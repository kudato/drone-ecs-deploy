FROM kudato/baseimage:alpine

RUN curl -o /usr/local/bin/ecs-cli \
    https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-latest

COPY plugin.sh /usr/bin/
RUN chmod +x /usr/local/bin/ecs-cli /usr/bin/plugin.sh

WORKDIR /src
CMD [ "/usr/bin/plugin.sh" ]