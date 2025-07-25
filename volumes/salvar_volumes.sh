#!/bin/bash
# Script para backup de volumes do Docker

CONTAINER_NAME="rustdesk-tailscale"
VOLUME_NAME="rustdesk_data"

sudo cp -ri "/var/lib/docker/volumes/${CONTAINER_NAME}_${VOLUME_NAME}/" ./

# shellcheck disable=SC2181
if [ $? -eq 0 ]; then
    echo "Backup do volume ${VOLUME_NAME} do contêiner ${CONTAINER_NAME} realizado com sucesso."
else
    echo "Erro ao realizar o backup do volume ${VOLUME_NAME} do contêiner ${CONTAINER_NAME}."
fi
