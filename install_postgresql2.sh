#!/bin/bash
sudo apt-get update 

#install the necessary tools 
sudo apt-get install gcc make libreadline6-dev zlib1g-dev -y

#download postgresql source code
sudo mkdir -p /apps/postgres
sudo wget https://ftp.postgresql.org/pub/source/v9.6.3/postgresql-9.6.3.tar.bz2 -P /apps/postgres
cd /apps/postgres
sudo tar jxvf  postgresql-9.6.3.tar.bz2


#manual postgresql deployment
sudo mkdir -p /var/lib/pgsql/data
sudo useradd -M -s /bin/false postgres
sudo chown -R postgres:postgres /var/lib/pgsql/data/
sudo mkdir /var/lib/pgsql/data-log
sudo chown -R postgres:postgres /var/lib/pgsql/data-log/
sudo -u postgres /apps/postgres/pgsql/bin/initdb -D /var/lib/pgsql/data/
sudo mkdir /apps/postgres/pgsql/log

#install postgressql 9.6.3
cd postgresql-9.6.3
./configure --prefix=/opt/postgresql-9.6.3
# sudo mkdir -p /opt/pgsql_data
# sudo chown -R postgres.postgres /opt/pgsql_data

#setup postgresql-9.6.service
sudo echo "[Unit]
Description=PostgreSQL 9.6 database server
After=syslog.target network.target
 
[Service]
Type=forking
TimeoutSec=0
 
User=postgres
 
Environment=PGDATA=/var/lib/pgsql/data
Environment=PIDFILE=/apps/postgres/9.6/data/postmaster.pid
Environment=LOGFILE=/var/lib/pgsql/data-log/startup.log
 
ExecStart=/apps/postgres/pgsql/bin/pg_ctl start -w -t 120 -D /var/lib/pgsql/data -l /var/lib/pgsql/data-log/startup.log
ExecStop=/apps/postgres/pgsql/bin/pg_ctl stop -m fast -w -D /var/lib/pgsql/data
ExecReload=/apps/postgres/pgsql/bin/pg_ctl reload -D /var/lib/pgsql/data
 
[Install]
WantedBy=multi-user.target" > /etc/systemd/system/postgresql-9.6.service

#install systemd
yes Y | sudo apt-get install systemd
sudo systemctl daemon-reload
sudo systemctl enable postgresql-9.6

#setup postgres.conf 
sudo echo "listen_addresses = '*'          
port = 5432                             
tcp_keepalives_idle = 200 
tcp_keepalives_interval = 200 
tcp_keepalives_count = 5 
shared_buffers = 4096MB 
work_mem = 4MB 
fsync = on 
synchronous_commit = on 
wal_sync_method = fsync 
checkpoint_timeout = 5min 
archive_mode = off 
log_destination = 'stderr' 
logging_collector = on 
log_truncate_on_rotation = on 
log_rotation_age = 4d 
autovacuum = on 
log_autovacuum_min_duration = 0 
autovacuum_max_workers = 1 
autovacuum_naptime = 1min 
autovacuum_vacuum_threshold = 50" > /var/lib/pgsql/data/postgres.conf

#setup pg_hba.conf 
sudo echo "# IPv4 local connections:
host    all             all             0.0.0.0/0            trust" > /var/lib/pgsql/data/pg_hba.conf
sudo systemctl restart postgresql-9.6

#setup postgreSQL
cd /root/postgresql-9.3.5/contrib/start-scripts
cp linux /etc/init.d/postgresql
sed -i '32s#usr/local#opt#' /etc/init.d/postgresql
sed -i '35s#usr/local/pgsql/data#var/lib/pgsql/data#' /etc/init.d/postgresql
chmod +x /etc/init.d/postgresql
/etc/init.d/postgresql start