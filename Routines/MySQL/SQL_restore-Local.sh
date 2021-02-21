#!/bin/bash

# Script version 1.5 

# The Goals
# Drop a Database 'Example';
# Create Database 'Exemple'; 
# Restorate the Database;
# This scripts was properly create to access for localhost;
# First identify if you are root

if [[ "${UID}" -ne 0 ]]
then
  echo "You are not root, this script need to be executed by root"
  exit 1
fi

# Checking the number os parameters
NUMBER_OF_PARAMETERS="${#}"
echo
echo "You supplied ${NUMBER_OF_PARAMETERS} argument(s) on the command line."
echo
# Make sure the user at least supply one argument.
if [[ "${NUMBER_OF_PARAMETERS}" -lt 1 ]]
then
    echo
    echo
    echo "Usage: ${0} [HOST_NAME] [HOST_ADDRESS] [MYSQL_USER_NAME] [MYSQL_PASSWORD] [DATABASE_NAME] -OPTIONS [COMMENT] ...."
    echo 'Drop a database and recreate it with the same name and do a dump.'
    echo
    echo
    exit 1
fi
HOST_NAME="${1}"
HOST_ADDRESS="${2}"
MYSQL_USER_NAME="${3}"
MYSQL_PASSWORD="${4}"
DATABASE_NAME="${5}"
#Checking the  arguments
# Host HOST_ADDRESS
echo "Checking host address. "
ping -c4 ${2} &> /dev/null

if [[ "${?}" -eq 0 ]] 
then
  echo
  echo "The server exist and is online" 
  echo
else
  echo
  echo "The Address does not exist or it's offline"
  echo
  exit 1
fi

#Checking the Database:
echo "Checking the Database ${5} with ${3}" >&2
echo

#Acessing the database; delete and create:
 mysql -u '${3}' -p'${4}'  -e "use  '${5}'" -v  &> /dev/null
if [[ "${?}" -eq 0 ]]
then 
mysql -u '${3}' -p'${4}'  -e "drop database '${5}'" -v;
mysql -u  '${3}' -p'${4}'  -e "create database '${5}'" -v;
else
  echo 'Database was not found'
  sleep 2
  read -p 'Do you want to create the Database '${5}'? (yes/no) ' CREATE_DATA
  if [[ "${CREATE_DATA}" = 'yes' ]]
  then
  mysql -u '${3}' -p'${4}'  -e "create database '${5}'" -v
  echo 'Database created'
  else
  echo 'Database does not exist.'
  exit 1
  fi
fi

if [[ "${?}" -eq 0 ]]
then
    echo
    echo 'Process realized with success!'
else
    echo 'Error check the arguments.'
    exit 1
fi

echo
echo 'Restorating the database:'
read -p 'Please provide the path sql data to restorate: ' BACKUP_PATH
# Realizing a Restorate
mysql -u '${3}' -p'${4}' '${5}' -v <  '${BACKUP_PATH}' > /home/dump.log
#mysql -u root -p exemplo < exemplo --verbose
echo 'Process realized with success'

exit 0
