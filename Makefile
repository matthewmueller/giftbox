MONIT_VERSION := 5.23.0

gh-fetch:
	go run gh-fetch/gh-fetch.go

release:
	goreleaser

download.monit:
	mkdir -p ./vendor/monit
	curl -s "https://mmonit.com/monit/dist/binary/$(MONIT_VERSION)/monit-$(MONIT_VERSION)-linux-x64.tar.gz" \
		| tar zx --strip-components 1 -C ./vendor/monit