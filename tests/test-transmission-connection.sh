#!/usr/bin/env bash
# Tests if the transmission daemon is up and running.

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NEUTRAL='\033[0m'

# Config
TRANSMISSION_RPC_PORT=9091

check-transmission-port() {
    case $1 in
    ss)
        ss -ltnp sport = ":${TRANSMISSION_RPC_PORT}" | grep -q 'transmission'
        ;;
    lsof)
        lsof -i "tcp:${TRANSMISSION_RPC_PORT}" | grep "LISTEN" | grep -q 'transmission'
        ;;
    *)
        printf "\n\n${RED}Unsupported port detection tool: %s ${NEUTRAL}\n" $1
        exit 1
    esac
}

# Check if transmission is listening on the RPC port.
if hash ss 2>/dev/null; then
    portmap_tool="ss"
elif hash lsof 2>/dev/null; then
    portmap_tool="lsof"
else
    printf "\n${RED}Unable to find any suitable commant to test for listening processes.${NEUTRAL}\n\n"
    exit 1
fi

# Try to check if the daemon is ready and listening, give it up to 60 seconds
# to come up after the playbook is finished.
retry_time=0
while true; do
    if check-transmission-port "${portmap_tool}"; then
        # Break the loop if we get a positive result
        break
    else
        printf "\n${GREEN}transmission-daemon - ${RED}NOT listening on tcp/${TRANSMISSION_RPC_PORT}${NEUTRAL} after ${retry_time} seconds. (Test via: ${portmap_tool})\n\n"
    fi
    # If we encountered a failure check if the TTL is exceded,
    if [[ $retry_time -gt 60 ]]; then
        printf "\n${GREEN}transmission-daemon - ${RED}Aborting due to timeout.${NEUTRAL}\n\n"
        exit 1
    else
        # if not out-of-time sleep for 5 more seconds and try another time.
        sleep 5
        retry_time=$(($retry_time + 5))
    fi
done

# Check for Transmission Remote executable
if [[ -z $(which transmission-remote) ]]; then
    printf "\n${RED}Unable to find transmission-remote.${NEUTRAL}\n\n"
    exit 1
fi

# Check for connection
transmission-remote  -n 'transmission:transmission' -l >/dev/null

if [[ $? -ne 0 ]]; then
    printf "\n${RED}transmission-remote - UNABLE TO CONNECT to the daemon.${NEUTRAL}\n\n"
    exit 1
else
    printf "\n${GREEN}transmission-remote - successfully connected to the daemon.${NEUTRAL}\n\n"
fi

# Set exit value
true