#!/bin/bash

# CLI Arguments (Specify -e email or -d directory when running script)
TEMP=`getopt -o d:e:t:sd: --long directory:email:time-interval:sync-directory: -- "$@"`
eval set -- "$TEMP"

# Check the CLI flags
while true ; do
    case "$1" in
        -e|--email)
            email=$2 ; shift 2;;
        -d|--directory)
            directory=$2 ; shift 2;;
        -sd|--sync-directory)
            sync_directory=$2 ; shift 2;;
        --) shift ; break ;;
        *) echo "Internal error!" ; exit 1 ;;
    esac
done

# Formatting directory
i=${directory: -1}
if [ $i != "/" ]; then
  $directory="$directory/"
fi


while :
do
sleep 20

while inotifywait -r -e create $directory; do
  # Sleep for 10 seconds in case there are a few files being uploaded
  sleep 10
  for f in "$directory"*
  do
    /usr/local/bin/cosaint.sh -a clean -f $f -e $email -d $sync_directory
  done

done
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
echo "cosaint.service finished at $TIMESTAMP"
done
