#!/usr/bin/env bash
#
# Author: Dolphin Whisperer
# Email: jeremy.bell@nih.gov
# Created: 2025-01-17
# Description: This script creates and manages SSH keys for a user and ensures their inclusion in the authorized_keys file for SSH authentication. 
#
set -e  # exit immediately if a command exits with a non-zero status
#
PASSPHRASE=""
KEYTYPES="rsa ecdsa ed25519"  # 'dsa' is deprecated
AUTHORIZEDKEYS="$HOME/.ssh/authorized_keys"
HOSTFILE=/path/to/hostfile
#
echo "Creating the user SSH v2 $AUTHORIZEDKEYS file for user $USER"
echo "Beware: An empty passphrase is used, which means a lower security level."
#
# ensure the user's home directory exists
if [[ ! -d "$HOME" ]]; then
    echo "ERROR: No home directory $HOME for user $USER"
    exit 1
fi
$
# ensure the ssh-keygen tool is installed
if [[ ! -x /usr/bin/ssh-keygen ]]; then
    echo "ERROR: ssh-keygen not found, please install the openssh package"
    exit 1
fi
#
# ensure the .ssh directory exists
if [[ ! -d "$HOME/.ssh/" ]]; then
    echo "Creating $HOME/.ssh/"
    mkdir -v "$HOME/.ssh/"
fi
#
# Ensure .ssh/ has the correct permissions
chmod 700 "$HOME/.ssh/"
#
# Navigate to the .ssh folder and ensure the authorized_keys file exists
cd "$HOME/.ssh/"
#
if [[ ! -f "$AUTHORIZEDKEYS" ]]; then
    touch "$AUTHORIZEDKEYS"
fi
#
# loop over the key types and manage keys
for keytype in $KEYTYPES; do
    # generate the key if it doesn't exist
    if [[ ! -f "id_${keytype}.pub" ]]; then
        echo "Generating SSH key for keytype $keytype"
        /usr/bin/ssh-keygen -t "$keytype" -f "id_${keytype}" -N "$PASSPHRASE"
    fi
#
    # extract the key material and check if it is in authorized_keys
    KEY_MATERIAL=$(cut -d' ' -f2 "id_${keytype}.pub")
    if grep -q "$KEY_MATERIAL" "$AUTHORIZEDKEYS"; then
        echo "$keytype key already in $AUTHORIZEDKEYS"
    else
        echo "Appending $keytype key to $AUTHORIZEDKEYS"
        cat "id_${keytype}.pub" >> "$AUTHORIZEDKEYS"
    fi
done
#
# set proper permissions for authorized_keys
chmod 600 "$AUTHORIZEDKEYS"
#
echo "SSH keys and $AUTHORIZEDKEYS file are successfully configured."
echo ""
echo "If you'd like to enable passwordless authentication throughout the cluster:"
echo ""
echo "1. Create a 'hosts' file containing one host per-line (e.g., vim bigsky-hosts) or copy the file from here:"
echo " blahblah"
echo "2. Run this command to iterate through the hosts file and copy your new key to each host:"
echo "for i in $(cat $HOSTFILE); do echo $i; ssh-copy-id $i; done"
echo ""
echo "You'll need your password handy, as you will be prompted to accept the fingerprint of the server and enter your current password to complete the transaction - cha-ching."
