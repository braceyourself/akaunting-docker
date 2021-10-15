#!/bin/bash

function ensure_env_is_set(){
    echo "$@"
    exit;
}


export WWWUSER=$(id -u)
export WWWGROUP=$(id -g)
export ENVIRON=production

echo "Creating Traefik Network"
docker network create traefik || true
echo ""

docker-compose build akaunting


echo "Setting up environment file"
test ! -f ".env" && { cp .env.example .env; }
sed -i "s/^WWWUSER=.*/WWWUSER=${WWWUSER}/" .env
sed -i "s/^WWWGROUP=.*/WWWGROUP=${WWWGROUP}/" .env
sed -i "s/^WWWGROUP=.*/WWWGROUP=${WWWGROUP}/" .env

source .env



if [[ -z "${DB_DATABASE}" ]]; then
    echo "DB_DATABASE: \n>" && read DB_DATABASE
    sed -i "s/^DB_DATABASE=.*/DB_DATABASE=${DB_DATABASE}/" .env
fi

if [[ -z "${DB_USERNAME}" ]]; then
    echo "DB_USERNAME: \n>" && read DB_USERNAME
    sed -i "s/^DB_USERNAME=.*/DB_USERNAME=${DB_USERNAME}/" .env
fi

if [[ -z "${DB_PASSWORD}" ]]; then
    echo "DB_PASSWORD: \n>" && read DB_PASSWORD
    sed -i "s/^DB_PASSWORD=.*/DB_PASSWORD=${DB_PASSWORD}/" .env
fi


# only start a traefik service if one is not already running
if [ ! "$(docker ps -q -f name=traefik)" ]; then

    if [ "$(docker ps -aq -f status=exited -f name=traefik)" ]; then
        # cleanup the stopped service
        docker rm traefik
    fi

    echo "Starting Traefik container"
    docker-compose -f traefik.yml up -d --no-recreate || true
    echo ""

fi

echo "Starting application"
docker-compose up -d
echo ""