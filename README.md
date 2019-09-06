# ohm-nominatim

This repository has all the modules and scripts required to standup an instance of Nominatim that points to the OpenHistoricalMap Planet extracts, and updates minutely. [Nominatim](https://www.nominatim.org) is the geocoding software for OpenStreetMap.

## Docker

The Dockerfiles are forked from [mediagis/nominatim-docker](https://github.com/mediagis/nominatim-docker/), with some minor changes to make it work for our usecase to host on AWS.

### Running locally
You can run the setup locally using `docker-compose`.
* Copy env.sample to `.env` and make adjustments if necessary
* Build the images `docker-compose build`
* Run the containers `docker-compose up`

## AWS

Production instance for OHM Nominatim is hosted on AWS. The `cloudformation` folder has the cloudformation yaml as well as a deploy script.

### Setting up an EC2 with PostgreSQL
Since Nominatim relies of custom functions, we cannot run rely on RDS. Currently, we run a t2.small that acts as the PostgreSQL server node. This has to be setup independent of the cloudformation stack. The `setup-ec2.sh` script will do everything needed to setup an EC2. Make sure the PostgreSQL ports are open for connection from anywhere.

### ECS Fargate Stack
Once the EC2 is ready, you can run `./deploy.sh` and give it the connection details. This will standup an ECS Fargate stack with two tasks -- API and Update. API runs the Nominatim software and website, and Update task runs the osmosis process to fetch replication and apply them to the database minutely.