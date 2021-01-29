#!/bin/bash 
ssh vagrant@192.168.33.10 'mysql -u root -p -e "create database teste"; 
 echo ola'
