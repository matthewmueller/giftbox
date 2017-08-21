MONIT_VERSION := 5.23.0

DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
VERSION ?= $(shell date -u +%Y-%m-%d-%H-%M)
NAME := $(shell basename $(DIR))

INFOLOG := \033[34m ▸\033[0m
WARNLOG := \033[33m ▸\033[0m
ERROLOG := \033[31m ⨯\033[0m

update:
	@mkdir -p $(DIR)/src
	@curl -s "https://mmonit.com/monit/dist/binary/$(VERSION)/monit-$(VERSION)-linux-x64.tar.gz" \
		| tar zx --strip-components 1 -C $(DIR)/src

release:
	@echo "$(INFOLOG) packaging monit"
	@mkdir -p rpm
	@fpm \
		--input-type=dir \
		--output-type=rpm \
		--name $(NAME) \
		--version $(VERSION) \
		--architecture x86_64 \
		--package "$(DIR)/rpm/$(NAME)-$(VERSION).rpm" \
		--rpm-os linux \
		--template-scripts \
		--after-install "$(DIR)/postinstall.sh" \
		--after-upgrade "$(DIR)/postupgrade.sh" \
		--before-remove "$(DIR)/preremove.sh" \
		--depends "procps" \
		--depends "util-linux" \
    --depends "initscripts" \
		--force \
		"$(DIR)/src/bin/monit"="/usr/local/bin/monit" \
		"$(DIR)/src/man/man1/monit.1"="/usr/share/man/man1/monit.1" \
		"$(DIR)/monitrc"="/usr/local/etc/monitrc" \
		"$(DIR)/init.sh"="/etc/init.d/monit"
	@test ! -e "./rpm/$(NAME).rpm" || (cp ./rpm/$(NAME).rpm ./rpm/$(NAME).prev.rpm)
	@mv ./rpm/$(NAME)-$(VERSION).rpm ./rpm/$(NAME).rpm