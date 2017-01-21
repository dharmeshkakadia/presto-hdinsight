#!/bin/bash

wget -O /tmp/HDInsightUtilities-v01.sh -q https://hdiconfigactions.blob.core.windows.net/linuxconfigactionmodulev01/HDInsightUtilities-v01.sh && source /tmp/HDInsightUtilities-v01.sh && rm -f /tmp/HDInsightUtilities-v01.sh

if [[ `hostname -f` == `get_primary_headnode` ]]; then
  which mvn &> /dev/null || sudo apt-get -y -qq install maven
  mkdir /var/lib/presto
  cd /var/lib/presto
  wget https://github.com/dharmeshkakadia/presto-hdinsight/archive/master.tar.gz -O presto-hdinsight.tar.gz
  tar xzf presto-hdinsight.tar.gz
  cd presto-hdinsight-master
  ./createsliderbuild.sh
  slider package --install --name presto1 --package build/presto-yarn-package.zip
  ./createconfigs.sh
  slider create presto1 --template appConfig-default.json --resources resources-default.json
fi

if [[ $shorthostname == workernode* || $shorthostname == wn* ]]; then
  mkdir /var/lib/presto
  chmod -R 777 /var/lib/presto/
fi

