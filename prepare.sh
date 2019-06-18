#!/usr/bin/env bash

if [ -n "${PLUGIN_DEPLOY_TAG}" ]
then
    export DEPLOY_TAG=${PLUGIN_DEPLOY_TAG}
fi

if [ -n "${DEPLOY_TAG}" ]
then
    if [ -n "${PLUGIN_COMPOSE_FILE}" ]
    then
        export COMPOSE_FILE=${PLUGIN_COMPOSE_FILE}
    else
        export COMPOSE_FILE=docker-compose.yml
    fi
    sed -i "s|{{tag}}|${DEPLOY_TAG}|g" "${COMPOSE_FILE}"
fi
