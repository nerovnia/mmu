#!/bin/bash
##  *****************************************************************
##  Backup / restore script MongoDB database from docker container
##  Copyright (c)  2020 Volodymyr Nerovnia  
##  
##  *****************************************************************
##
##  Arguments set in command line or in configuration file
##

 ##set -x

## Utilites 
SNAME="Backup and restore MongoDB database from docker container"
VERSION="0.1.0"

## Directories and files
BACKUP_NAME=$(date +\%Y.\%m.\%d.\%H\%M\%S)
BACKUP_PATH="./backup"
ARCHIVE_NAME="$BACKUP_PATH/$BACKUP_NAME.archive"
CFG="config.file"

## Docker 
CONTAINER=""

## Database
DBLOGIN=""
DBPASSWORD=""
URI="mongodb://$DBLOGIN:$DBPASSWORD@localhost:$DBPORT/?authSource=admin"
DBPORT="27017"

# Colors
ERR_COLOR='\033[0;31m'
NO_COLOR='\033[0m'

## Test mode
TEST_MODE=1
ERR=1
COUNT_ERR=0

## Regular expressions
re='^[0-9]+$'
backup=1
restore=1
CFG_IS_READ=1

shopt -s nullglob
declare -a BACKUP_FILES=("${BACKUP_PATH}"/*)

check_backup_path () {
  if [ ! -d $BACKUP_PATH ] && [ ! $CFG_IS_READ ]; then
    print_err "Directory $BACKUP_PATH is absend!"
    read -p "Do you want create this directory: " YN
    if [ "$YN" == "y" ] || [ "$YN" == "Y"]; then
      mkdir -p $BACKUP_PATH
    else
      exit 1
    fi;  
  fi;
}

read_cfg () {
  echo "read_cfg"
  CFG_IS_READ=0
  if [ -e $CFG ] && [ -f $CFG ]; then
    . $CFG
    echo "$DBPASSWORD"
    if [ "$DBPASSWORD" == "" ] || [ "$DBLOGIN" == "" ]; then
      print_err "Login or password can't  be empty!"
      exit 1
    fi;
    check_backup_path
    set_port $DBPORT
    set_container $CONTAINER
  else
    print_err "Can't find configuration file!"
    exit 1  
  fi;
}

auth () {
  # Enter login
  read -p "Login: " DBLOGIN
  # Enter password
  read -s -p "Password: " DBPASSWORD
  echo ""
}

print_list_files () {
  i=1;
  for f in ${BACKUP_FILES[@]}; do
    echo -e $i '\t' $f
    let "i++"
  done    
}

print_help () {
  echo Usage: ./dbbackup.sh [OPTION]
  echo "$SNAME"
  echo -e "\nMandatory arguments to long options are mandatory for short options too."
  echo -e "  -p, --port       container MongoDB database destination port"
  echo -e "  -c, --container  docker container name"
  echo -e "  -b, --backup     backup an entire database"
  echo -e "  -r, --restore    restore an entire database"
  echo -e "  -l, --list       list all backup files"
  echo -e "  -d, --directory  set path to backup directory"
  echo -e "  -u, --use-cfg    use configuration file"
  echo -e "  -s, --set-cfg    set path to configuration file"
  echo -e "  -v, --version    output version information and exit"
  echo -e "  -h, --help       display this help and exit" 
  echo -e "\nSome examples:"
  echo -e "  ./dbbackup.sh -b -p 27017"
  echo -e "  ./dbbackup.sh -b -s config.file"
  echo -e "  ./dbbackup.sh -r -p 27017"
  echo -e "  ./dbbackup.sh --version"
}

print_err () {
  echo -e "${ERR_COLOR}Error: $1 ${NO_COLOR}"
}

set_port () {
  if [ -n "$1" ]; then
    if [[ "$1" =~ $re ]]; then
      if [ "$1" -gt "0" ] && [ "$1" -lt "65536" ]; then
        DBPORT="$1"
      else
        print_err "Port is out of the range."
        exit 1  
      fi;
    else
      print_err "Port isn't numeric."
      exit 1
    fi;
  else
    print_err "Param port is present but expect argument."
    exit 1
  fi;    
}

set_container () {
  CONTAINER=`docker ps -a | awk -v CONTAINER="$1" '{if ( $NF == CONTAINER ) print CONTAINER }'`
  if [ "$CONTAINER" != "$1" ]; then
    print_err "Container $1 not found!"
    exit 1
  fi;
}

dbbackup () {
  echo "--"
  echo "CONTAINER: $CONTAINER"
  echo "DBPORT: $DBPORT"
  echo "BACKUP_PATH: $BACKUP_PATH"
  echo "URI: $URI"
  set -x
  docker exec $CONTAINER sh -c "exec mongodump --uri=\"$URI\" --gzip --archive"  > $ARCHIVE_NAME
   #docker exec "$CONTAINER" sh -c "exec mongodump --uri=\"$URI\" --gzip --archive" # > $ARCHIVE_NAME
   #docker exec "$CONTAINER" sh -c "exec mongodump --uri=\"$URI\" --gzip --archive" #> $ARCHIVE_NAME
   echo "--"
}

dbrestore () {
  print_list_files
  read -p "Select backup what you want to restore: " REST_FILE_NUM
  if ( (($REST_FILE_NUM > 0)) && (($REST_FILE_NUM < ${#BACKUP_FILES[@]} )) ); then
    read -p "You select ${BACKUP_FILES[$REST_FILE_NUM]} file (Y/n): " YN
    if [ "$YN" == "y" ] || [ "$YN" == "Y"]; then
      docker cp ${BACKUP_FILES[$REST_FILE_NUM]} $CONTAINER:/home/backup.archive
      # docker exec $CONTAINER sh -c 'exec mongorestore --uri=\"mongodb://$DBLOGIN:$DBPASSWORD@localhost:$DBPORT/?authSource=admin\" --gzip --archive=/home/backup.archive'
      docker exec $CONTAINER sh -c 'exec mongorestore --uri=$URI --gzip --archive=/home/backup.archive'
    fi;
  else
   print_err Number selected file is wrong!  
  fi;
}

set_backup_path() {
  if [ ! -n "$1" ]; then
    BACKUP_PATH="./backups"
  else
    BACKUP_PATH="$1"
  fi;
  check_backup_path
}

if [ -n "$1" ]; then
  while [ "$1" != "" ]; do
      case $1 in
          -p | --port )           
            shift
            set_port $1
          ;;
          -c | --container )           
            shift
            set_container $1
          ;;
          -b | --backup )         
            backup=0
          ;;
          -r | --restore )        
            restore=0
          ;;
          -l | --list )        
            print_list_files
            exit
          ;;
          -d | --directory )
            shift
            set_backup_path $1
          ;;
          -u | --use-cfg )
            read_cfg
          ;;
          -s | --set-cfg )
            shift
            CFG=$1
          ;;
          -v | --version ) 
            echo "$SNAME"       
            echo "Version: $VERSION"
            exit
          ;;
          -h | --help )           
            print_help
            exit
          ;;
          * )
            print_err "$1 not expected argument"
            exit 1
      esac
      shift
  done
  if [ "$CONTAINER" == "" ]; then
    print_err "Container can't be empty."
    exit 1
  fi;
else
  print_err "Can't find any argument!"
  exit 1  
fi;  
if [ $backup -eq $restore ]; then
  if [ $backup -eq 1 ]; then
    print_err "Not select any operation."
    exit 1
  else
    print_err "You can set only one operation (backup | restore)"
    exit 1
  fi;  
else
  if [ ! $CFG_IS_READ ] && ([ "$DBPASSWORD" == "" ] || [ "$DBLOGIN" == "" ]); then
    auth
  fi;
  if [ $backup -eq 0 ]; then
    dbbackup
  else
    dbrestore
  fi;  
fi;
