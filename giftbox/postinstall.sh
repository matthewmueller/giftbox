#!/bin/bash
set -eo pipefail

# echo to stderr
stderr() {
	echo "$@" 1>&2; 
}

main() {
    local name="${1}"
    local version="${2}"

    stderr "NAME: ${name}"
    stderr "VERSION: ${version}"
}

main "<%= name %>" "<%= version %>"