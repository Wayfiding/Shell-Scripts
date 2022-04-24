#!/bin/bash

# This scripts is for disabling, delete or achieve an account users from the system.

ARCHIVE_DIR='/archive'

# Run as root

if [[ "${UID}" -ne 0 ]]
then
  echo 'Execute this script as root, ortherwise it will not work.' >&2
  exit 1
fi

# Check Usage statements

usage () {
echo ' Usage: ${0}[-dra USER [USER]...] .'
echo 'This scripts work with this options' >&2
echo 'Delete an account, Remove the home directory associated with the account(s).' >&2
echo ' user  USER ACCOUNT Specify the user account.' >&2
echo ' -d  Deletes accounts instead of disabling them.' >&2
echo ' -r  Removes the home directory associated with the account(s).' >&2
echo ' -a  Create an archive of the home directory associated with the accounts(s) and stores the archive in the /archives' >&2
echo ' -v  Verbose mode'
exit 1

}

# Parse the options

while getopts vdra OPTION
do
  case ${OPTION} in
  v) VERBOSE='true' echo 'Verbose mode on'    ;;
  d) DELETE_USER='true' ;;
  r) REMOVE_USER='-r'  ;;
  a) ARCHIVE='true' ;;
  ?)
    usage
    ;;
  esac
done


# Remove the options while leaving the arguments.
shift "$(( OPTIND - 1 ))"


# If the user doesn't give a argument them give a usage.
if  [[ "${#}" -lt 1 ]]
then
  usage
fi

for USER_NAME in "${@}"
do
  #Check if the username is a normal accounts
  USER_ID=$(id -u ${USER_NAME})
  USERNAME=$(id -un ${USER_NAME})
  if [[ "${USER_ID}" -lt 1000 ]]
  then
    echo 'This is system account and should be modified by system administrators.' >&2
    exit 1
  fi

  # Check ARCHIVE options
  if [[ "${ARCHIVE}" = 'true' ]]
  then
    # Check if the ARCHIVE_DIR exists.
    echo 'Verifying if the direcotry exist.'
    if [[ ! -d "${ARCHIVE_DIR}" ]]
    then
      mkdir -p ${ARCHIVE_DIR}
      if [[ "${?}" -ne 0 ]]
      then
        echo 'The ${ARCHIVE_DIR} could not be created.' >&2
        exit 1
      fi
    fi
    # Setting Archive FILE
    HOME_DIR=/home/${USERNAME}
    ARCHIVE_FILE=${ARCHIVE_DIR}/${USERNAME}.tgz
    if [[ -d "${HOME_DIR}" ]]
    then
      tar -zcf ${ARCHIVE_FILE} ${HOME_DIR} &>/dev/null
      echo 'The user file was archive in ${ARCHIVE_DIR}.'
    else
      if [[ "${?}" -ne 0 ]]
      then
      echo 'The user file could not be created' >&2
      exit 1
    fi
  fi
fi

  # Check delete user option
  if [[ "${DELETE_USER}" = 'true' ]]
  then
    userdel ${REMOVE_USER} ${USER_NAME}
    if [[ "${?}" -ne 0 ]]
    then
      echo 'This accout could not be deleted.' >&2
      exit 1
    fi
    echo 'The account was deleted.'

  else
    chage -E 0 ${USERNAME}
    if [[ "${?}" -ne 0 ]]
    then
      echo 'This account could not be disabled' >&2
      exit 1
    fi
    echo 'The account was disabled.'
  fi
done

exit 0
