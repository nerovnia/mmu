# mmu
MongoDB Management Utility


  ## Mandatory arguments to long options are mandatory for short options too.

    -p, --port        container MongoDB database destination port
    -c, --container   docker container name
    -b, --backup      backup an entire database
    -r, --restore     restore an entire database
    -l, --list        list all backup files
    -d, --directory   path to backup files in the backup directory
    -u, --use-cfg     use configuration file
    -s, --set-cfg     path to configuration file
    -v, --version     output version information and exit
    -h, --help        display this help and exit 
  
  Some examples:

    ./dbbackup.sh -b -c config.file
    ./dbbackup.sh -r -p 27017
    ./dbbackup.sh --version

## Config file options

    BACKUP_PATH - path to backup directory
    DBPORT - MongoDB open port in container
    CONTAINER - conatainer name
    URI - connection string to database