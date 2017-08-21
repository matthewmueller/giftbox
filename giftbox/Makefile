DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
VERSION ?= $(shell date -u +%Y-%m-%d-%H-%M)
CURRENT_TAG := release-$(VERSION)
NAME := $(shell basename $(DIR))

GHBASE := https://github.com/matthewmueller/giftbox/raw/$(CURRENT_TAG)/rpm

INFOLOG := \033[34m ▸\033[0m
WARNLOG := \033[33m ▸\033[0m
ERROLOG := \033[31m ⨯\033[0m

update:
	@echo "nothing to do"

release:
	@echo "$(INFOLOG) packaging giftbox"
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
		--depends "$(GHBASE)/monit.rpm" \
		--force \
			"$(DIR)/init.sh"="/etc/init.d/giftbox"
	@test ! -e "./rpm/$(NAME).rpm" || (cp ./rpm/$(NAME).rpm ./rpm/$(NAME).prev.rpm)
	@mv ./rpm/$(NAME)-$(VERSION).rpm ./rpm/$(NAME).rpm