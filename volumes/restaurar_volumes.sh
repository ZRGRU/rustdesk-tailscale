#!/bin/bash
# Script para restaurar backup de volumes do Docker

CONTAINER_NAME="rustdesk-tailscale"
VOLUME_NAME="rustdesk_data"

sudo cp -ri ./"${CONTAINER_NAME}"_"${VOLUME_NAME}"/_data /var/lib/docker/volumes/"${CONTAINER_NAME}"_"${VOLUME_NAME}"/

# shellcheck disable=SC2181
if [ $? -eq 0 ]; then
    echo "Restauração do volume ${VOLUME_NAME} do contêiner ${CONTAINER_NAME} realizada com sucesso."
else
    echo "Erro ao realizar a restauração do volume ${VOLUME_NAME} do contêiner ${CONTAINER_NAME}."
fi
