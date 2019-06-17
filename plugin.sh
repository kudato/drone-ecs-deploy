#!/bin/bash

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
        PLUGIN_REGION,AWS_DEFAULT_REGION,us-east-1 \
		PLUGIN_CLUSTER,AWS_ECS_CLUSTER,default \
		PLUGIN_CNF_STACK,AWS_CNF_STACK,${AWS_ECS_CLUSTER} \
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

# Set tag in compose file
if [ "${PLUGIN_DEPLOY_COMMIT}" ]
then
	sed -i "s|{{tag}}|${PLUGIN_DEPLOY_COMMIT}|g" "${COMPOSE_FILE}"
fi

# Configure esc-cli profile
if [ -f ~/.ecs/config ]; then rm ~/.ecs/config; fi
ecs-cli configure profile \
	--profile-name "${ECS_PROFILE}" \
	--access-key "${AWS_ACCESS_KEY_ID}" \
	--secret-key "${AWS_SECRET_ACCESS_KEY}"

# Configure esc-cli
ecs-cli configure \
	--cluster "${AWS_ECS_CLUSTER}" \
	--default-launch-type "${AWS_LAUNCH_TYPE}" \
	--region "${AWS_DEFAULT_REGION}" \
	--cfn-stack-name "${AWS_CNF_STACK}"

# Create Task Definitions
ecs-cli compose -f "${COMPOSE_FILE}" \
	--ecs-params "${ECS_PARAMS_FILE}" \
	--project-name "${ECS_SERVICE}" create


# Deploy
if [ -n "${TARGET_GROUP_ARN}" ]
then
	ecs-cli compose -f "${COMPOSE_FILE}" --project-name "${ECS_SERVICE}" \
		service up \
			--deployment-max-percent "${DEPLOYMENT_MAX_PERCENT}" \
			--deployment-min-healthy-percent "${DEPLOYMENT_MIN_HEALTHY_PERCENT}" \
			--container-name "${CONTAINER_NAME}" \
			--target-group-arn "${TARGET_GROUP_ARN}" \
			--timeout "${TIMEOUT}" \
			--launch-type "${AWS_LAUNCH_TYPE}" \
			--health-check-grace-period "${HEALTH_CHECK_GRACE_PERIOD}"
else
	ecs-cli compose -f "${COMPOSE_FILE}" --project-name "${ECS_SERVICE}" \
		service up \
			--deployment-max-percent "${DEPLOYMENT_MAX_PERCENT}" \
			--deployment-min-healthy-percent "${DEPLOYMENT_MIN_HEALTHY_PERCENT}" \
			--timeout "${TIMEOUT}" \
			--launch-type "${AWS_LAUNCH_TYPE}"
fi
