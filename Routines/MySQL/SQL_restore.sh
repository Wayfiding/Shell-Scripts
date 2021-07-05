#!/bin/bash

# Script version 2.0
# Change Log:
# -Added a function Usage
# -Added a parsing Command Line Options
# -Added Verbosity function
# -Added SSH
# -Added Local access
# -Fixed Bugs with Paramaters and arguments
# -Alpha loading bar implmented
# -Testing Scripts on Windows Side

# The Goals
# Drop a Database 'Example';
# Create Database 'Exemple';
# Restorate the Database;
# This scripts was properly create to access any server with ssh;

# First identify if you are root

if [[ "${UID}" -ne 0 ]]; then
  echo "You are not root, this script need to be executed by root"
  exit 1
fi

# Usage Function
usage() {
  echo
  echo
  echo "Usage: ${0} [-sv [HOST_NAME] [HOST_ADDRESS] [MYSQL_USER_NAME] [MYSQL_PASSWORD] [DATABASE_NAME]]"
  echo 'Drop a database and recreate it with the same name and do a dump.'
  echo ' -s   Enable ssh'
  echo ' -v   Verbose mode'
  exit 1
}

# Log Message Function

log() {

  local MESSAGE="${@}"

  if [[ "${VERBOSE}" = 'true' ]]; then
    echo "${MESSAGE}"

    if [[ -n "$1" ]]; then
      local input="$1"
    else
      while read input; do
        echo -e $input
      done

    fi

  fi

}

sql() {
  mysql "${@}"
}
secure() {

  if [[ "${s_access}" = 'true' ]]; then
    ssh $HOST_NAME@$HOST_ADDRESS "${@}"

  #echo 'Acessing the Database without SSH'
  else
    
    eval "${@}"
    
  fi

}

# Parse the Options
while getopts vs OPTION; do
  case ${OPTION} in
  v)
    VERBOSE='true'
    log 'Verbose Mode On'
    ;;
  s)
    s_access='true'
    echo 'SSH enabled'
    ;;
  ?)
    usage
    ;;
  esac
done

# Remove the options while leaving the arguments.
shift "$((OPTIND - 1))"

# If the user doesn't give a argument them give a usage.
if [[ "${#}" -lt 1 ]]; then
  usage
fi
HOST_NAME=${1}
HOST_ADDRESS=${2}
MYSQL_USER_NAME=${3}
MYSQL_PASSWORD=${4}
DATABASE_NAME=${5}
# Host HOST_ADDRESS

echo "Checking host address. "
ping -c4 ${HOST_ADDRESS} |& log

if [[ "${PIPESTATUS[0]} " -eq 0 || "${?}" -eq 0 ]]; then
  echo
  echo "The server exist and is online"
  echo
else
  echo
  echo "Could not access the Database."
  log "The Address ${HOST_ADDRESS} doesn't exist or it's offline, or ${HOST_NAME} doesn't exist"
  usage
  exit 1
fi

#Checking the Database:

if [[ -n "${DATABASE_NAME}" && -n "${MYSQL_USER_NAME}" ]]; then
  echo
  echo "Checking the SQL Database access with ${MYSQL_USER_NAME}" >&2
  secure "mysql -u ${3} -p${4} -vvv -e 'quit' " |& log 
  if [[ "${PIPESTATUS[0]} " -eq 0 ]]; then
    echo
    echo "Accessing granted with success"
    echo
  else
    echo
    echo "Problem found with Mysql User Name and Database."
    echo "Check if you are not trying to access a remote server"
    usage
    exit 1
  fi
else
  log "Database Name or MySQL Username not supplied"
  usage
  exit 1

fi

#Acessing the Database and Checking Database:

echo 'Checking the selected Database.'
secure "mysql -u $3 -p$4 -vvv  -e 'use $5'" |& log

if [[ "${PIPESTATUS[0]} " -eq 0 ]]; then
  echo "Waiting a moment!"
  sleep 2
  echo
  echo "Requesting access again"
  echo
  secure "mysql -u ${3} -p${4} -vvv -e 'drop database "${5}"'; 
mysql -u  ${3} -p${4} -vvv -e 'create database "${5}"' " |& log

else
  echo 'Database was not found.'
  sleep 2
  read -p 'Do you want to create the Database '${5}'? (yes/no) ' CREATE_DATA
  if [[ "${CREATE_DATA}" = 'yes' ]]; then
    secure "mysql -u ${3} -p${4} '-e create database ${5}' -vvv" |& log

    if [[ "${PIPESTATUS[0]}" -eq 0 ]]; then
      echo
      echo 'Database was created.'
    else
      echo
      echo "Database wasn't created."
      echo
      usage
      exit 1
    fi
  else
    echo
    echo "Database wasn't created by the user choice."
    exit 1
  fi
fi

if [[ "${?}" -eq 0 ]]; then
  # This still a alpha loading bar
  sleep 2 &
  PID=$! #simulate a long process
  echo
  echo
  echo "Process loading! "
  printf "["
  # While process is running...
  while kill -0 $PID 2>/dev/null; do
    printf "▓"
    sleep 0.02
  done

  printf "]"
  echo
  echo
  echo

  echo 'Process realized with success!'
else
  echo
  echo 'Error check the arguments.'
  exit 1
fi

echo
echo 'Restorating the database:'
read -p 'Please provide the path sql data to restorate: ' BACKUP_PATH
# Realizing a Restorate
echo "Checking access again"
secure "mysql -u ${3} -p${4} ${5} -vvv <  ${BACKUP_PATH}" |& log | tee /home/dump.log

# This still a alpha loading bar
sleep 5 &
PID=$! #simulate a long process
echo $!
echo
echo "THIS MAY TAKE A WHILE, PLEASE BE PATIENT WHILE "${0}" IS RUNNING..."
printf "["
# While process is running...
while kill -0 $PID 2>/dev/null; do
  printf "▓"
  sleep 0.05
done

printf "] done!"
echo
echo
echo

echo 'Process realized with success!'

exit 0


