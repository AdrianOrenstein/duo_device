#!/bin/bash

# Check if oathtool is installed
if ! command -v oathtool >/dev/null 2>&1; then
    echo "Error: 'oathtool' is not installed."
    echo "Please install oathtool to use this script."
    echo "For Debian/Ubuntu, run: sudo apt-get install oathtool"
    echo "For macOS with Homebrew, run: brew install oath-toolkit"
    exit 1
fi

# Path to your HOTP token file, resolved next to this script
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
token_file="$script_dir/duotoken.hotp"

# Check if the token file exists
if [ ! -f "$token_file" ]; then
    echo "Token file not found at $token_file"
    exit 1
fi

# Read the secret and count from the file
secret=$(sed -n '1p' "$token_file")
count=$(sed -n '2p' "$token_file")

# Generate the HOTP code using oathtool
code=$(oathtool --base32 --hotp --counter="$count" "$secret")

# Increment the count
new_count=$((count + 1))

# Write the secret and new count back to the file
{
    echo "$secret"
    echo "$new_count"
} > "$token_file"

# Output the code
echo "$code"