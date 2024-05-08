#!/bin/bash
# Utility to add disclaimer for all domains
# Starting from version 8.5, the feature of creating domain-specific disclaimers was added, making it impossible
# to use a universal disclaimer

# Obtains a list of all domains to add a default disclaimer
for DOMAIN in $(zmprov gad); do
    echo "Adding disclaimers for the domain: $DOMAIN"
    zmprov md $DOMAIN zimbraAmavisDomainDisclaimerText "$(cat /opt/zimbra/postfix/conf/disclaimer.txt)"
    zmprov md $DOMAIN zimbraAmavisDomainDisclaimerHTML "$(cat /opt/zimbra/postfix/conf/disclaimer.html)"
done
