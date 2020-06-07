FROM alpine:latest

COPY ./srcs/ /tmp/
RUN apk update
RUN apk add lighttpd mysql-client
RUN apk add php7 php7-openssl php7-cgi php7-xml php7-pdo php7-mcrypt php7-session php7-mysqli php7-zlib php7-json php-iconv php-mbstring
RUN apk add --update --no-cache telegraf \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/
ADD https://files.phpmyadmin.net/phpMyAdmin/5.0.2/phpMyAdmin-5.0.2-english.tar.gz /tmp/phpmyadmin.tar.gz

EXPOSE 5000

ENTRYPOINT ["sh", "/tmp/setup.sh"]
