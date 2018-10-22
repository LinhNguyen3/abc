#!/bin/bash
sudo apt-get update 
#install the necessary tools 
sudo apt-get install gcc make libreadline6-dev zlib1g-dev -y
#download postgresql source code
sudo mkdir -p /apps/postgres
curl -O https://get.enterprisedb.com/postgresql/postgresql-9.6.3-1-linux-x64-binaries.tar.gz
tar -zxvf postgresql-9.6.3-1-linux-x64-binaries.tar.gz -C /apps/postgres
#manual postgresql deployment
sudo mkdir -p /k8s-data-mt/fme-dbms
sudo useradd -M -s /bin/false postgres
sudo chown -R postgres:postgres /k8s-data-mt/fme-dbms/
sudo mkdir /k8s-data-mt/fme-dbms-log
sudo -u postgres /apps/postgres/pgsql/bin/initdb -D /k8s-data-mt/fme-dbms/
sudo mkdir /apps/postgres/pgsql/log
sudo echo "[Unit]
Description=PostgreSQL 9.6 database server
After=syslog.target network.target
 
[Service]
Type=forking
TimeoutSec=0
 
User=postgres
 
Environment=PGDATA=/k8s-data-mt/fme-dbms
Environment=PIDFILE=/apps/postgres/9.6/data/postmaster.pid
Environment=LOGFILE=/k8s-data-mt/fme-dbms-log/startup.log
 
ExecStart=/apps/postgres/pgsql/bin/pg_ctl start -w -t 120 -D "${PGDATA}" -l "${LOGFILE}"
ExecStop=/apps/postgres/pgsql/bin/pg_ctl stop -m fast -w -D "${PGDATA}"
ExecReload=/apps/postgres/pgsql/bin/pg_ctl reload -D ${PGDATA}
 
[Install]
WantedBy=multi-user.target" > /etc/systemd/system/postgresql-9.6.service
yes Y | sudo apt-get install systemd
sudo systemctl daemon-reload
sudo systemctl enable postgresql-9.6
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
autovacuum_vacuum_threshold = 50" > /k8s-data-mt/fme-dbms/postgres.conf
sudo echo "# IPv4 local connections:
host    all             all             0.0.0.0/0            trust" > /k8s-data-mt/fme-dbms/pg_hba.conf
sudo systemctl restart postgresql-9.6
