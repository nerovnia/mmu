# mmu
MongoDB Management Utility


  ## Mandatory arguments to long options are mandatory for short options too.

    -h   display this help and exit 
    -b   backup an entire database
    -r   restore an entire database
    -v   list all backup files
    -f   path to backup files in the backup directory
    -с   configuration file
    -p   container MongoDB database destination port
    -n   docker container name
      --version   output version information and exit
  
  Some examples:

    ./dbbackup.sh -b -c config.file
    ./dbbackup.sh -r -p 27017
    ./dbbackup.sh --version

## Config file options

    BACKUP_PATH - path to backup directory
    DBPORT - MongoDB open port in container
    CONTAINER - conatainer name
    URI - connection string to database