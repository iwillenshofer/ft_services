FROM alpine:latest

RUN apk add --update --no-cache influxdb
RUN apk add --update --no-cache grafana telegraf \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/
COPY ./srcs/ /tmp/
COPY ["srcs/influxdb.conf", "/etc/influxdb.conf"]
COPY ["srcs/telegraf.conf", "/etc/telegraf.conf"]
RUN chmod 755 /tmp/setup.sh

EXPOSE 8086 8088
ENTRYPOINT ["/tmp/setup.sh"]
