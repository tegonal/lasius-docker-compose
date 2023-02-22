# Lasius

This is a companion repo for Lasius, the open source time tracking solution for teams.

## Beta..?!?
1) We are currently preparing the source code release of Lasius in another repo that we will link to once we are ready. In the meantime, you can use the `compose` files this repo to run Lasius locally, using the docker images we provide on docker hub.
2) Please note that Lasius is currently in beta. We are working hard to make it production ready, but we cannot guarantee that it will work for you.
3) **We currently only offer amd64 images.** If you want to run Lasius on a different architecture, you need to build the images yourself.

## Getting started

In order to run Lasius locally you need to have [Docker](https://www.docker.com/) and [Docker Compose](https://docs.docker.com/compose/) installed.

### Requirements
```
$ uname -m
x86_64

$ docker --version
Docker version 20.10.22, build 3a2c30b
```

### Setup
```
git clone git@github.com:tegonal/lasius-docker-compose.git

# Copy the example environment file and _change the secrets_
cp .env.example .env

# Start the containers for local testing, without https / letsencrypt
./start-http.sh

# Start the containers for production, with https / letsencrypt
# This will require you to run Lasius on a public domain. Make sure to set the correct domain/hostname in the .env file
./start-https.sh

# Stop the containers
docker-compose down
```

### Usage

Depending on which script you used to start the containers, Lasius will be available at `http://localhost:8080` or on your specified hostname.

## Looking for someone to run Lasius for you?

If you would like to use Lasius in a commercial setting, please contact us at [info@tegonal.com](mailto:info@tegonal.com). We can help you with deployment and maintenance of Lasius.

Or join the Lasius SaaS beta at [https://lasius.ch](https://lasius.ch).

## Terms of use

Lasius is licensed under Gnu Affero General Public License v3.0. Please read the [LICENSE](LICENSE) file for more information. Lasius comes with no warranty.
