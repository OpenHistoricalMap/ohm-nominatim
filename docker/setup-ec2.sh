sudo apt-get -y update -qq 
sudo apt-get -y install locales && \
    sudo locale-gen en_US.UTF-8 && \
    sudo update-locale LANG=en_US.UTF-8

sudo tee /etc/apt/sources.list.d/pgdg.list <<END
deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main
END

wget https://www.postgresql.org/media/keys/ACCC4CF8.asc && \
sudo apt-key add ACCC4CF8.asc

# fetch the metadata from the new repo
sudo apt-get update

sudo apt-get install -y build-essential cmake g++ libboost-dev libboost-system-dev \
    libboost-filesystem-dev libexpat1-dev zlib1g-dev libxml2-dev \
    libbz2-dev libpq-dev libgeos-dev libgeos++-dev libproj-dev \
    postgresql postgresql-server-dev-11 postgresql-contrib postgresql-11-postgis-2.5 \
    git curl wget \
    osmosis python3-pip \
    libboost-python-dev php-pear php-db php-pgsql php-intl && \
    sudo apt-get clean

sudo pip install osmium
sudo service postgresql start && \
sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='nominatim'" | grep -q 1 || sudo -u postgres createuser -s nominatim && \
sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='www-data'" | grep -q 1 || sudo -u postgres createuser -SDR www-data && \
sudo -u postgres psql postgres -c "DROP DATABASE IF EXISTS nominatim"

#! TODO - setup password for the nominatim pgsql user

# Locally all users are trusted for postgres access
echo "local   all             all                                     trust" | sudo tee -a /etc/postgresql/11/main/pg_hba.conf

# Enable access from anywhere using password
echo "host    all             all             0.0.0.0/0               md5" | sudo tee -a /etc/postgresql/11/main/pg_hba.conf
echo "listen_addresses='*'" | sudo tee -a /etc/postgresql/11/main/postgresql.conf

sudo service postgresql restart
sudo useradd -m nominatim

# Nominatim install
NOMINATIM_VERSION=v3.3.0
git clone --recursive https://github.com/openstreetmap/Nominatim ./src && \
cd ./src && git checkout tags/$NOMINATIM_VERSION && git submodule update --recursive --init && \
    mkdir build && cd build && cmake .. && make

curl http://www.nominatim.org/data/country_grid.sql.gz > ~/src/data/country_osm_grid.sql.gz
sed -i -e 's|bin/python|bin/python3|' ~/src/utils/*.py
chmod o=rwx ~/src/build

# Fetch the local settings file
wget https://gist.githubusercontent.com/geohacker/5f770da6c10fd6ca60e995ceae7bb7f0/raw/56b87c4be1d90042638f4691c2bc2424bdecef79/local-remote.php ~src/build/settings/local.php

# Initialize the DB for minutely updates
wget http://planet.openhistoricalmap.org/planet/ohm_planet_2019-08-27.osm.bz2 -q -O ~/src/data/osmfile.osm.bz2 && \
sudo -u nominatim ~/src/build/utils/setup.php --osm-file ~/src/data/osmfile.osm.bz2 --all --threads 4 && \

