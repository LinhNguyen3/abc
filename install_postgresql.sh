#!/bin/bash
sudo apt-get update 
#install the necessary tools 
sudo apt-get install gcc make libreadline6-dev zlib1g-dev -y
#download postgresql source code
mkdir -p /apps/postgres
mkdir -p /apps/postgres12

wget https://get.enterprisedb.com/postgresql/postgresql-9.6.3-1-linux-x64-binaries.tar.gz
tar -zxvf postgresql-9.6.3-1-linux-x64-binaries.tar.gz -C /apps/postgres
#manual postgresql deployment
sudo mkdir -p /k8s-data-mt/fme-dbms
sudo useradd -M -s /bin/false postgres
sudo chown -R postgres:postgres /k8s-data-mt/fme-dbms/
sudo mkdir /k8s-data-mt/fme-dbms-log
sudo -u postgres /apps/postgres/pgsql/bin/initdb -D /k8s-data-mt/fme-dbms/
sudo mkdir /apps/postgres/pgsql/log
