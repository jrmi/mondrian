import re
import sys
from contextlib import contextmanager
from sys import exc_info

from mondrian import settings, term
from mondrian.formatters import format_exception
from mondrian.styles import BOTTOM_LEFT, BOTTOM_RIGHT, HORIZ, TOP_LEFT, TOP_RIGHT, VERT, VERT_LEFT

preformatted_pattern = re.compile("([^`]*)`([^`]*)`([^`]*)")


def humanized(exc, *, fg=term.red, bg=lambda *args: term.red_bg(term.bold(*args))):
    SPACES = 2
    prefix, suffix = fg(VERT + " " * (SPACES - 1)), fg(" " * (SPACES - 1) + VERT)
    result = []

    def format_arg(arg):
        length = len(preformatted_pattern.sub("\\1\\2\\3", arg))
        arg = preformatted_pattern.sub("\\1" + term.bold("\\2") + "\\3", arg)
        arg = re.sub("^  \$ (.*)", term.lightblack("  $ ") + term.reset("\\1"), arg)
        return (arg, length)

    def joined(*args):
        return "".join(args)

    term_width, term_height = term.get_size()
    line_length = min(80, term_width)
    for arg in exc.args:
        line_length = max(min(line_length, len(arg) + 2 * SPACES), 120)

    result.append(joined(fg(TOP_LEFT + HORIZ * (line_length - 2) + TOP_RIGHT)))

    for i, arg in enumerate(exc.args):

        if i == 1:
            result.append(joined(prefix, " " * (line_length - 2 * SPACES), suffix))

        arg_formatted, arg_length = format_arg(arg)
        if not i:
            # first line
            result.append(
                joined(
                    prefix,
                    bg(" " + type(exc).__name__ + " "),
                    " ",
                    term.white(arg_formatted),
                    " " * (line_length - (arg_length + 3 + len(type(exc).__name__) + 2 * SPACES)),
                    suffix,
                )
            )
        else:
            # other lines
            result.append(joined(prefix, arg_formatted + " " * (line_length - arg_length - 2 * SPACES), suffix))

    more = settings.DEBUG
    exc_lines = format_exception(exc_info(), fg=fg, bg=bg, summary=False).splitlines()

    if not len(exc_lines):
        more = False

    result.append(
        joined(fg((VERT_LEFT if more else BOTTOM_LEFT) + HORIZ * (line_length - 2) + BOTTOM_RIGHT)),
    )

    if more:
        for _line in exc_lines:
            result.append(_line)
        result.append(joined(fg("╵")))

    return '\n'.join(result)


class Success():
    def __init__(self, *args):
        self.args = args

    def __str__(self):
        return humanized(self, fg=term.green, bg=lambda *args: term.lightgreen_bg(term.lightblack(*args)))


@contextmanager
def humanize(*, types=(Exception,)):
    if not isinstance(types, tuple):
        types = (types,)

    try:
        yield
    except types as exc:
        print(humanized(exc), file=sys.stderr)