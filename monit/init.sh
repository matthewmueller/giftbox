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

main() {
		declare action="${1}"

		case $action in
		start)   do_start;   exit $? ;;
		stop)    do_stop;    exit $? ;;
		restart) do_restart; exit $? ;;
		status)  do_status;  exit $? ;;
		*)       do_usage;   exit $? ;;
		esac
}

# echo to stderr
stderr() {
	echo "$@" 1>&2; 
}

# search processes for an exact match of $command
# return 1 or 0 based of if the process is running or not
is_running() {
		pidof -x "$command" > /dev/null 2>&1
}

do_setup() {
		# prereqs
		[[ -x "$command" ]] || (stderr "$command not found"; exit 1)
		[[ -r "$config" ]] || (stderr "$config not found or not readable"; exit 1)

		# ensure that we'll run at boot
		chkconfig --add "$name" || (stderr "unable to add $name to chkconfig"; exit 1)
		chkconfig "$name" on || (stderr "unable to turn $name on in chkconfig"; exit 1)

		# setup stdout as root, but hand ownership over to $user
		if [[ ! -w "$stdout" ]]; then
			touch "$stdout"
			chown "$user" "$stdout"
		fi

		# setup stderr as root, but hand ownership over to $user
		if [[ ! -w "$stderr" ]]; then
			touch "$stderr"
			chown "$user" "$stderr"
		fi

		# setup the user configuration directory
		mkdir -p "$configdir"
}

do_start() {
		if is_running; then
				stderr "Already started"
				return 0
		fi

		stderr -n "Starting $name.."
		do_setup
		su --login --shell /bin/sh "$user" --command "exec $exec >> $stdout 2>> $stderr &"

		# wait for 10 $timeout to make sure the command is still running
		for (( i=0; i<timeout; i++))
		do
				stderr -n "."
				if ! is_running; then
						break
				fi
				sleep 1
		done
		stderr

		# if we're not running, echo error
		if ! is_running; then
				stderr "Unable to start, see $stderr"
				return 1
		fi

		# add lockfile
		touch "$lockfile"

		stderr "Started"
		return 0
}

do_stop() {
		if ! is_running; then
			stderr "Not running"
			return 0
		fi

		stderr -n "Stopping $name.."
		pkill -fx "$exec" || (stderr "Not stopped; pkill couldn't find process to stop"; exit 1)
		
		for (( i=0; i<timeout; i++))
		do
				stderr -n "."
				if ! is_running; then
						break
				fi
				sleep 1
		done
		stderr

		# TODO: add pkill -9 after timeout

		if is_running; then
				stderr "Not stopped; may still be shutting down or shutdown may have failed"
				return 1
		fi

		# remove lockfile
		rm "$lockfile"
		
		stderr "Stopped"
		return 0
}

do_restart() {
		if ! is_running; then
			do_start
			return $?
		fi

		stderr -n "Restarting $name.."
		do_setup
		pkill -HUP -fx "$exec" || (stderr "Not restarted; pkill couldn't find process to restart"; exit 1)

		# wait for 10 $timeout to make sure the command is still running
		for (( i=0; i<timeout; i++))
		do
				stderr -n "."
				if ! is_running; then
						break
				fi
				sleep 1
		done
		stderr ""

		# if we're not running, stderr error
		if ! is_running; then
				stderr "Unable to restart, see $stderr"
				return 1
		fi

		stderr "Restarted"
		return 0
}

do_status() {
		if is_running; then
				stderr "Running"
		else
				stderr "Stopped"
				return 1
		fi
		return 0
}

do_usage() {
	stderr $"Usage: $name {start | stop | restart | status}"
	return 1
}

main "$@"