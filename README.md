# mbrbug_infra
mbrbug Infra repository

№5 Знакомство с облачной инфраструктурой и облачными сервисами.

Создание виртуальных машин в GCP

Использование приватного/публичного ключей SSH, проброс ключей
ssh-keygen, ssh-agent, ssh-add

Создание vpn сервера Pritunl на bastion хосте

Самостоятельное задание:
Исследовать способ подключения к someinternalhost в одну команду:

Решение:
ssh -t -A -i ~/.ssh/locladmn locladmn@104.198.142.243 ssh someinternalhost

Дополнительное задание:
Предложить вариант решения для подключения из консоли при помощи команды вида ssh someinternalhost из локальной консоли
рабочего устройства, чтобы подключение выполнялось по алиасу someinternalhost

Решение:
Добавить в ~/.ssh/config

Host someinternalhost
HostName 104.198.142.243
User locladmn
IdentityFIle ~/.ssh/locladmn
ForwardAgent yes
RemoteCommand ssh someinternalhost
RequestTTY force

Данные для проверки cloud-bastion:

bastion_IP = 104.198.142.243
someinternalhost_IP = 10.128.0.3

№6 Основные сервисы Google Cloud Platform (GCP).

Цели занятия
Способы управления ресурсами в GCP.

# данные для проверки

testapp_IP = 35.222.255.111
testapp_port = 9292

# Команда для запуска автоматического создания инстанса gcloud

gcloud compute instances create reddit-app \
--boot-disk-size=10GB \
--image-family ubuntu-1604-lts \
--image-project=ubuntu-os-cloud \
--machine-type=g1-small \
--tags puma-server \
--restart-on-failure \
--metadata startup-script='wget -qO - https://www.mongodb.org/static/pgp/server-3.2.asc | apt-key add -
echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list
apt update
apt install -y ruby-full ruby-bundler build-essential mongodb-org
systemctl start mongod && systemctl enable mongod
cd /home/locladmn
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install
puma -d'

#или

gcloud compute instances create reddit-app \
--boot-disk-size=10GB \
--image-family ubuntu-1604-lts \
--image-project=ubuntu-os-cloud \
--machine-type=g1-small \
--tags puma-server \
--restart-on-failure \
--metadata-from-file startup-script=startupscript.sh

#или

gcloud compute instances create reddit-app \
--boot-disk-size=10GB \
--image-family ubuntu-1604-lts \
--image-project=ubuntu-os-cloud \
--machine-type=g1-small \
--tags puma-server \
--restart-on-failure \
--metadata startup-script-url=gs://mbrbucket/startupscript.sh

# firewall rule

gcloud compute firewall-rules create default-puma-server --allow tcp:9292 --target-tags 'puma-server' --source-ranges 0.0.0.0/0
