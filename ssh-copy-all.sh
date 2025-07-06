#!/bin/bash

# Script to copy SSH keys to multiple hosts for passwordless authentication

# Check if the host file is provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <host_file>"
    echo "Example: $0 hosts"
    exit 1
fi

HOST_FILE=$1

# Check if the file exists and is readable
if [ ! -f "$HOST_FILE" ] || [ ! -r "$HOST_FILE" ]; then
    echo "Error: Cannot read host file '$HOST_FILE'. Please check the file path and permissions."
    exit 1
fi

# Loop through each host in the file
while IFS= read -r host; do
    # Skip empty lines and comments
    [[ -z "$host" || "$host" =~ ^# ]] && continue

    echo "Copying SSH key to $host..."
    ssh-copy-id "$host"

    if [ $? -eq 0 ]; then
        echo "Key successfully copied to $host."
    else
        echo "Error: Could not copy SSH key to $host. Please check your connection or credentials."
    fi
    echo
done < "$HOST_FILE"

echo "SSH key distribution complete!"
