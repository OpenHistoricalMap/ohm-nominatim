OSMFILEURL=$1
PGDIR=$2
THREADS=$3

useradd -m -p password1234 nominatim && \
chown -R nominatim:nominatim ./src

export PGPASSWORD=$PG_PASSWORD
if psql -h $PG_HOST -p $PG_PORT -U $PG_USER -lqt | cut -d \| -f 1 | grep -qw 'nominatim'; then
    if psql -h $PG_HOST -p $PG_PORT -U $PG_USER -tAc "SELECT 1 FROM import_status" | grep -q 1; then
        echo 'DB exists. Skip importing'
        exit 0
    else
        echo 'Tables does not exist, setup db'
        psql -h $PG_HOST -p $PG_PORT -U $PG_USER -tAc "SELECT 1 FROM pg_roles WHERE rolname='nominatim'" | grep -q 1 || createuser -h $PG_HOST -p $PG_PORT -U $PG_USER -s nominatim && \
        psql -h $PG_HOST -p $PG_PORT -U $PG_USER -tAc "SELECT 1 FROM pg_roles WHERE rolname='www-data'" | grep -q 1 || createuser -h $PG_HOST -p $PG_PORT -U $PG_USER -SDR www-data && \
        mkdir -p /data/$PGDIR && \
        echo "Downloading...$1"
        wget $1 -q -O osmfile.osm.bz2 && \
        OSMFILE=osmfile.osm.bz2 && \
        ./src/build/utils/setup.php --osm-file $OSMFILE --setup-db \
         --import-data --create-functions \
         --create-tables --create-partition-tables \
         --create-partition-functions --import-wikipedia-articles \
         --load-data --import-tiger-data \
         --calculate-postcodes --index \
         --create-search-indices --create-country-names \
         --threads $THREADS
    fi
else
    echo 'DB does not exist. Run all operations'
    mkdir -p /data/$PGDIR && \
    wget $1 -q -O osmfile.osm.bz2 && \
    OSMFILE=osmfile.osm.bz2 && \
    ./src/build/utils/setup.php --osm-file $OSMFILE --all --threads $THREADS
fi
