#!/usr/bin/env bash
source /usr/bin/lib.sh

for i in \
    PLUGIN_DEPLOY_TAG,DEPLOY_TAG=latest \
    PLUGIN_ACCESS_KEY,AWS_ACCESS_KEY_ID="" \
    PLUGIN_SECRET_KEY,AWS_SECRET_ACCESS_KEY="" \
    PLUGIN_REGION,AWS_REGION,AWS_DEFAULT_REGION=us-east-1 \
    PLUGIN_CLUSTER,ECS_CLUSTER=default \
    PLUGIN_CNF_STACK,AWS_CNF_STACK=${ECS_CLUSTER} \
    PLUGIN_LAUNCH_TYPE,AWS_LAUNCH_TYPE=EC2 \
    PLUGIN_ECS_PROFILE,ECS_PROFILE=drone \
    PLUGIN_COMPOSE_FILE,COMPOSE_FILE=docker-compose.yml \
    PLUGIN_PARAMS_FILE,ECS_PARAMS_FILE=ecs-params.yml \
    PLUGIN_SERVICE,ECS_SERVICE=${PWD##*/} \
    PLUGIN_DEPLOYMENT_MAX_PERCENT,DEPLOYMENT_MAX_PERCENT=200 \
    PLUGIN_DEPLOYMENT_MIN_HEALTHY_PERCENT,DEPLOYMENT_MIN_HEALTHY_PERCENT=100 \
    PLUGIN_TIMEOUT,TIMEOUT=10 \
    PLUGIN_TARGET_GROUP_ARN,TARGET_GROUP_ARN="" \
    PLUGIN_CONTAINER_NAME,CONTAINER_NAME=server \
    PLUGIN_CONTAINER_PORT,CONTAINER_PORT=8000 \
    PLUGIN_ROLE_ARN,TASK_ROLE_ARN=none \
    PLUGIN_HEALTH_CHECK_GRACE_PERIOD,HEALTH_CHECK_GRACE_PERIOD=15
do
    defaultEnv "${i}"
done
sed -i "s|{{tag}}|${DEPLOY_TAG}|g" "${COMPOSE_FILE}"


if [ -f ~/.ecs/config ]; then rm ~/.ecs/config; fi
ecs-cli configure profile \
    --profile-name "${ECS_PROFILE}" \
    --access-key "${AWS_ACCESS_KEY_ID}" \
    --secret-key "${AWS_SECRET_ACCESS_KEY}"

# Configure esc-cli
ecs-cli configure \
    --cluster "${ECS_CLUSTER}" \
    --default-launch-type "${AWS_LAUNCH_TYPE}" \
    --region "${AWS_DEFAULT_REGION}" \
    --cfn-stack-name "${AWS_CNF_STACK}"


export \
_DEPLOY_CMD="ecs-cli compose -f ${COMPOSE_FILE}"

if [[ "${TASK_ROLE_ARN}" != "none" ]]
then
    export \
    _DEPLOY_CMD="${_DEPLOY_CMD} --task-role-arn ${TASK_ROLE_ARN}"
fi

curry deploy ${_DEPLOY_CMD} --project-name "${ECS_SERVICE}" \
        service up \
            --deployment-max-percent "${DEPLOYMENT_MAX_PERCENT}" \
            --deployment-min-healthy-percent "${DEPLOYMENT_MIN_HEALTHY_PERCENT}" \
            --timeout "${TIMEOUT}" \
            --launch-type "${AWS_LAUNCH_TYPE}"

echo "Starting deploy to ${ECS_CLUSTER}"
if [ -n "${TARGET_GROUP_ARN}" ]
then
    deploy \
        --target-group-arn "${TARGET_GROUP_ARN}" \
        --container-name "${CONTAINER_NAME}" \
        --container-port "${CONTAINER_PORT}" \
        --health-check-grace-period "${HEALTH_CHECK_GRACE_PERIOD}"
else
    deploy
fi
