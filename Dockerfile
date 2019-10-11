FROM kudato/baseimage:alpine

RUN curl -o /usr/local/bin/ecs-cli \
    https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-latest

COPY plugin.sh /
RUN chmod +x /usr/local/bin/ecs-cli /plugin.sh

ENV ECS_CLI_VERSION="$(ecs-cli --version)"
WORKDIR /src
CMD [ "/plugin.sh" ]