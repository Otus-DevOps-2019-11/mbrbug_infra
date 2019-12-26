#!/bin/bash
wget -qO - https://www.mongodb.org/static/pgp/server-3.2.asc | apt-key add -
echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list
apt update
apt install -y ruby-full ruby-bundler build-essential mongodb-org
systemctl start mongod && systemctl enable mongod
cd /home/locladmn
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install
puma -d
