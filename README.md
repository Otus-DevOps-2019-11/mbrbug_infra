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
