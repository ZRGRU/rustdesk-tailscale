#!/bin/bash
# Script para backup de volumes do Docker

CONTAINER_NAME="rustdesk-tailscale"
VOLUME_NAME="rustdesk_data"

sudo cp -r "/var/lib/docker/volumes/${CONTAINER_NAME}_${VOLUME_NAME}/" ./
