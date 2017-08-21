DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
VERSION := $(shell date -u +%Y-%m-%d-%H-%M)
COMMIT := $(shell git log -1 --format="%h")
APP := $(shell basename $(DIR))

INFOLOG := \033[34m ▸\033[0m
WARNLOG := \033[33m ▸\033[0m
ERROLOG := \033[31m ⨯\033[0m

release:
	#@test -d ".git" || (echo "$(ERROLOG) $(APP)/ is not a git repo"; exit 1)
	#@test -z "$(shell git status --porcelain 2> /dev/null)" || (echo "$(ERROLOG) repo has changed or untracked files"; exit 1)
	#@test ! $(shell git tag -l "release-$(VERSION)") || (echo "$(ERROLOG) tag 'release-$(VERSION)' already exists"; exit 1)

	@# dependencies
	@$(MAKE) -C $(DIR)/monit release VERSION=$(VERSION)
	@$(MAKE) -C $(DIR)/giftbox release VERSION=$(VERSION)
	
	@echo "$(INFOLOG) colocating packages"
	@mkdir -p $(DIR)/rpm/
	@cp -R $(DIR)/*/rpm/* $(DIR)/rpm/
	@echo "$(INFOLOG) released $(VERSION)"

	@echo "$(INFOLOG) tagging the release"
	@git add .
	@git commit -a --allow-empty -m "Release $(VERSION)"
	@git tag "release-$(VERSION)"

update:
	@$(MAKE) -C $(DIR)/monit update

test:
	@docker run -v $(DIR)/rpm:/rpm -it --rm --name monit amazonlinux /bin/bash

deploy:
	@docker cp $(DIR)/rpm monit:/
	@docker exec monit yum localinstall -y /rpm/monit.rpm

clean:
	rm -rf $(DIR)/rpm/*
	rm -rf $(DIR)/*/rpm/*