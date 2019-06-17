FROM kudato/baseimage:alpine3.9

COPY plugin.sh /

RUN apk add --no-cache --virtual .deps gnupg curl \
	&& curl -o /usr/local/bin/ecs-cli \
		https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-latest \
	&& chmod +x /usr/local/bin/ecs-cli /plugin.sh  \
	&& apk del .deps

ENV \
	AWS_DEFAULT_REGION=us-east-1 \
	ECS_DEFAULT_CLUSTER=default \
	ECS_CLI_VERSION="$(ecs-cli --version)" \
	CMD_USER=ecs-cli

CMD [ "/plugin.sh" ]