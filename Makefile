# Generated by Medikit 0.5.14 on 2018-03-18.
# All changes will be overriden.
# Edit Projectfile and run “make update” (or “medikit update”) to regenerate.

PACKAGE ?= mondrian
PYTHON ?= $(shell which python || echo python)
PYTHON_BASENAME ?= $(shell basename $(PYTHON))
PYTHON_DIRNAME ?= $(shell dirname $(PYTHON))
PYTHON_REQUIREMENTS_FILE ?= requirements.txt
PYTHON_REQUIREMENTS_DEV_FILE ?= requirements-dev.txt
QUICK ?= 
PIP ?= $(PYTHON) -m pip
PIP_INSTALL_OPTIONS ?= 
VERSION ?= $(shell git describe 2>/dev/null || git rev-parse --short HEAD)
PYTEST ?= $(PYTHON_DIRNAME)/pytest
PYTEST_OPTIONS ?= --capture=no --cov=$(PACKAGE) --cov-report html
SPHINX_BUILD ?= $(PYTHON_DIRNAME)/sphinx-build
SPHINX_OPTIONS ?= 
SPHINX_SOURCEDIR ?= docs
SPHINX_BUILDDIR ?= $(SPHINX_SOURCEDIR)/_build
YAPF ?= $(PYTHON) -m yapf
YAPF_OPTIONS ?= -rip
MEDIKIT ?= $(PYTHON) -m medikit
MEDIKIT_UPDATE_OPTIONS ?= 
MEDIKIT_VERSION ?= 0.5.14

.PHONY: $(SPHINX_SOURCEDIR) clean format help install install-dev medikit quick release test update update-requirements

install: .medikit/install   ## Installs the project.
.medikit/install: $(PYTHON_REQUIREMENTS_FILE) setup.py
	$(eval target := $(shell echo $@ | rev | cut -d/ -f1 | rev))
ifeq ($(filter quick,$(MAKECMDGOALS)),quick)
	@printf "Skipping \033[36m%s\033[0m because of \033[36mquick\033[0m target.\n" $(target)
else ifneq ($(QUICK),)
	@printf "Skipping \033[36m%s\033[0m because \033[36m$$QUICK\033[0m is not empty.\n" $(target)
else
	@printf "Applying \033[36m%s\033[0m target...\n" $(target)
	$(PIP) install $(PIP_INSTALL_OPTIONS) -U pip wheel
	$(PIP) install $(PIP_INSTALL_OPTIONS) -U -r $(PYTHON_REQUIREMENTS_FILE)
	@mkdir -p .medikit; touch $@
endif

install-dev: .medikit/install-dev   ## Installs the project (with dev dependencies).
.medikit/install-dev: $(PYTHON_REQUIREMENTS_DEV_FILE) $(PYTHON_REQUIREMENTS_FILE) setup.py
	$(eval target := $(shell echo $@ | rev | cut -d/ -f1 | rev))
ifeq ($(filter quick,$(MAKECMDGOALS)),quick)
	@printf "Skipping \033[36m%s\033[0m because of \033[36mquick\033[0m target.\n" $(target)
else ifneq ($(QUICK),)
	@printf "Skipping \033[36m%s\033[0m because \033[36m$$QUICK\033[0m is not empty.\n" $(target)
else
	@printf "Applying \033[36m%s\033[0m target...\n" $(target)
	$(PIP) install $(PIP_INSTALL_OPTIONS) -U pip wheel
	$(PIP) install $(PIP_INSTALL_OPTIONS) -U -r $(PYTHON_REQUIREMENTS_DEV_FILE)
	@mkdir -p .medikit; touch $@
endif

clean:   ## Cleans up the local mess.
	rm -rf build dist *.egg-info
	find . -name __pycache__ -type d | xargs rm -rf

quick:   #
	@printf ""

test: install-dev  ## Runs the test suite.
	$(PYTEST) $(PYTEST_OPTIONS) tests

$(SPHINX_SOURCEDIR): install-dev  ##
	$(SPHINX_BUILD) -b html -D latex_paper_size=a4 $(SPHINX_OPTIONS) $(SPHINX_SOURCEDIR) $(SPHINX_BUILDDIR)/html

format: install-dev  ## Reformats the whole python codebase using yapf.
	$(YAPF) $(YAPF_OPTIONS) .
	$(YAPF) $(YAPF_OPTIONS) Projectfile

release:   ## Releases mondrian.
	python -c 'import medikit; print(medikit.__version__)' || pip install medikit;
	$(PYTHON) -m medikit pipeline release start

medikit:   # Checks installed medikit version and updates it if it is outdated.
	@$(PYTHON) -c 'import medikit, sys; from packaging.version import Version; sys.exit(0 if Version(medikit.__version__) >= Version("$(MEDIKIT_VERSION)") else 1)' || $(PYTHON) -m pip install -U "medikit>=$(MEDIKIT_VERSION)"

update: medikit  ## Update project artifacts using medikit.
	$(MEDIKIT) update $(MEDIKIT_UPDATE_OPTIONS)

update-requirements:   ## Update project artifacts using medikit, including requirements files.
	MEDIKIT_UPDATE_OPTIONS="--override-requirements" $(MAKE) update

help:   ## Shows available commands.
	@echo "Available commands:"
	@echo
	@grep -E '^[a-zA-Z_-]+:.*?##[\s]?.*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?##"}; {printf "    make \033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo
