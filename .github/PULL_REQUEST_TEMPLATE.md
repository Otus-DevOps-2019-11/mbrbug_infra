# Выполнено ДЗ №11

 - [x] Основное ДЗ №11
 - [x] Задание со *
 - [x] Задание со **

## В процессе сделано:
 - изучена работа с ролями
 - проект разбит на роли app, db, nginx
 - Работа с Ansible Vault
 - Работа с trytravis

## Как запустить проект:
 - запустить terraform apply (в нужном окружении)
 - запустить ansible-playbook clone.yml
 `ansible-playbook -i environments/stage/dyn_inv.sh playbooks/site.yml`

## Как проверить работоспособность:
 - http://app_external_ip

## PR checklist
 - [x] Выставил label с номером домашнего задания
 - [x] Выставил label с темой домашнего задания
