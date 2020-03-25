#!/bin/bash
SNAME="Backup and restore MongoDB database from docker container"
VERSION="0.0.1"
BACKUP_NAME=$(date +\%Y.\%m.\%d.\%H\%M\%S)
BACKUP_PATH=""
ARCHIVE_NAME="$BACKUP_PATH/$BACKUP_NAME.archive"
CONTAINER="nerv_mongo"
URI="mongodb://$DBLOGIN:$DBPASSWORD@localhost:$DBPORT/?authSource=admin"
DBPORT="27017"
CFG="config.file"

DBLOGIN=""
DBPASSWORD=""
re='^[0-9]+$'


read_cfg() {
  while read LINE
    do echo LINE
  done < CFG  
}

auth() {
  # Enter login
  read -p "Login: " DBLOGIN
  # Enter password
  read -s -p "Password: " DBPASSWORD
  echo ""
}

print_help() {
  echo Usage: ./dbbackup.sh [OPTION]
  echo "$SNAME"
  echo -e "\nMandatory arguments to long options are mandatory for short options too."
  echo -e "  -h   display this help and exit" 
  echo -e "  -b   backup database"
  echo -e "  -r   restore database"
  echo -e "  -v   list all backup files"
  echo -e "  -f   path to backup files directory"
  echo -e "  -d   set path to backup files directory"
  echo -e "  -p   container MongoDB database destination port"
  echo -e "    --version   output version information and exit"
  echo -e "\nSome examples:"
  echo -e "  ./dbbackup.sh -b -p 27017 "
}

set_port() {
    if [ "$2" == "-p" ] && [["$3" =~ $re ]]; then
      if [ "$3" -gt "0"] && ["$3" -lt "65536"]; then
        DBPORT="$3"
      fi;  
    fi;
}

dbbackup () {
   docker exec $CONTAINER sh -c "exec mongodump --uri=\"$URI\" --gzip --archive" > $ARCHIVE_NAME
}

dbrestore () {
  shopt -s nullglob
  declare -a BACKUP_FILES=("${BACKUP_PATH}"/*)
  i=1;
  for f in ${BACKUP_FILES[@]}; do
    echo -e $i '\t' $f
    let "i++"
  done  
  read -p "Select backup what you want to restore: " REST_FILE_NUM
  if ( (($REST_FILE_NUM > 0)) && (($REST_FILE_NUM < ${#BACKUP_FILES[@]} )) ); then
    read -p "You select ${BACKUP_FILES[$REST_FILE_NUM]} file (Y/n): " YN
    if [ "$YN" == "y" ] || [ "$YN" == "Y"]; then
      docker cp ${BACKUP_FILES[$REST_FILE_NUM]} $CONTAINER:/home/backup.archive
      # docker exec $CONTAINER sh -c 'exec mongorestore --uri=\"mongodb://$DBLOGIN:$DBPASSWORD@localhost:$DBPORT/?authSource=admin\" --gzip --archive=/home/backup.archive'
      docker exec $CONTAINER sh -c 'exec mongorestore --uri=$URI --gzip --archive=/home/backup.archive'
    fi;
  else
    echo Number selected file is wrong!  
  fi;
}

OPERATION=10

if [ "$1" == "" ]; then
  echo "Select operation with database:"
  read -p "0 - backup or 1 - restore: " OPERATION
else
  if [ "$1" == "-b" ] || [ "$OPERATION" -eq "0" ]; then
    auth
    set_port
    dbbackup
  elif [ "$1" == "-r" ] || [ "$OPERATION" -eq "1" ]; then
    auth
    set_port
    dbrestore
  elif [ "$1" == "-v" ]; then
    print_backups
  elif [ "$1" == "-h" ]; then
    print_help
  elif [ "$1" == "-f" ]; then
    print_files
  elif [ "$1" == "-p" ]; then
    print_help
  elif [ "$1" == "--version" ]; then
    echo "$SNAME"
    echo "Version: $VERSION"
  fi;
fi;
#if [ "$OPERATION" -eq "0" ]; then
#  dbbackup
#elif [ "$OPERATION" -eq "1" ]; then
#  dbrestore
#fi;  
