#!/bin/sh

set -e

if [[ -e "/home/opencode/.local/bin/plannotator" ]]; then
    sudo ln -sf "/home/opencode/.local/bin/plannotator" "/usr/local/bin/plannotator"
fi

opencode serve --hostname 0.0.0.0 --port 4096
