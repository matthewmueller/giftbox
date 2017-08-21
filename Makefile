MONIT_VERSION := 5.23.0

giftbox:
	go run giftbox/giftbox.go fetch
.PHONY: giftbox

release:
	goreleaser --rm-dist



download.monit:
	mkdir -p ./vendor/monit
	curl -s "https://mmonit.com/monit/dist/binary/$(MONIT_VERSION)/monit-$(MONIT_VERSION)-linux-x64.tar.gz" \
		| tar zx --strip-components 1 -C ./vendor/monit