#!/bin/bash
###   Z2Z - Maintained by BKTECH <http://www.bktech.com.br>                     ###
###   Copyright (C) 2016  Fabio Soares Schmidt <fabio@respirandolinux.com.br>     ###
###   FOR INFORMATION ABOUT THE TOOL, PLEASE READ THE README AND INSTALL FILES ###

###   VERSION 1.0.2

# LOAD FUNCTIONS USED BY THE SCRIPT
. func.sh
 
# START Z2Z
clear
cat banner.txt
echo ""
#

# CONFIRM IF IT'S BEING EXECUTED WITH THE ZIMBRA USER
Run_as_Zimbra
separator_char

# CONFIRM IF THE USER WANTS TO CONTINUE WITH THE EXECUTION
test_exec
separator_char

# TESTS FOR UTILITY EXECUTION

# NECESSARY COMMANDS
declare -a COMANDOS=('ldapsearch' 'zmmailbox' 'zmshutil' 'zmprov');

Check_Command
separator_char

# VALIDATE SINGLE SERVER OR SINGLE MAILBOX ENVIRONMENT
Check_Maibox
separator_char

# SETTING ZIMBRA ENVIRONMENT VARIABLES
source ~/bin/zmshutil
zmsetvars


# SETTING SERVER NAME WITH ENVIRONMENT VARIABLE
ZIMBRA_HOSTNAME=$zimbra_server_hostname
# SETTING USER TO BIND TO ZIMBRA LDAP WITH ENVIRONMENT VARIABLE
ZIMBRA_BINDDN=$zimbra_ldap_userdn


#### DIRECTORIES

DIRETORIO=$WORKDIR
Check_Directory
separator_char
DIRETORIO="`pwd`/skell"
Check_Directory
separator_char
DESTINO=$WORKDIR
mkdir $WORKDIR/alias # Create temporary directory to export aliases

# CAN CONTINUE


 # EXPORTING CLASS OF SERVICE
 $NORMAL_TEXT "EXPORTING CLASS OF SERVICE"
 separator_char
 ldapsearch -x -H ldap://$ZIMBRA_HOSTNAME -D $ZIMBRA_BINDDN -w $zimbra_ldap_password -b '' -LLL "(objectclass=zimbraCOS)" > $DESTINO/COS.ldif
 $INFO_TEXT "CLASS OF SERVICE EXPORTED SUCCESSFULLY: $DESTINO/COS.ldif"
 separator_char
 
 # EXPORTING ACCOUNTS - DISREGARDING ZIMBRA SERVICE ACCOUNTS (zimbraIsSystemResource=TRUE)
 $NORMAL_TEXT  "EXPORTING ACCOUNTS"
 separator_char
 ldapsearch -x -H ldap://$ZIMBRA_HOSTNAME -D $ZIMBRA_BINDDN -w $zimbra_ldap_password -b '' -LLL '(&(!(zimbraIsSystemResource=TRUE))(objectClass=zimbraAccount))' > $DESTINO/CONTAS.ldif
 $INFO_TEXT "ACCOUNTS EXPORTED SUCCESSFULLY: $DESTINO/CONTAS.ldif"
 separator_char
 
 # EXPORTING ALTERNATE NAMES
 $NORMAL_TEXT  "EXPORTING ALTERNATE NAMES"
 separator_char

 ldapsearch -x -H ldap://$ZIMBRA_HOSTNAME -D $ZIMBRA_BINDDN -w $zimbra_ldap_password  -b '' -LLL '(&(!(uid=root))(!(uid=postmaster))(objectclass=zimbraAlias))' uid | grep ^uid | awk '{print $2}' > $DESTINO/lista_contas.ldif

 for MAIL in $(cat $DESTINO/lista_contas.ldif);
 	do 
	      ldapsearch -x -H ldap://$ZIMBRA_HOSTNAME -D $ZIMBRA_BINDDN -w $zimbra_ldap_password -b '' -LLL "(&(uid=$MAIL)(objectclass=zimbraAlias))" > $DESTINO/alias/$MAIL.ldif
		  	cat $DESTINO/alias/*.ldif > $DESTINO/APELIDOS.ldif
			done 

   $INFO_TEXT "ALTERNATE NAMES EXPORTED SUCCESSFULLY: $DESTINO/APELIDOS.ldif"
   separator_char

# EXPORTING DISTRIBUTION LISTS
   $NORMAL_TEXT  "EXPORTING DISTRIBUTION LISTS"
   separator_char
ldapsearch -x -H ldap://$ZIMBRA_HOSTNAME -D $ZIMBRA_BINDDN -w $zimbra_ldap_password -b '' -LLL "(|(objectclass=zimbraGroup)(objectclass=zimbraDistributionList))" > $DESTINO/LISTAS.ldif
   $INFO_TEXT "DISTRIBUTION LISTS EXPORTED SUCCESSFULLY: $DESTINO/LISTAS.ldif"
   separator_char

# CLEAR TEMPORARY FILES CREATED IN THE EXPORT DIRECTORY
Clear_Workdir

# COPY IMPORT SCRIPT AND SIMPLE BANNER
cp skell/importar_ldap.sh export/
cp skell/banner_simples.txt export/
chmod +x export/importar_ldap.sh

# INTERACTIVITY: CHANGE SERVER HOSTNAME
Replace_Hostname
separator_char

# INTERACTIVITY: EXPORT MAILBOXES (RELATIONSHIP)

export_Mailboxes
separator_char

Export_Dest

# EXPORT MAILBOX
execute_Export_Full
separator_char

# EXPORT TRASH
execute_Export_Trash
separator_char

# EXPORT JUNK
execute_Export_Junk
separator_char

# END
