FROM ubuntu:16.04

RUN apt-get update && \
    apt-get -y install wget && \
    wget https://sensuapp.org/install.sh && \
    printf 'y\nN\n' | bash install.sh && \
    apt-get update && \
    apt-get -y install sensu && \
    apt-get install -y uchiwa && \
    apt-get install -y vim

RUN apt-get -y install redis-server curl jq && \
    sed -i '/bind 127.0.0.1/c\bind 0.0.0.0' /etc/redis/redis.conf && \
    update-rc.d redis-server enable

EXPOSE 4567 3000 6379

RUN wget -O /etc/sensu/config.json https://sensuapp.org/docs/0.26/files/simple-sensu-config.json && \
    chown -R sensu:sensu /etc/sensu

COPY uchiwa-config.json /etc/sensu/uchiwa.json

CMD service redis-server start && \
    service sensu-server start && \
    service sensu-api start && \
    service uchiwa start && \
    tail -f /var/log/sensu/sensu-server.log