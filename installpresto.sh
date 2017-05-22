#!/bin/bash
set -eux

VERSION=0.174

mkdir -p /var/lib/presto
chmod -R 777 /var/lib/presto/

if [[ $(hostname -s) = hn0-* ]]; then 
  apt-get update
  which mvn &> /dev/null || apt-get -y -qq install maven
  cd /var/lib/presto
  wget https://github.com/dharmeshkakadia/presto-hdinsight/archive/master.tar.gz -O presto-hdinsight.tar.gz
  tar xzf presto-hdinsight.tar.gz
  cd presto-hdinsight-master
  ./createsliderbuild.sh $VERSION
  slider package --install --name presto1 --package build/presto-yarn-package.zip --replacepkg
  ./createconfigs.sh $VERSION "${1:-}"
  slider exists presto1 --live && slider stop presto1 --force
  slider exists presto1 && slider destroy presto1 --force
  slider create presto1 --template appConfig-default.json --resources resources-default.json
fi

if [[ $(hostname -s) = hn* ]]; then 
  wget https://repo1.maven.org/maven2/com/facebook/presto/presto-cli/$VERSION/presto-cli-$VERSION-executable.jar -O /usr/local/bin/presto-cli
  chmod +x /usr/local/bin/presto-cli

  until slider registry  --name presto1 --getexp presto ; do
    echo "waiting for presto to start.."
    sleep 10
  done

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
