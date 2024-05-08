#!/bin/bash
# Script to obtain the actual size (usage) of mailboxes in the Zimbra environment
# Useful for validating the migration process
# Reference: https://wiki.zimbra.com/wiki/Get_all_user%27s_mailbox_size_from_CLI

all_accounts=$(zmprov -l gaa)

for account in $all_accounts; do
    mbox_size=$(zmmailbox -z -m $account gms)
    echo "Espaço UTILIZADO da conta $account = $mbox_size"
done
