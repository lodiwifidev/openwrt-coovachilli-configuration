#!/bin/sh 
#
# Pings a remote host and restarts WiFi/OpenVPN if the connection is down
# Requires "fping" -> opkg install fping
#
# Copyright (C) 2020 luani.de

. /lib/functions.sh

# check prerequisites
if [ ! -x "$(command -v fping)" ]; then
	echo 'watchping error: fping is not installed, exiting' >&2
	exit 1
fi

config_load watchping
if [ $? -ne 0 ]; then
	echo 'watchping error: configuration not found, exiting' >&2
	exit 1
fi

# setup function, parse config & check ranges
setup_check() {
	local job=$1
	if [ -z $job ]; then return 1; fi

	local enabled
	config_get_bool enabled ${job} enabled "false"
	if [ "$enabled" -eq "1" ]; then
		local host
		local timeout
		local command

		config_get host ${job} host "localhost"
		config_get timeout ${job} timeout "5"
		config_get command ${job} command ""
		if [ $timeout -le 0 ]; then
			$timeout=5
		fi
		if [ -z "$command" ]; then
			return 1
		fi

		eval "${job}_host"=\$host
		eval "${job}_timeout"=\$timeout
		eval "${job}_command"=\$command
		eval "${job}_failcount"=0

		joblist="${joblist} ${job}"
		logger -t "watchping" "job '${job}' setup: host '${host}', timeout ${timeout} min"
	fi
}

# check function
perform_check() {
	local job=$1

	local host
	local timeout
	local command
	local failcount
	local failure=0

	eval host=\$"${job}_host"
	eval timeout=\$"${job}_timeout"
	eval command=\$"${job}_command"
	eval failcount=\$"${job}_failcount"

	# ping host
	fping --ipv4 --quiet --count 1 --random ${host} &> /dev/null
	if [ $? -ne 0 ]; then
		failure=1
		let "failcount++"
	else
		failcount=0
	fi

	if [ $failcount -ge $timeout ]; then
		failcount=0
		logger -t "watchping" "job '${job}' failure: host (${host}) is down for $timeout min, command initiated!"

		# restart service
		eval "$command"
	fi

	eval "${job}_failcount"=\$failcount
	return $failure
}


# read configuration
joblist=""
config_foreach setup_check watchping

# check loop
firstrun=true
while sleep 60; do
	for job in $joblist; do		
		perform_check ${job}

		if [ $? -eq 0 ] && [ "$firstrun" = true ]; then
			logger -t "watchping" "job '${job}' first run: executed successfully, host reachable"
		elif [ "$firstrun" = true ]; then
			logger -t "watchping" "job '${job}' first run: failed, host unavailable"
		fi
	done
	if [ "$firstrun" = true ]; then firstrun=false; fi
done

exit 0
