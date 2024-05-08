#!/bin/bash
# Script to audit all forwarding configurations set up in Zimbra accounts
# Reference: https://wiki.zimbra.com/wiki/Obtain_all_the_forwards_per_each_account

for account in $(zmprov -l gaa); do
    forwardingaddress=$(zmprov ga $account | grep 'zimbraPrefMailForwardingAddress' | sed 's/zimbraPrefMailForwardingAddress: //')
    if [ -n "$forwardingaddress" ]; then
        echo "$account is forwarding to $forwardingaddress"
    else
        forwardingaddress=""
    fi
done
