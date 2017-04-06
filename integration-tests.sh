#!/bin/bash
set -eux

result=$(tempfile)
presto --schema default --execute "select count(*) from hivesampletable"

# There are quotes in the result "59793"
if [ $(cat $result) == "\"59793\"" ]; then
  echo "Hive connector test passed"
else
  echo "Hive connector test failed " expected \"59793\" , but got $(cat $result)"
  exit 1
fi  
  
