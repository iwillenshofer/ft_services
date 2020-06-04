FROM alpine:latest
RUN apk add --no-cache nginx
RUN apk add --no-cache openssl
RUN apk add --no-cache openssh-server
RUN apk add --no-cache telegraf \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/

EXPOSE 80 443 22
COPY ./srcs/ /tmp/

RUN chmod 755 tmp/setup.sh
RUN mv /tmp/nginx.conf /etc/nginx/conf.d/default.conf
RUN mkdir -p /ssl/
RUN openssl req -x509 -nodes -newkey rsa:2048 -keyout /ssl/cert.key -out /ssl/cert.crt -days 365 -subj '/CN=localhost'

RUN mkdir -p /var/www/html
RUN mv /tmp/index.html /var/www/html/
RUN mv /tmp/telegraf.conf /etc/telegraf.conf
ENTRYPOINT ["/tmp/setup.sh"]
