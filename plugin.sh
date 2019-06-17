#!/usr/bin/env bash

# Configure esc-cli profile
if [ -f ~/.ecs/config ]; then rm ~/.ecs/config; fi
ecs-cli configure profile \
    --profile-name "${ECS_PROFILE}" \
    --access-key "${AWS_ACCESS_KEY_ID}" \
    --secret-key "${AWS_SECRET_ACCESS_KEY}"

# Configure esc-cli
ecs-cli configure \
    --cluster "${ECS_CLUSTER}" \
    --default-launch-type "${AWS_LAUNCH_TYPE}" \
    --region "${AWS_REGION}" \
    --cfn-stack-name "${AWS_CNF_STACK}"

# Create Task Definitions and Deploy
if [ -n "${TARGET_GROUP_ARN}" ]
then
    ecs-cli compose -f "${COMPOSE_FILE}" --project-name "${ECS_SERVICE}" \
        service up \
            --deployment-max-percent "${DEPLOYMENT_MAX_PERCENT}" \
            --deployment-min-healthy-percent "${DEPLOYMENT_MIN_HEALTHY_PERCENT}" \
            --container-name "${CONTAINER_NAME}" \
            --container-port "${CONTAINER_PORT}" \
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
