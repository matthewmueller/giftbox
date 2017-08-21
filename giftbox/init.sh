#!/bin/bash
### BEGIN INIT INFO
# Provides:          generic-prog
# Required-Start:    $local_fs $remote_fs $network
# Required-Stop:     $local_fs $remote_fs $network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Generic Program
# Description:       Generic Program is a generic program to do generic things with
### END INIT INFO

set -eo pipefail
[[ "${TRACE}" ]] && set -x

# variables you shouldn't need to touch
readonly name=$(basename "$(readlink -f "${0}")")
readonly command="/usr/local/bin/$name"
readonly lockfile="/var/lock/subsys/$name"
readonly stdout="/var/log/${name}.log"
readonly stderr="/var/log/${name}.err"

# variables you may want to edit
readonly user="root"
readonly exec="$command -I"
readonly timeout=10 # seconds
readonly config="/usr/local/etc/monitrc"
readonly configdir="/usr/local/etc/monit.d"

# echo to stderr
stderr() {
	echo "$@" 1>&2; 
}

main() {
		declare action="${1}"

		case $action in
		start)   do_start;   exit $? ;;
		stop)    do_stop;    exit $? ;;
		restart) do_restart; exit $? ;;
		*)       do_usage;   exit $? ;;
		esac
}

do_setup() {
		stderr "unboxing!"
}

do_teardown() {
    stderr "TODO"
}

do_start() {
    stderr -n "Setting up box..."
    do_setup
    stderr -n "Set up box"
		return 0
}

do_stop() {
    stderr -n "Tearing down box..."
    do_teardown
    stderr -n "Tore down box"
		return 0
}

do_restart() {
    stderr -n "Setting up box..."
    do_setup
    stderr -n "Set up box"
		return 0
}

do_status() {
    stderr -n "Not running"
		return 0
}

do_usage() {
	stderr $"Usage: $name {start | stop | restart | status}"
	return 1
}

main "$@"