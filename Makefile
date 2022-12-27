# -*- makefile -*-
# -----------------------------------------------------------------------
# Copyright 2023 Open Networking Foundation (ONF) and the ONF Contributors
# Copyright 2017-2023 Open Networking Foundation (ONF) and the ONF Contributors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-FileCopyrightText: 2017-2023 Open Networking Foundation (ONF) and the ONF Contributors
# SPDX-License-Identifier: Apache-2.0
# -----------------------------------------------------------------------

# -*- makefile -*-
# -----------------------------------------------------------------------
# Copyright 2017-2022 Open Networking Foundation (ONF) and the ONF Contributors
# SPDX-FileCopyrightText: 2022-present Intel Corporation
#
# SPDX-License-Identifier: Apache-2.0
# -----------------------------------------------------------------------

.DEFAULT_GOAL := test

dot         ?= .
TOP         ?= $(dot)
MAKEDIR     ?= $(TOP)/makefiles

jq          = $(env-clean) jq
jq-args     += --exit-status

YAMLLINT      = $(shell which yamllint)
yamllint      := $(env-clean) $(YAMLLINT)
yamllint-args := -c .yamllint

##--------------------##
##---]  INCLUDES  [---##
##--------------------##
include $(MAKEDIR)/include.mk

##-------------------##
##---]  TARGETS  [---##
##-------------------##
all:

lint += lint-json
lint += lint-yaml

lint : $(lint)
test : lint

## -----------------------------------------------------------------------
## -----------------------------------------------------------------------
lint-yaml yaml-lint:
ifeq ($(null),$(shell which yamllint))
	$(error "Please install yamllint to run linting")
endif
	$(HIDE)$(env-clean) find . -name '*.yaml' -type f -print0 \
	    | xargs -0 -t -n1 $(yamllint) $(yamllint-args)

## -----------------------------------------------------------------------
## -----------------------------------------------------------------------
lint-json:
	$(HIDE)$(env-clean) find . -name '*.json' -type f -print0 \
	    | xargs -0 -t -n1 $(jq) $(jq-args) $(dot) >/dev/null

## -----------------------------------------------------------------------
## -----------------------------------------------------------------------
pre-check:
	@echo "[REQUIRED] Checking for linting tools"
	$(HIDE)which jq
	$(HIDE)which yamllint
	@echo

## -----------------------------------------------------------------------
## -----------------------------------------------------------------------
.PHONY: pre-commit
.PHONY: fixperms
pre-commit: lint fixperms

## -----------------------------------------------------------------------
## Scrub volume messages from jenksins logs and help secure nodes.
## WARNING: Kubernetes configuration file is group-readable. This is insecure
## -----------------------------------------------------------------------
fixperms-args :=$(null)
fixperms-args += -name '*.conf'
fixperms-args += -o -name '*.json'
fixperms-args += -o -name '*.yaml'
fixperms:
	$(HIDE)find . \( $(fixperms-args) \) -print0 \
	    | xargs -0 chmod og-rwx

## -----------------------------------------------------------------------
## -----------------------------------------------------------------------
clean:

## -----------------------------------------------------------------------
## -----------------------------------------------------------------------
help::
	@echo
	@echo "USAGE: $(MAKE)"
	@echo "  lint        perform syntax checks on source"
	@echo "  test        perform syntax checks on source"
	@echo "  pre-check   Verify tools and deps are available for testing"
	@echo
	@echo "[LINT]"
	@echo "  lint-json   Syntax check .json sources"
	@echo "  lint-yaml   Syntax check .yaml sources"
	@echo
	@echo "[PRE:check]"
	@echo "  pre-check   Verify tools and deps are available for testing"
	@echo
	@echo "[PRE:commit]"
	@echo "  pre-commit  Perform common repairs on source"
	@echo "  fixperms    Remove group write permission on config files"
	@echo

# [EOF]
