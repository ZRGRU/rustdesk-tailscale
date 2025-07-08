#!/bin/bash
# Script para backup de volumes do Docker

CONTAINER_NAME="rustdesk-tailscale"
VOLUME_NAME="rustdesk_data"

sudo cp -r ./"${CONTAINER_NAME}"_"${VOLUME_NAME}"/_data /var/lib/docker/volumes/"${CONTAINER_NAME}"_"${VOLUME_NAME}"/_data

