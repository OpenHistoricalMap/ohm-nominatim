OSMFILEURL=$1
PGDIR=$2
THREADS=$3

mkdir -p /data/$PGDIR && \
wget $1 -O osmfile.osm.bz2
OSMFILE=osmfile.osm.bz2

export  PGDATA=/data/$PGDIR  && \
useradd -m -p password1234 nominatim && \
chown -R nominatim:nominatim ./src && \
sudo -u nominatim ./src/build/utils/setup.php --osm-file $OSMFILE --all --threads $THREADS 
