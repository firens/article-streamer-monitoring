#!/usr/bin/env bash

wget -q https://sensu.global.ssl.fastly.net/apt/pubkey.gpg -O- | apt-key add -
echo "deb     https://sensu.global.ssl.fastly.net/apt sensu main" | tee /etc/apt/sources.list.d/sensu.list
apt-get update
apt-get install sensu

# Install checks
sensu-install -p cpu-checks:1.0.0


echo '{}' > /etc/sensu/config.json

# Might not be necessary
mkdir /etc/sensu/conf.d

cat > /etc/sensu/conf.d/client.json <<- EOM
   {
      "client": {
        "name": "application_server",
        "environment": "development",
        "subscriptions": [
          "development"
        ]
    }
}
EOM

cat > '/etc/sensu/conf.d/transport.json' <<- EOM
{
  "transport": {
    "name": "redis",
    "reconnect_on_error": true
  }
}
EOM

cat > '/etc/sensu/conf.d/redis.json' <<- EOM
{
  "redis": {
    "host": "178.62.95.107",
    "port": 6379
  }
}
EOM

update-rc.d sensu-client defaults

echo 'Installation completed, starting client service'

service sensu-client start

echo 'Client service started'