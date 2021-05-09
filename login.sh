#!/bin/bash
set -e

dir="$(dirname "$0")"
duo="$dir/duo-cli"
venv="$duo/venv/bin"
echo "Reading config..." >&2
source "$dir/config"
uoy_pass="env"
#Check if duo-cli has been activated
if [ ! -f "$duo/tokens.txt" ]; then
    echo "Duo has not been set up. Please follow the instruction in the README."
    read -p "Enter activation url when ready: " duo_url
    eval "$venv/python $duo/duo_activate.py $duo_url" > "$duo/tokens.txt"
fi
echo "Generating a DUO token..."
duo_otp="$("$venv/python" "$duo/duo_gen.py" | tail -n 1 | cut -f 2 -d ' ')"
echo "Got token: $duo_otp"
expect -d "$dir/login.expect" "-vvv -E $dir/ssh.log $ssh_args $persistent_args" \
    "$host" "$user" "$uoy_pass" "$server" "$duo_otp"
