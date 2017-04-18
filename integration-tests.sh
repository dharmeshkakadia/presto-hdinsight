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
  hive -e "DROP TABLE IF EXISTS PrestoHiveSampleTable; CREATE TABLE PrestoHiveSampleTable (ClientId string,QueryTime string,Market string,DevicePlatform string,DeviceMake string,DeviceModel string,State string,Country string,QueryDwellTime double,SessionId bigint,SessionPageViewOrder bigint) ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'; LOAD DATA LOCAL INPATH '/usr/lib/examples/hive/HiveSampleData.txt' OVERWRITE INTO TABLE PrestoHiveSampleTable;"
  presto --schema default --execute "select count(*) from PrestoHiveSampleTable" > $result

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
