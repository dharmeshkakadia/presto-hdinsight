mkdir build
cd build

git clone https://github.com/prestodb/presto-yarn
#update the presto.version
mvn clean package -f presto-yarn/pom.xml

unzip presto-yarn/presto-yarn-package/target/presto-yarn-package-1.4-SNAPSHOT-0.163.zip -d presto-yarn-package
tar xzf presto-yarn-package/package/files/presto-server-0.163.tar.gz
rm presto-server-0.163/plugin/hive-hadoop2/hadoop-apache2-0.10.jar

git clone https://github.com/prestodb/presto-hadoop-apache2
#Apply WASB patch
mvn clean package -f presto-hadoop-apache2/pom.xml
cp presto-hadoop-apache2/target/hadoop-apache2-0.11-SNAPSHOT.jar presto-server-0.163/plugin/hive-hadoop2/

tar cvf presto-server-0.163.tar.gz presto-server-0.163/
cp presto-server-0.163.tar.gz presto-yarn-package/package/files/
cd presto-yarn-package
zip -r ../../presto-yarn-package-1.4-SNAPSHOT-0.163.zip .
