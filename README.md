# mbrbug_infra
mbrbug Infra repository

### №5 Знакомство с облачной инфраструктурой и облачными сервисами.
<details>
<summary>Знакомство с облачной инфраструктурой и облачными сервисам</summary>

#### Создание виртуальных машин в GCP

Использование приватного/публичного ключей SSH, проброс ключей
ssh-keygen, ssh-agent, ssh-add

Создание vpn сервера Pritunl на bastion хосте

Самостоятельное задание:
Исследовать способ подключения к someinternalhost в одну команду:

Решение:
`ssh -t -A -i ~/.ssh/locladmn locladmn@104.198.142.243 ssh someinternalhost`

Дополнительное задание:
Предложить вариант решения для подключения из консоли при помощи команды вида ssh someinternalhost из локальной консоли
рабочего устройства, чтобы подключение выполнялось по алиасу someinternalhost

Решение:
Добавить в `~/.ssh/config`

```
Host someinternalhost
HostName 104.198.142.243
User locladmn
IdentityFIle ~/.ssh/locladmn
ForwardAgent yes
RemoteCommand ssh someinternalhost
RequestTTY force
```

#### Данные для проверки cloud-bastion:

bastion_IP = 104.198.142.243
someinternalhost_IP = 10.128.0.3
</details>

### №6 Основные сервисы Google Cloud Platform (GCP).
<details>
<summary>Основные сервисы Google Cloud Platform (GCP).</summary>

Цели занятия
Способы управления ресурсами в GCP.

#### данные для проверки

testapp_IP = 35.222.255.111
testapp_port = 9292

#### Команда для запуска автоматического создания инстанса gcloud

```gcloud compute instances create reddit-app \
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
```

##### или

```gcloud compute instances create reddit-app \
--boot-disk-size=10GB \
--image-family ubuntu-1604-lts \
--image-project=ubuntu-os-cloud \
--machine-type=g1-small \
--tags puma-server \
--restart-on-failure \
--metadata-from-file startup-script=startupscript.sh
```

##### или

```gcloud compute instances create reddit-app \
--boot-disk-size=10GB \
--image-family ubuntu-1604-lts \
--image-project=ubuntu-os-cloud \
--machine-type=g1-small \
--tags puma-server \
--restart-on-failure \
--metadata startup-script-url=gs://mbrbucket/startupscript.sh
```

#### firewall rule

`gcloud compute firewall-rules create default-puma-server --allow tcp:9292 --target-tags 'puma-server' --source-ranges 0.0.0.0/0`
</details>

### №7 Модели управления инфраструктурой Packer.
<details>
  <summary>Модели управления инфраструктурой Packer</summary>

##### Цели занятия
Изучение packer. Команды, синтаксис, конфигурационные файлы.

Скачиваем Packer `https://www.packer.io/downloads.html`

Распаковываем в папки из переменной окружения PATH.

Создаем Application Default Credentials (ADC) `gcloud auth application-default login`
Создаем Packer template вида ubuntu16.json
```
{
    "variables":
       {
            "machine_type": "f1-micro"
            ...
       },

    "builders": [
        {
            "type": "googlecompute"
            "project_id": "{{ user `project_id` }}",
            "image_name": "reddit-full-{{timestamp}}",
            "machine_type": "{{ user `machine_type` }}"
        }
    ],
    "provisioners": [
        {
            "type": "shell",
            "script": "script.sh",
            "execute_command": "sudo {{.Path}}"
        }
        ...
    ]
}
```
variables - переменные
builders - секция отвечает за создание образа
provisioners - секция отвечает за изменение образа (софт, настройки и конфигурация)

`gcloud projects list`
Проверка конфига `packer validate ubuntu16.json`
Сборка образа `packer build ubuntu16.json`

#### Самостоятельное задание
Используем пользовательские переменные:
в секции
```{
    "variables": {
            "machine_type": "f1-micro"
  }
```
или
в файле variables.json
```
{
  "project_id": "infra-123456",
  "source_image_family": "ubuntu-1604-lts"
}
```
файл указывается параметром `-var-file=variables.json`

#### Задание со *
##### "Запекаем" образ - добавляем в образ приложение, зависимости и конфиги
Используем `"source_image_family": "reddit-base"`
Для запуска puma используем systemd.unit
```
[Unit]
Description=Puma Server
After=network.target
Requires=network.target

[Service]
ExecStart=/usr/local/bin/puma -C /var/lib/gems/2.3.0/gems/puma-3.10.0/lib/puma.rb --dir /home/appuser/reddit
TimeoutSec=15
Restart=always

[Install]
WantedBy=multi-user.target
```
##### Создание VM из образа через скрипт, используя gcloud
```
#!/bin/bash
gcloud compute instances create reddit-app \
> --boot-disk-size=10GB \
> --image-family reddit-full \
> --machine-type=g1-small \
> --tags puma-server \
> --restart-on-failure
 ```
</details>

### №8 Практика IaC с использованием Terraform.
<details>
  <summary>Практика IaC с использованием Terraform</summary>

##### Цели занятия
 Изучение Terraform. Команды, синтаксис, конфигурационные файлы.
 Скачиваем Terraform, распаковываем в путь из окружения PATH
 Создаем main.tf c провайдером google и ресурсами вида:
 ```
 resource "google_compute_instance" "app" {
 name = "reddit-app"
 machine_type = "g1-small"
 zone = "europe-west1-b"
 boot_disk {
 initialize_params {
 image = "reddit-base"
 }
 }
 network_interface {
 network = "default"
 access_config {}
 }
 }
 ```
###### работа с ключами SSH
 ```
 resource "google_compute_instance" "app" {
 ...
 metadata = {
 # путь до публичного ключа
 ssh-keys = "appuser:${file("~/.ssh/appuser.pub")}"
 }
 ...
 }
 ```
###### работа с портами
 ```
 resource "google_compute_firewall" "firewall_puma" {
 name = "allow-puma-default"
 # Название сети, в которой действует правило
 network = "default"
 # Какой доступ разрешить
 allow {
 protocol = "tcp"
 ports = ["9292"]
 }
 # Каким адресам разрешаем доступ
 source_ranges = ["0.0.0.0/0"]
 # Правило применимо для инстансов с перечисленными тэгами
 target_tags = ["reddit-app"]
 }

 ```
###### работа с провиженерами
 ```
 provisioner "file" {
 source = "files/puma.service"
 destination = "/tmp/puma.service"
 }
 ```
###### работа с variables
```
variable project {
description = "Project ID"
}
variable region {
description = "Region"
# Значение по умолчанию
default = "europe-west1"
}
```
```
provider "google" {
version = "2.15.0"
project = var.project
region = var.region
}
```
##### Задание со *
Добавление ключей для нескольких пользователей через sshkeys
при добавлении ключа через веб-интерфейс ключ не виден в Terraform
##### Задание с **
Создание балансировщика и использование и использование параметра count

```
resource "google_compute_target_pool" "reddit-app-target-pool" {
  name = "reddit-app-target-pool"

  instances = google_compute_instance.app[*].self_link

  health_checks = [
    google_compute_http_health_check.reddit-http-hc.name,
  ]
}

resource "google_compute_http_health_check" "reddit-http-hc" {
  name                = "reddit-http-hc"
  timeout_sec         = 1
  check_interval_sec  = 1
  healthy_threshold   = 4
  unhealthy_threshold = 5
  port                = 9292

}

resource "google_compute_forwarding_rule" "reddit-fr" {
  name                  = "reddit-fr"
  region                = var.region
  load_balancing_scheme = "EXTERNAL"
  target                = google_compute_target_pool.reddit-app-target-pool.self_link
  port_range            = 9292
}
```
```
resource "google_compute_instance" "app" {
  count        = var.count_inst
  name         = "reddit-app${count.index + 1}"
```
</details>

### №9 Принципы организации инфраструктурного кода и работа над инфраструктурой в команде на примере Terraform.

##### Цели занятия
Изучение Terraform. Команды, синтаксис, конфигурационные файлы.

если ресурс уже существует, его можно импортировать в terraform
команда `terraform import google_compute_firewall.firewall_ssh default-allow-ssh`

ресурс ip-адреса
```resource "google_compute_address" "app_ip" {
name = "reddit-app-ip"
}
```
Зависимости ресурсов, явные и неявные
`depends_on`

Модули terraform (отдельная папка, файлы main, variables, outputs)
ссылка на модуль в main.tf
```
module "app" {
source = "./modules/app"
public_key_path = "${var.public_key_path}"
zone = "${var.zone}"
app_disk_image = "${var.app_disk_image}"
}
```
ссылка на выходную переменную модуля
```
output "app_external_ip" {
value = "${module.app.app_external_ip}"
}
```
параметризация модулей, input переменные
terraform/vpc/main.tf
`source_ranges = "${var.source_ranges}"`
terraform/vpc/variables.tf
```
variable source_ranges {
description = "Allowed IP addresses"
default = ["0.0.0.0/0"]
}
```
terraform/main.tf
```
module "vpc" {
source = "modules/vpc"
source_ranges = ["80.250.215.124/32"]
}
```
##### Реестр модулей HashiCorp
```
module "storage-bucket" {
  source  = "SweetOps/storage-bucket/google"
  version = "0.3.0"
  name        = "mbrbug-bucket-reddit-app"
  location    = "europe-west1"
}
```
##### Хранение стайт файла в бекенде
```
terraform {
  backend "gcs" {
    bucket  = "mbrbug-bucket-reddit-app"
    prefix  = "prod"
  }
}
```
##### if statement in terraform
 задаем переменную boolean в variables.tf модуля
 ```
 variable app_provisioner {
  description = "turn on off puma provisioner"
 }
 ```
 задаем значение переменной в main.tf root модуля
 ```
 module "app" {
   ...
   app_provisioner = true
 }
 ```
 в main.tf модуля app задаем два идентичных ресурса с разными именами и различием в проверке переменной
 ```
 count = var.app_provisioner ? 0 : 1
 ```
 или
 ```
count = var.app_provisioner ? 0 : 1
 ```
