#!/bin/bash
set -eo pipefail

# echo to stderr
stderr() {
	echo "$@" 1>&2; 
}

main() {
    # local name="${1}"
    local version="${2}"

    yum install -y "https://github.com/matthewmueller/giftbox/raw/${version}/rpm/monit.rpm"
}

main "<%= name %>" "<%= version %>"