OSMFILEURL=$1
PGDIR=$2
THREADS=$3

useradd -m -p password1234 nominatim && \
chown -R nominatim:nominatim ./src

if psql -lqt | cut -d \| -f 1 | grep -qw 'nominatim'; then
    echo 'DB exists. Skip importing'
    exit 0
else
    echo 'DB does not exist. Importing'
    mkdir -p /data/$PGDIR && \
    wget $1 -O osmfile.osm.bz2
    OSMFILE=osmfile.osm.bz2

    # export  PGDATA=/data/$PGDIR  && \
    ./src/build/utils/setup.php --osm-file $OSMFILE --all --threads $THREADS
fi
