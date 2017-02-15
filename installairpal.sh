#!/bin/bash

#Install mysql
mysqlPassword=presto
prestoaddress=$(slider registry  --name presto1 --getexp presto | grep value | grep -o "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*:[0-9]*")
echo "detected presto running on $prestoaddress"
apt-get update

echo "mysql-server-5.7 mysql-server/root_password password $mysqlPassword" | debconf-set-selections
echo "mysql-server-5.7 mysql-server/root_password_again password $mysqlPassword" | debconf-set-selections

#install mysql-server 5.7
apt-get -y install mysql-server-5.7

#service mysql restart
mysql --user=root -p$mysqlPassword -e "drop database if exists airpal; create database airpal"

#Build airpal fork that has latest presto API fix
wget https://github.com/stunlockstudios/airpal/archive/master.tar.gz -O airpal.tar.gz
tar xzf airpal.tar.gz
chmod -R 777 airpal-master
cd airpal-master

# Build fails for root user on node-gyp
su hive ./gradlew clean shadowJar
cp reference.example.yml reference.yml

java -Ddw.prestoCoordinator=http://$prestoaddress \
     -Ddw.dataSourceFactory.url=jdbc:mysql://127.0.0.1:3306/airpal \
     -Ddw.dataSourceFactory.user=root \
     -Ddw.dataSourceFactory.password=$mysqlPassword \
     -Duser.timezone=UTC \
     -cp build/libs/airpal-*-all.jar com.airbnb.airpal.AirpalApplication db migrate reference.yml

nohup java -Ddw.prestoCoordinator=http://$prestoaddress \
     -Ddw.dataSourceFactory.url=jdbc:mysql://127.0.0.1:3306/airpal \
     -Ddw.dataSourceFactory.user=root \
     -Ddw.dataSourceFactory.password=$mysqlPassword \
     -Duser.timezone=UTC \
     -Ddw.server.applicationConnectors[0].port=9191 \
     -Ddw.server.adminConnectors[0].port=9192 \
     -cp build/libs/airpal-*-all.jar com.airbnb.airpal.AirpalApplication server reference.yml &
