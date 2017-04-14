#!/bin/bash
set -eux

tpchtest(){
  local result=$(tempfile)
  presto --execute "select count(*) from tpch.tiny.nation" > $result
   
  # There are quotes in the result "25"
  if [[ $(cat $result) == "\"25\"" ]] ; then
    echo "TPCH connector test passed"
  else
    echo "TPCH connector test failed: expected \"25\" , but got $(cat $result)"
    exit 1
  fi
}

hivetest(){
  local result=$(tempfile)
  presto --schema default --execute "select count(*) from hivesampletable" > $result

  # There are quotes in the result "59793"
  if [[ $(cat $result) == "\"59793\"" ]] ; then
    echo "Hive connector test passed"
  else
    echo "Hive connector test failed: expected \"59793\" , but got $(cat $result)"
    exit 1
  fi
}

until [[ $(presto --schema default --execute 'select * from system.runtime.nodes') ]]; do
  echo "waiting for presto workers to join.."
  sleep 5
done

tpchtest
hivetest
