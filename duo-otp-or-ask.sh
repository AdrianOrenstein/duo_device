#!/bin/bash

# ssh calls this program (via SSH_ASKPASS) to obtain a passcode. Return the
# Duo OTP for the Duo prompt, read the terminal for other prompts, and fall
# back to a GUI when neither is available.

PROMPT="$1"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$PROMPT" == *"Duo Push"* ]]; then
    "$script_dir/duo_otp.sh" "$1"
elif [ -e /dev/tty ]; then
    # There's a controlling terminal, read from it
    read -s -p "$PROMPT" response < /dev/tty > /dev/tty
    echo "$response"
else
    # No controlling terminal, fall back to system ssh-askpass (GUI prompt)
    exec ssh-askpass "$PROMPT"
fi
