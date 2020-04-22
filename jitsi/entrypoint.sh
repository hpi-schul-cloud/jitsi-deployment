#!/bin/bash
set -euo pipefail

if [[ "$1" =~ ^[0-9]+$ ]]; then
    BASE_PORT=$1
    shift
else
    BASE_PORT=30300
fi

export JVB_PORT=$(($BASE_PORT+${HOSTNAME##*-}))
echo "JVB_PORT=$JVB_PORT"

exec "$@"
