#!/bin/bash
set -eux

# check if we have atleast 4 nodes
nodes=$(curl -L http://headnodehost:8088/ws/v1/cluster/nodes |  grep -o '"nodeHostName":"[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*"'  | wc -l)
if [[ $nodes -lt 4 ]]; then 
  echo "you need atleast 4 node hadoop cluster to run presto on HDI. Aborting."
  exit 1
fi 

VERSION=0.174

mkdir -p /var/lib/presto
chmod -R 777 /var/lib/presto/

if [[ $(hostname -s) = hn0-* ]]; then 
  apt-get update
  which mvn &> /dev/null || apt-get -y -qq install maven
  cd /var/lib/presto
  wget https://github.com/hdinsight/presto-hdinsight/archive/master.tar.gz -O presto-hdinsight.tar.gz
  tar xzf presto-hdinsight.tar.gz
  cd presto-hdinsight-master
  wget https://prestohdi.blob.core.windows.net/build/presto-yarn-package.zip -P build/
  slider package --install --name presto1 --package build/presto-yarn-package.zip --replacepkg
  ./createconfigs.sh $VERSION "${1:-}"
  slider exists presto1 --live && slider stop presto1 --force
  slider exists presto1 && slider destroy presto1 --force
  slider create presto1 --template appConfig-default.json --resources resources-default.json
fi

if [[ $(hostname -s) = hn* ]]; then 
  wget https://repo1.maven.org/maven2/com/facebook/presto/presto-cli/$VERSION/presto-cli-$VERSION-executable.jar -O /usr/local/bin/presto-cli
  chmod +x /usr/local/bin/presto-cli

  attempt=1

  until [[ -n "$(slider registry  --name presto1 --getexp presto | grep 'Exiting with status 0')" || $attempt -gt 60 ]]; do
    echo "waiting for presto to start.. attempt $attempt/60"
    let attempt+=1
    sleep 10
  done

  if [[ $attempt -gt 60 ]]; then
    echo "[Error] Presto failed to start in 10 mins after 60 attempts. Exiting."
    exit 1
  fi

  cat > /usr/local/bin/presto <<EOF
#!/bin/bash
presto-cli --server $(slider registry  --name presto1 --getexp presto |  grep value | grep -o "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*:[0-9]*") --catalog hive "\$@"
EOF
  
  chmod +x /usr/local/bin/presto
fi

# Test
if [[ $(hostname -s) = hn0-* ]]; then
  ./integration-tests.sh
fi
