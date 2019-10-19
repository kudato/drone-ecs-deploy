## drone-ecs-deploy

[![](https://images.microbadger.com/badges/image/kudato/drone-ecs-deploy.svg)](https://microbadger.com/images/kudato/drone-ecs-deploy "Get information about this image.")

This [Drone](https://drone.io/) plugin is just a wrapper for [ecs-cli](https://docs.aws.amazon.com/en_us/AmazonECS/latest/developerguide/ECS_CLI.html). It uses the ability to create a task definition from the docker-compose file, supports the [ecs-params](https://docs.aws.amazon.com/en_us/AmazonECS/latest/developerguide/cmd-ecs-cli-compose-ecsparams.html) file as a source of additional parameters and the association of the launched containers with the target group of the elastic load balancer. You can find more details about using docker-compose [here](https://docs.aws.amazon.com/en_us/AmazonECS/latest/developerguide/ECS_CLI.html).


### Usage

Deployment will require only a cluster in AWS ECS and ELB with a target group if necessary. Both Application Load Balancer and Network Load Balancer are supported. Service and task definition will be created automatically if they do not exist.


Example pipeline step for deployment without use ELB:

```yaml
...

- name: Deploy
  image: kudato/drone-ecs-deploy
  settings:
    region: us-east-1
    cluster: name-of-your-ecs-cluster
    service: name-of-yout-ecs-service
    compose_file: path/to/docker-compose.yml
    params_file: path/to/ecs-params.yml
    deploy_tag: ${DRONE_COMMIT_SHA:0:7}
    access_key:
      from_secret: aws_access_key_id
    secret_key:
      from_secret: aws_secret_access_key

...

```

To associate with the target group, you must additionally specify its arn container port name to be added to the target container group


```yaml
...
  settings:
    ...
    target_group_arn: your-target-group-arn
    container_name: webserver
    container_port: 80
    ...
...

```

# Parameter Reference

- **access_key:** your aws access key

- **secret_key:** your aws secret access key

- **region:** aws region where your registry is located, defaults is `us-east-1`

- **images:** list of download images

