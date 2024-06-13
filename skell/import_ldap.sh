#!/bin/bash
###   Z2Z - Maintained by BKTECH <https://www.bktech.com.br>                     ###
###   Copyright (C) 2016  Fabio Soares Schmidt <fabio@respirandolinux.com.br>    ###
###   FOR INFORMATION ABOUT THE TOOL, PLEASE READ THE README AND INSTALL FILES   ###

# SETTING ZIMBRA ENVIRONMENT VARIABLES
source ~/bin/zmshutil
zmsetvars

# FUNCTIONS AND VARIABLES FOR THE UTILITY
NORMAL_TEXT="printf \e[1;34m%-6s\e[m\n" # Blue
ERROR_TEXT="printf \e[1;31m%s\e[0m\n"  # Red
INFO_TEXT="printf \e[1;33m%s\e[0m\n"   # Yellow
CHOICE_TEXT="printf \e[1;32m%s\e[0m\n" # Green
DEFAULTCOS_DN="cn=default,cn=cos,cn=zimbra"
DEFAULTEXTERNALCOS_DN="cn=defaultExternal,cn=cos,cn=zimbra"
SERVER_HOSTNAME=$zimbra_server_hostname
SESSION=$(date +"%d_%b_%Y-%H-%M")
SESSION_LOG="registro-$SESSION.log"

# CONFIRM IF IT'S BEING EXECUTED AS THE ZIMBRA USER
if [ "$(whoami)" != "zimbra" ]; then
    $ERROR_TEXT "This command must be executed as Zimbra."
    exit 1
fi

# NECESSARY FILES FOR EXECUTION
declare -a FILES_IMPORT=('ACCOUNTS.ldif' 'COS.ldif', 'ALIASES.ldif', 'LISTS.ldif');

for i in "${FILES_IMPORT[@]}"; do
    if [ ! -r $i ]; then
        $ERROR_TEXT  "ERROR: File $i not found or does not have read permission."
        exit 1
    else
        $INFO_TEXT "OK: File $i found"
    fi
done

# VERIFYING IF THE HOSTNAME IN THE ENTRIES MATCHES THE SERVER HOSTNAME
LDIF_HOSTNAME=$(grep zimbraMailHost ACCOUNTS.ldif | uniq | awk '{print $2}')
if [ "$SERVER_HOSTNAME" != "$LDIF_HOSTNAME" ]; then
    $ERROR_TEXT "ERROR: The server hostname does not match the hostname in the import files"
    $INFO_TEXT "Server hostname: $SERVER_HOSTNAME"
    $INFO_TEXT "Hostname in import files: $LDIF_HOSTNAME"
    exit 1
fi

# NECESSARY COMMANDS FOR EXECUTION
declare -a COMMANDS=('ldapsearch' 'zmhostname' 'zmshutil' 'zmmailbox');

for i in "${COMMANDS[@]}"; do
    type $i >/dev/null 2>/dev/null
    if [ $? != 0 ]; then
        $ERROR_TEXT "ERROR: Command $i not found, aborting execution."
        exit 1
    fi
done

clear
cat banner_simples.txt # Display Banner
echo ""
echo ""

# STARTING IMPORT ROUTINES
$INFO_TEXT "This version DOES NOT create or import domains, only continue if you have already created the domains for the environment"
$INFO_TEXT "Import started at: $SESSION" &> $SESSION_LOG
$NORMAL_TEXT "Session log: $SESSION_LOG"
ZIMBRAADMIN_DN=$(ldapsearch -x -H ldap://$zimbra_server_hostname -D $zimbra_ldap_userdn -w $zimbra_ldap_password -b '' -LLL uid=admin dn | awk '{print $2}') &>> $SESSION_LOG # GET ADMIN DN

# INTERACTIVITY: execution of import
test_exec() {
    read -p "Do you want to start the import of COS, ACCOUNTS, ALTERNATIVE NAMES, and DISTRIBUTION LISTS (yes/no)?" choice
    case "$choice" in
        y|Y|yes|s|S|sim ) $NORMAL_TEXT "Starting Z2Z";;
        n|N|no|nao ) exit 0;;
        * ) test_exec ;;
    esac
}

test_exec # Execute test_exec function

# INTERACTIVITY: import the admin user
test_importadmin() {
    echo ""
    read -p "Do you want to import the ADMIN user (yes/no)?" choice
    case "$choice" in
        y|Y|yes|s|S|sim )
            $NORMAL_TEXT "Removing ADMIN: $ZIMBRAADMIN_DN"
            ldapdelete -r -x -H ldap://$zimbra_server_hostname -D $zimbra_ldap_userdn -c -w $zimbra_ldap_password $ZIMBRAADMIN_DN &>> $SESSION_LOG
            ;;
        n|N|no|nao ) $CHOICE_TEXT "The admin user will not be imported. Use the password of the NEW installation";;
        * ) test_importadmin ;;
    esac
}

test_importadmin # Execute test_importadmin function

# START IMPORT OF COS, ACCOUNTS, ALTERNATIVE NAMES, AND DISTRIBUTION LISTS
## REMOVE DEFAULT ZIMBRA COS: DEFAULT AND DEFAULTEXTERNAL
$INFO_TEXT "Removing default COS: Default and DefaultExternal"
ldapdelete -r -x -H ldap://$zimbra_server_hostname -D $zimbra_ldap_userdn -c -w $zimbra_ldap_password $DEFAULTCOS_DN &>> $SESSION_LOG
ldapdelete -r -x -H ldap://$zimbra_server_hostname -D $zimbra_ldap_userdn -c -w $zimbra_ldap_password $DEFAULTEXTERNALCOS_DN &>> $SESSION_LOG

## IMPORT COS, ACCOUNTS, ALTERNATIVE NAMES, AND DISTRIBUTION LISTS
$INFO_TEXT "Importing COS"
ldapadd -c -x -H ldap://$zimbra_server_hostname -D $zimbra_ldap_userdn -w $zimbra_ldap_password -f COS.ldif &>> $SESSION_LOG
$INFO_TEXT "Importing accounts"
ldapadd -c -x -H ldap://$zimbra_server_hostname -D $zimbra_ldap_userdn -w $zimbra_ldap_password -f ACCOUNTS.ldif &>> $SESSION_LOG
$INFO_TEXT "Importing alternative names"
ldapadd -c -x -H ldap://$zimbra_server_hostname -D $zimbra_ldap_userdn -w $zimbra_ldap_password -f ALIASES.ldif &>> $SESSION_LOG
$INFO_TEXT "Importing distribution lists"
ldapadd -c -x -H ldap://$zimbra_server_hostname -D $zimbra_ldap_userdn -w $zimbra_ldap_password -f LISTS.ldif &>> $SESSION_LOG

#
