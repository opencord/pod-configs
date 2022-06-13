# SPDX-FileCopyrightText: 2022-present Intel Corporation
#
# SPDX-License-Identifier: Apache-2.0

test: yaml-lint

yaml-lint:
ifeq (, $(shell which yamllint))
	$(error "Please install yamllint to run linting")
endif
	yamllint -c .yamllint .
