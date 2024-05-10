#!/bin/bash
#Changelog:
# 15/Nov/2016: Creation of the func.sh file (Fabio Soares Schmidt)

#FUNCTIONS AND VARIABLES FOR THE UTILITY
NORMAL_TEXT="printf \e[1;34m%-6s\e[m\n" #Blue
ERROR_TEXT="printf \e[1;31m%s\e[0m\n" #Red
INFO_TEXT="printf \e[1;33m%s\e[0m\n" #Yellow
CHOICE_TEXT="printf \e[1;32m%s\e[0m\n" #Green
MAILBOX_LIST="$(zmprov -l gaa | grep -v -E 'admin|virus-|ham.|spam.|galsync')" #ALL ZIMBRA ACCOUNTS EXCEPT SYSTEM ACCOUNTS
WORKDIR="$(pwd)/export"
SINGLE_MAILBOX=1
MAILBOX_SERVERS="$(zmprov gas mailbox | wc -l)"

##

separator_char()
{
echo ++++++++++++++++++++++++++++++++++++++++
}
##

test_exec()
{
read -p "Continue (yes/no)?" choice
    case "$choice" in
     y|Y|yes|s|S|sim ) $NORMAL_TEXT "Starting utility";;
     n|N|no|nao ) exit 0;;
     * ) test_exec ;;
esac
}

##

Check_Directory()
{

if [ ! -d "$DIRECTORY" ]; then
	 ${ERROR_TEXT} "ERROR: The directory $DIRECTORY does not exist, aborting execution."
	 exit 1
 else
	${INFO_TEXT} "OK: Directory $DIRECTORY exists."

fi
}

##

Check_Command()
{

for i in "${COMMANDS[@]}"
    do
    # do whatever on $i
    type $i >/dev/null 2>/dev/null
      if [ $? == 0 ]; then
   ${INFO_TEXT} "OK: command $i exists."
		separator_char
       else
      ${ERROR_TEXT} "ERROR: The command $i was not found, aborting execution."
    	exit 1
    fi
done


}

##

Check_Mailbox()
{

if (($MAILBOX_SERVERS > 1)); then
	$ERROR_TEXT "CAUTION: The current version was developed for Single Server environments or with only one mailbox server."
	$ERROR_TEXT "CAUTION: For environments with more than one Mailbox server, it will be necessary to modify the exported files if you wish to rename the servers."
else
	$NORMAL_TEXT "OK: Environment has only one Mailbox server"
fi
}

##

Enter_New_Hostname()
{

read -p "Enter the new Zimbra server hostname: " userInput


if [[ -z "$userInput" ]]; then
      printf '%s\n' ""
      Enter_New_Hostname
     else
       TEST_FQDN="$(echo $userInput | awk -F. '{print NF}')"
	        if [ ! "$TEST_FQDN" -ge 2 ]; then
		       ${ERROR_TEXT} "ERROR: The provided hostname is not a valid FQDN"
		       Enter_New_Hostname
			fi
	  OLD_HOSTNAME="$zimbra_server_hostname"
	  NEW_HOSTNAME="$userInput"
	  $CHOICE_TEXT "Hostname provided: $NEW_HOSTNAME"
fi
}

##

Run_as_Zimbra()
{

if [ "$(whoami)" == "zimbra" ]; then
    ${INFO_TEXT} "OK: Running as Zimbra."
   else
    ${ERROR_TEXT} "ERROR: This command must be run as Zimbra."
    exit 1
fi
}

##

Replace_Hostname()
{
	#$INFO_TEXT "Modify hostname"
read -p "The Zimbra server hostname will be changed (yes/no)? " choice
   case "$choice" in
   y|Y|yes|s|S|sim )
    ${CHOICE_TEXT} "The Zimbra server hostname will be changed. "
	Enter_New_Hostname
	Execute_Replace_Hostname
	;;
   n|N|no|nao ) ${CHOICE_TEXT} "The server hostname will be kept.";;
   * ) Replace_Hostname ;;
esac
}

##

Execute_Replace_Hostname()
{
sed "s/$OLD_HOSTNAME/$NEW_HOSTNAME/g" -i "$DESTINATION/ACCOUNTS.ldif"
sed "s/$OLD_HOSTNAME/$NEW_HOSTNAME/g" -i "$DESTINATION/LISTS.ldif"
}

##

export_Mailboxes()
{
read -p "Do you want to export mailboxes (yes/no)?" choice
    case "$choice" in
    y|Y|yes|s|S|sim ) ${CHOICE_TEXT} "The RELATIONSHIP for the FULL export of all system accounts will be created.";;
    n|N|no|nao ) ${CHOICE_TEXT} "Mailboxes will not be exported. Execution aborted by the user." ; exit 0 ;;
    * ) export_Mailboxes ;;
esac
}

##

export_Destination()
{
read -p "Enter the directory path for export: " userInput
if [[ -z "$userInput" ]]; then
    ${ERROR_TEXT} "No directory provided"
    export_Destination
       else
	EXPORT_PATH="$userInput"
    ${CHOICE_TEXT} "Directory provided:" "$userInput"
fi
}

##

execute_Export_Full()
{
		 ${NORMAL_TEXT} "INBOX: Creating file with related accounts for full export:"
		 ${INFO_TEXT} "$WORKDIR/script_export_FULL.sh"
         for mailbox in $MAILBOX_LIST; do
		 echo "zmmailbox -z -m $mailbox -t 0 getRestURL \"//?fmt=tgz\" > $EXPORT_PATH/$mailbox.tgz" >> "$WORKDIR/script_export_FULL.sh" #command for full export
		 chmod +x "$WORKDIR/script_export_FULL.sh"
		 echo "zmmailbox -z -m $mailbox -t 0 postRestURL -u https://localhost:7071 \"//?fmt=tgz&resolve=skip\" $EXPORT_PATH/$mailbox.tgz" >> "$WORKDIR/script_import_FULL.sh" #command for full import
		 chmod +x "$WORKDIR/script_import_FULL.sh"
done
}

##

execute_Export_Trash()
{
		 ${NORMAL_TEXT} "TRASH: Creating file with related accounts for export:"
         ${INFO_TEXT} "$WORKDIR/script_export_TRASH.sh"
        for i in $MAILBOX_LIST; do
		echo "zmmailbox -z -m $i -t 0 gru \"//Trash?fmt=tgz\" > $EXPORT_PATH/$i-Trash.tgz" >> "$WORKDIR/script_export_TRASH.sh"
		chmod +x "$WORKDIR/script_export_TRASH.sh"
		echo "zmmailbox -z -m $i -t 0 postRestURL \"//?fmt=tgz&resolve=skip\" $EXPORT_PATH/$i-Trash.tgz" >> "$WORKDIR/script_import_TRASH.sh"
		chmod +x "$WORKDIR/script_import_TRASH.sh"
done
}

##

execute_Export_Junk()
{

	     ${NORMAL_TEXT} "SPAM: Creating file with related accounts for export:"
         ${INFO_TEXT} "$WORKDIR/script_export_JUNK.sh"
		 for i in $MAILBOX_LIST; do
		 echo "zmmailbox -z -m $i -t 0 gru \"//Junk?fmt=tgz\" > $EXPORT_PATH/$i-Junk.tgz" >> "$WORKDIR/script_export_JUNK.sh"
		 chmod +x "$WORKDIR/script_export_JUNK.sh"
		 echo "zmmailbox -z -m $i -t 0 postRestURL \"//?fmt=tgz&resolve=skip\" $EXPORT_PATH/$i-Junk.tgz" >> "$WORKDIR/script_import_TRASH.sh"
		 chmod +x "$WORKDIR/script_import_TRASH.sh"
done

}

##

Clear_Workdir()
{
rm -f "$WORKDIR/account_list.ldif"
rm -fr "$WORKDIR/alias"
}

##
