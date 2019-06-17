#!/usr/bin/env bash

export_var() {
    local var
    var="${1}"
    if [ -n "${!var}" ]
    then
        export "$2"="${!var}"
    else
        export "$2"="${3}"
    fi
}

check_plugin_vars() {
    OLDIFS=$IFS; IFS=','
    for e in \
        PLUGIN_ACCESS_KEY,AWS_ACCESS_KEY_ID,"" \
        PLUGIN_SECRET_KEY,AWS_SECRET_ACCESS_KEY,"" \
        PLUGIN_REGION,AWS_REGION,${AWS_DEFAULT_REGION} \
        PLUGIN_CLUSTER,ECS_CLUSTER,${AWS_ECS_DEFAULT_CLUSTER} \
        PLUGIN_CNF_STACK,AWS_CNF_STACK,${ECS_CLUSTER} \
        PLUGIN_LAUNCH_TYPE,AWS_LAUNCH_TYPE,EC2 \
        PLUGIN_ECS_PROFILE,ECS_PROFILE,drone \
        PLUGIN_COMPOSE_FILE,COMPOSE_FILE,docker-compose.yml \
        PLUGIN_PARAMS_FILE,ECS_PARAMS_FILE,ecs-params.yml \
        PLUGIN_SERVICE,ECS_SERVICE,${PWD##*/} \
        PLUGIN_DEPLOYMENT_MAX_PERCENT,DEPLOYMENT_MAX_PERCENT,200 \
        PLUGIN_DEPLOYMENT_MIN_HEALTHY_PERCENT,DEPLOYMENT_MIN_HEALTHY_PERCENT,100 \
        PLUGIN_TIMEOUT,TIMEOUT,10 \
        PLUGIN_TARGET_GROUP_ARN,TARGET_GROUP_ARN,"" \
        PLUGIN_CONTAINER_NAME,CONTAINER_NAME,server \
        PLUGIN_CONTAINER_PORT,CONTAINER_PORT,8000 \
        PLUGIN_HEALTH_CHECK_GRACE_PERIOD,HEALTH_CHECK_GRACE_PERIOD,15
    do
        set -- $e
        export_var "$1" "$2" "$3"
    done
    IFS=$OLDIFS
}

if ! check_plugin_vars
then
    echo "Seems something went wrong."
    exit 1
fi

if [ "${PLUGIN_DEPLOY_COMMIT}" ]
then
    sed -i "s|{{tag}}|${PLUGIN_DEPLOY_COMMIT}|g" "${COMPOSE_FILE}"
fi