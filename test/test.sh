#!/bin/bash

echo Test help
../dbbackup.sh -h
echo Test backup database
../dbbackup.sh 
echo Test restore database
../dbbackup.sh 
echo Test list all backup files
../dbbackup.sh 
echo Test path to backup files directory
../dbbackup.sh 
echo Test set path to backup files directory
../dbbackup.sh 
echo Test container MongoDB database destination port
../dbbackup.sh 
echo Test --version   output version information and exit
../dbbackup.sh




../dbbackup.sh -h
../dbbackup.sh -b

../dbbackup.sh -b -p 27017
../dbbackup.sh -b -p 27017 -f ~/backup
../dbbackup.sh -b -p 27017 -c config.file

../dbbackup.sh -r -p 27017
../dbbackup.sh -r -p 27017 -f ~/backup
../dbbackup.sh -r -p 27017 -c config.file


    ./dbbackup.sh -b -c config.file
    ./dbbackup.sh -r -p 27017
    ./dbbackup.sh --version
