#!/usr/bin/env bash
# Tests if the transmission daemon is up and running.

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NEUTRAL='\033[0m'

# Config
TRANSMISSION_RPC_PORT=9091
TRANSMISSION_RPC_AUTH='transmission:transmission'

#
# Given a tool and  a port will check if a process named transmission
# is listening
#
check-transmission-port() {
    tool=$1
    port=$2
    
    case $tool in
    ss)
        ss -ltnp sport = ":${port}" | grep -q 'transmission'
        ;;
    lsof)
        lsof -i "tcp:${port}" | grep "LISTEN" | grep -q 'transmission'
        ;;
    *)
        printf "\n\n${RED}Unsupported port detection tool: %s ${NEUTRAL}\n" $tool
        exit 1
    esac
}

#
# Check if transmission is listening
#
is-transmission-listening() {
    rpc_port=$1
    
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
        if check-transmission-port "${portmap_tool}" "${rpc_port}"; then
            # Break the loop if we get a positive result
            break
        else
            printf "\n${GREEN}transmission-daemon - ${RED}NOT listening on tcp/${rpc_port}${NEUTRAL} after ${retry_time} seconds. (Test via: ${portmap_tool})\n\n"
        fi
        # If below the timeout threshold sleep a few seconds and retry
        if [[ $retry_time -lt 60 ]]; then
            sleep 5
            retry_time=$(($retry_time + 5))
        else
            # If wait time is above the timeout, bail out.
            break -1
        fi
    done
}

###############
#     MAIN    #
###############

is-transmission-listening "${TRANSMISSION_RPC_PORT}"
if [[ $? -ne 0 ]]; then
    printf "\n${GREEN}transmission-daemon - ${RED}Transmission daemon not listening after timeout.${NEUTRAL}\n\n"
    exit 1
fi

# Check for Transmission Remote executable
if hash transmission-remote 2>/dev/null; then
    printf "\n${RED}Unable to find transmission-remote.${NEUTRAL}\n\n"
    exit 1
fi

# Check for connection via transmission-remote
if transmission-remote  -n "${TRANSMISSION_RPC_AUTH}" -l >/dev/null; then
    printf "\n${RED}transmission-remote - UNABLE TO CONNECT to the daemon.${NEUTRAL}\n\n"
    exit 1
else
    printf "\n${GREEN}transmission-remote - successfully connected to the daemon.${NEUTRAL}\n\n"
fi
