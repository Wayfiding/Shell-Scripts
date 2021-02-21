#!/bin/bash

# Script version 1.0 Alpha

# The Goals
# 1 - drop database exemplo; 2 - create database exemplo; 
#3 - mysql -uroot -p exemplo < exemplo --verbose


# First identify if you are root

if [[ "${UID}" -ne 0 ]]
then
  echo "You are not root, this script need to be executed by root"
  exit 1
fi
# --> Interacting with User <-- INPUT STYLE

# Ask the Host Address 
#read -p 'Enter the Host Address: ' HOST_ADDRESS

# Ask the Mysql User name
#read -p 'Enter the Mysql Username: ' MYSQL_USER_NAME

#Ask the Mysql MYSQL_PASSWORD
#read -p 'Enter the Mysql Password: ' MYSQL_PASSWORD

#Ask the Database to erase and dump
#read -p 'Enter the database name to drop and recreate: ' DATABASE_NAME

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
    echo "Usage: ${0} [HOST_ADDRESS] [MYSQL_USER_NAME] [MYSQL_PASSWORD] [DATABASE_NAME] -OPTIONS [COMMENT] ...."
    echo 'Drop a database and recreate it with the same name and do a dump.'
    echo
    echo
    exit 1
fi

HOST_ADDRESS="${1}"
MYSQL_USER_NAME="${2}"
MYSQL_PASSWORD="${3}"
DATABASE_NAME="${4}"
#Checking the  arguments
# Host HOST_ADDRESS
ping  -c4 "${1}" >&2
if [[ "${?}" -eq 0 ]]
then
  echo
  echo "The server exist and is online" >&2
  echo
fi

#Show the MYSQL_USER_NAME and database

echo
echo "Acessing the ${4} with ${1}"
echo
#Acessing the database 
ssh vagrant@${1}  'mysql -u '${2}' -p'${3}'  -e "create database teste" -v; 

mysql -u  '${2}' -p'${3}'  -e "drop database teste" -v'

exit ${EXIT_STATUS}

