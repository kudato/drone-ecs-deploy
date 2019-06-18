#!/usr/bin/env bash

if [ -n "${PLUGIN_DEPLOY_COMMIT}" ]
then
    if [ -n "${PLUGIN_COMPOSE_FILE}" ]
    then
        export COMPOSE_FILE=${PLUGIN_COMPOSE_FILE}
    else
        export COMPOSE_FILE=docker-compose.yml
    fi
    sed -i "s|{{tag}}|${PLUGIN_DEPLOY_COMMIT}|g" "${COMPOSE_FILE}"
fi
