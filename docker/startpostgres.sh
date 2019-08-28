#!/bin/bash
PGDIR=$1

# sudo mkdir -p /data/$PGDIR && export PGDATA=/data/$PGDIR
# sudo chown -R postgres:postgres /data/$PGDIR 

# sudo -u postgres /usr/lib/postgresql/11/bin/initdb -D /data/$PGDIR && \
# sudo -u postgres /usr/lib/postgresql/11/bin/pg_ctl -D /data/$PGDIR start && \
sudo service postgresql start && \
sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='nominatim'" | grep -q 1 || sudo -u postgres createuser -s nominatim && \
sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='www-data'" | grep -q 1 || sudo -u postgres createuser -SDR www-data && \
sudo -u postgres psql postgres -c "DROP DATABASE IF EXISTS nominatim" && \

sudo service postgresql restart && \
tail -f /var/log/postgresql/postgresql-11-main.log