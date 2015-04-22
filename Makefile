#!/usr/bin/make
PYTHON := /usr/bin/env python
export PYTHONPATH := hooks

virtualenv:
	virtualenv .venv
	.venv/bin/pip install flake8 nose mock six

lint: virtualenv
	.venv/bin/flake8 --exclude hooks/charmhelpers hooks tests/10-tests
	@charm proof

bin/charm_helpers_sync.py:
	@mkdir -p bin
	@bzr cat lp:charm-helpers/tools/charm_helpers_sync/charm_helpers_sync.py \
        > bin/charm_helpers_sync.py

sync: bin/charm_helpers_sync.py
	@$(PYTHON) bin/charm_helpers_sync.py -c charm-helpers-hooks.yaml
	@$(PYTHON) bin/charm_helpers_sync.py -c charm-helpers-tests.yaml

test:
	@echo Starting Amulet tests...
	# coreycb note: The -v should only be temporary until Amulet sends
	# raise_status() messages to stderr:
	#   https://bugs.launchpad.net/amulet/+bug/1320357
	@juju test -v -p AMULET_HTTP_PROXY --timeout 900 \
        00-setup 10-tests
