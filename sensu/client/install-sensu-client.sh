#!/usr/bin/env bash


if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

if [[ $# -ne 2 ]] && [[ $2 != 'APP' ]] && [[ $2 != 'OTHER' ]]; then
    echo "USAGE: 'script.sh [NAME_OF_CLIENT] [APP|OTHER]'"
    exit 1
fi

clientName=$1

if [[ $2 == 'APP' ]]; then
    subscriptions='"development","application"'
else
    subscriptions='"development"'
fi

# Activate docker deamon API if necessary
sed -i 's@ExecStart=/usr/bin/dockerd -H fd://.*@ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:4243@' /lib/systemd/system/docker.service

wget -q https://sensu.global.ssl.fastly.net/apt/pubkey.gpg -O- | apt-key add -
echo "deb     https://sensu.global.ssl.fastly.net/apt sensu main" | tee /etc/apt/sources.list.d/sensu.list
apt-get update
apt-get install sensu

## Install checks ######
# CPU checks
sensu-install -p cpu-checks:1.0.0
# Memory checks
sudo /opt/sensu/embedded/bin/gem install vmstat
sensu-install -p memory-checks:1.0.2
# Disk checks
sensu-install -p disk-checks:2.0.1
# Docker checking
sensu-install -p docker:1.1.5

echo '{}' > /etc/sensu/config.json

# Might not be necessary
mkdir /etc/sensu/conf.d

cat > /etc/sensu/conf.d/client.json <<- EOM
   {
      "client": {
        "name": "$clientName",
        "environment": "development",
        "subscriptions": [
          $subscriptions
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

service sensu-client restart

echo 'Client service started'

echo "You might need to restart the docker daemon to activate the API :
 $ systemctl daemon-reload
 $ service docker restart"