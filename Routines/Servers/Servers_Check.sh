#!/bin/bash
#
# This scripts check the status of every servers on a network

SERVER_FILE='/vagrant/Class\ 7/servers'
# Check Usage Statements

usage () {

echo "Usage: ${0} [-fnsv SERVER [SERVER] ...] ." >&2
echo 'This scripts check the status of a list of servers.' >&2
echo  'SERVER Specify a server to be cheked if the file servers does not exists or override the default file.' >&2
echo  ' -f Override the default list file of servers, this need to be used with giving name of the servers.' >&2
echo  ' -n Command will be displayed like a DRY RUN instead of be executed.' >&2
echo  ' -s Run the command with sud privileges on the remote servers.' >&2
echo  ' -v Enable verbose mode, which display the name of the server for which te command is being executed on.' >&2

exit 1
}

# Parse the options
while getopts f:nsv OPTION
do
  case ${OPTION} in
  f) FILE='true' echo 'Attach the file servers.' ;;
  n) DRY_RUN='true' ;;
  s) SUPER_USER='true' ;;
  v) VERBOSE='true' echo 'Enabling Verbose mode.' ;;
  ?)
    usage
    ;;
    esac
done


# Remove the options while leaving the arguments.
shift "$(( OPTIND - 1 ))"

#Check if the file exists

SERVER_LIST=/vagrant/Class\ 7/servers
if [[ "${FILE}" = 'true' ]]
then
echo 'Server name being attached.'
echo "${@}" >> /vagrant/Class\ 7/servers >&2
if [[ "${?}" -ne 0 ]]
then
  echo "The ${@} could not be attached to the servers files." >&2
  exit 1
fi
exit 0
fi

if [[ ! -e "${SERVER_FILE}" ]]
then
echo 'Cannot open ${SERVER_FILE}.' >&2
  usage
  exit 1
fi




for SERVER in $(cat ${SERVER_FILE})
do
  echo "Pinging ${SERVER}"
  ping -c 3 ${SERVER} &> /dev/null
  if [[ "${?}" -ne 0 ]]
  then
  echo "${SERVER} down"
  else
  echo "${SERVER} up"
  fi
done

exit 0
