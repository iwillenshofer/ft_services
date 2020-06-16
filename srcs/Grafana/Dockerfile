FROM alpine:3.11.6

WORKDIR /usr/share/grafana

RUN apk add --update --no-cache grafana telegraf \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/

COPY srcs/datasources.yml /usr/share/grafana/conf/provisioning/datasources/
COPY srcs/dashboards.yml /usr/share/grafana/conf/provisioning/dashboards/
COPY srcs/telegraf.conf /etc/telegraf.conf
COPY srcs/setup.sh /tmp/
COPY srcs/grafana.db /usr/share/grafana/data/grafana.db
COPY srcs/defaults.ini /usr/share/grafana/conf/defaults.ini
COPY srcs/dashboard.json /var/lib/grafana/dashboards/dashboard.json
COPY srcs/dashboard-ftps.json /var/lib/grafana/dashboards/dashboard-ftps.json
COPY srcs/dashboard-grafana.json /var/lib/grafana/dashboards/dashboard-grafana.json
COPY srcs/dashboard-influxdb.json /var/lib/grafana/dashboards/dashboard-influxdb.json
COPY srcs/dashboard-nginx.json /var/lib/grafana/dashboards/dashboard-nginx.json
COPY srcs/dashboard-mysql.json /var/lib/grafana/dashboards/dashboard-mysql.json
COPY srcs/dashboard-phpmyadmin.json /var/lib/grafana/dashboards/dashboard-phpmyadmin.json
COPY srcs/dashboard-wordpress.json /var/lib/grafana/dashboards/dashboard-wordpress.json
RUN chmod +x /tmp/setup.sh
EXPOSE 3000

CMD ["sh", "/tmp/setup.sh"]
