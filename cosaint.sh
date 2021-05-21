#!/bin/bash

# Cosaint is simple script that cleans a file of metadata, compresses it, encrypts it with a GPG key and moves -
# the file to a new folder if specified.  


cleaning()
{
  mat2 --unknown-members omit --inplace $1
  echo "Directory $1 cleaned"
}

encrypting()
{
  # Compress file
  zip -r "$1".zip $1

  # Encrypt file using GPG and the users email
  yes "y" | gpg --encrypt --sign --armor -r $2 "$1".zip

  # Checking if sync directory specified, if so moves the GPG signed file and removes the .zip file
  if [ -z "${3++}" ]; then
    exit 1
  fi
  mv "$1".zip.asc $3
  rm "$1".zip
}


# CLI Arguments:
TEMP=`getopt -o a:f:e:d:h --long action:file:email:directory:help -- "$@"`
eval set -- "$TEMP"

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  echo "Usage: Cosaint -a [action] -f [file] [options]"
  echo "-a is the action you want to preform (clean, encrypt, all)" 
  echo "-f is the file or directory you want to preform the action on"
  echo "-e is the recipient email used for the GPG encryption (required for encrypting)"
  echo "-d is the directory you want to sync the file to (if not set file will be kept locally)"
  echo
  echo "Example:"
  echo
  echo "cosaint -a encrypt -f <some_file> -e somelad@protonmail.com"
  exit 1
fi

# Check the CLI flags
while true ; do
    case "$1" in
        -a|--action)
            the_action=$2 ; shift 2;;
        -f|--file)
            the_file=$2 ; shift 2;;
        -e|--email)
            email=$2 ; shift 2;;
        -d|--directory)
            directory=$2 ; shift 2;;
        --) shift ; break ;;
        *) echo "Internal error!" ; exit 1 ;;
    esac
done

# Checking if file and action specified
if [ -z "${the_file++}" ] || [ -z "${the_action++}" ]
then
  echo "Action or File not specified. Run 'cosaint -h' for help"
  exit 1
fi

if [ $the_action == 'clean' ] 
then
  cleaning $the_file
elif [ $the_action == 'encrypt' ]
then
  encrypting $the_file $email $directory 
elif [ $the_action == 'all' ]
then
  cleaning $the_file
  encrypting $the_file $email $directory
else
  echo "The action specified '$the_action' is not supported. Run 'cosaint -h' for help"
  exit 1
fi

