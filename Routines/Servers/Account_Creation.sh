#!/bin/bash

#The goal of this script is create a new users on the local system

#This script will prompt to enter the username (login), the person name, and a password.
#After the configuration, the script will display the Username, password and host for the account.


#Fist the script will check if is being executed with superuser privileges.

if [[ "${UID}" -ne 0 ]]
then
  echo "You are not root, this script need to be executed by root"
  exit 1
fi

#Get the User name
read -p 'Enter the username to create: ' USER_NAME


#Get the person name
read -p 'Enter the person name to this account: ' COMMENT


#Get the password
read -p 'Enter the password for this account: ' password

# Create the users
useradd -c "${COMMENT}" -m ${USER_NAME}

#Check if the command succeeded.
if [[ "${?}" -ne 0 ]]
then
  echo ' The username could not be created'
  exit 1
fi

# Set the password for the user.
echo ${password} | passwd --stdin ${USER_NAME}

#Check if the command succeeded.
if [[ "${?}" -eq 1 ]]
then
  echo ' The password could not be set for this account'
  exit 1
fi

#Force Password change on first login.
passwd -e ${USER_NAME}


# Display the username, password and host where the account was created.

echo 'Username:'
echo "${USER_NAME}"
echo
echo 'Password:'
echo  "${password}"
echo
echo 'Host:'
echo "${HOSTNAME}"
