#!/bin/sh
# Tests if the transmission daemon is up and running.

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NEUTRAL='\033[0m'

# Config
TRANSMISSION_RPC_PORT=9091

# Check if transmission is listening on the RPC port.
if [[ ! -z "$(which lsof)" ]]; then
    tool="lsof"
    lsof -i ":${TRANSMISSION_RPC_PORT}" | grep "LISTEN" | grep -q 'transmission'
    status="$?"
elif [[ ! -z "$(which netstat)" ]]; then
    tool="netstat"
    netstat -pln | grep "$TRANSMISSION_RPC_PORT" | grep "LISTEN" | grep -q 'transmission'
    status="$?"
elif [[ ! -z "$(which ss)" ]]; then
    tool="ss"
    ss -tpl | grep "$TRANSMISSION_RPC_PORT" | grep "LISTEN" | grep -q 'transmission'
    status="$?"
else
    printf "\n${RED}Unable to find any suitable commant to test for listening processes.${NEUTRAL}\n\n"
    exit 1
fi

if [[ $status -ne 0 ]]; then
    printf "\n${RED}transmission-daemon - NOT listening on port: ${TRANSMISSION_RPC_PORT} (Via ${tool})${NEUTRAL}\n\n"
    exit 1
else
    printf "\n${GREEN}transmission-daemon - listening on: ${TRANSMISSION_RPC_PORT} (Via ${tool})${NEUTRAL}\n\n"
fi

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