#!/bin/bash

echo "== Run mix test ==
> Execute NOT inside a docker container.
";

function initGlobals(){
  # echo "Define error reporting level, file seperator, and init direcotry.";
#  set -Eeuo pipefail; # set -o xtrace;
  IFS=$'\n\t'
  readonly DIR=$PWD;
  TMP="$(dirname "${DIR}")"
  readonly ROOT_DIR="$(dirname "${TMP}")"
  readonly STORAGE_DIR="$ROOT_DIR/storage"
  readonly LOG_DIR="$STORAGE_DIR/logs"
  readonly LOG_FILENAME="phoenix-tests.log"
  readonly LOG_FILE="$LOG_DIR/$LOG_FILENAME"
}

function prepareLogsDirectory(){
  echo 'Prepare logs directory.'
  
  if [[ ! -d $STORAGE_DIR ]]; then
		mkdir $STORAGE_DIR;
    echo "Created $STORAGE_DIR"
	fi
  if [[ ! -d $LOG_DIR ]]; then
		mkdir $LOG_DIR;
    echo "Created $LOG_DIR"
	fi 
}

function archivePreviousLog(){

  if [[ -r $LOG_FILE ]]; then

    timestamp=`date '+%Y-%m-%d_%H-%M-%S'`;
    newFile="$LOG_FILE-$timestamp"
    
    echo 'Archive previous log file to $newFile.'
    mv $LOG_FILE $newFile
  fi
}

function runTests(){
  echo "Run tests."
  cd $ROOT_DIR
  mix test > $LOG_FILE
  cd $DIR
}

initGlobals
prepareLogsDirectory
archivePreviousLog
runTests

echo "Phoenix tests have been finished!"
cd $DIR
