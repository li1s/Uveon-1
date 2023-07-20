#!/bin/bash

if [ "$VERBOSE" == "yes" ]; then set -x; fi
YW=$(echo "\033[33m")
RD=$(echo "\033[01;31m")
BL=$(echo "\033[36m")
GN=$(echo "\033[1;92m")
CL=$(echo "\033[m")
RETRY_NUM=10
RETRY_EVERY=3
NUM=$RETRY_NUM
CM="${GN}✓${CL}"
CROSS="${RD}✗${CL}"
BFR="\\r\\033[K"
HOLD="-"
set -o errexit
set -o errtrace
set -o nounset
set -o pipefail
shopt -s expand_aliases
alias die='EXIT=$? LINE=$LINENO error_exit'
trap die ERR

function msg_info() {
  local msg="$1"
  echo -ne " ${HOLD} ${YW}${msg}..."
} 

function msg_ok() {
  local msg="$1"
  echo -e "${BFR} ${CM} ${RD}${msg}${CL}"
}

function msg_error() {
    local msg="$1"
    echo -e "${BFR} ${CM} ${GN}${msg}${CL}"
}
echo "============================================================================"
echo "=====         Установка  Termidesk редакции 4.1                        ====="
echo "============================================================================"

msg_info "Устанавливаем обновления"
sudo apt update &>/dev/null
#sudo apt dist-upgrade -y &>/dev/null
astra-update -A -r -T
msg_ok "Обновления успешно установлены"

msg_info "Устанавливаем СУБД PostgreSQL"
sudo apt install postgresql -y &>/dev/null
msg_ok "СУБД PostgreSQL успешно установлена"

msg_info "Создаем БД: termidesk \n"
sudo su postgres -c "psql -c \"CREATE DATABASE termidesk LC_COLLATE 'ru_RU.utf8' LC_CTYPE 'ru_RU.utf8' TEMPLATE template0;\" &>>/dev/null" || echo "База данных с таким именем уже существует"
msg_ok "База данных: termidesk успешно создана"

msg_info "Coздаем пользователя: termidesk"
sudo su postgres -c "psql -c \"CREATE USER termidesk WITH PASSWORD 'ksedimret';\" &>>/dev/null" || echo "Пользователь с таким именем уже существует"
msg_ok "Пользователь termidesk создан"

msg_info "Выдаем права пользователю termidesk на базу данных termidesk"
sudo su postgres -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE termidesk TO termidesk;\" &>>/dev/null"
msg_ok "Права пользователю termidesk на БД termidesk выданы"

msg_info "Установка RabbitMQ-server"
sudo apt install -y rabbitmq-server &>/dev/null
msg_ok "Установка RabbitMQ-server выполнена успешно"

msg_info "Настройка RabbitMQ-server"
sudo mkdir -p /etc/rabbitmq
sudo touch /etc/rabbitmq/rabbitmq.conf
sudo touch /etc/rabbitmq/definitions.json
sudo chown rabbitmq:rabbitmq /etc/rabbitmq/rabbitmq.conf
sudo chown rabbitmq:rabbitmq /etc/rabbitmq/definitions.json
sudo chmod 0646 /etc/rabbitmq/rabbitmq.conf
sudo chmod 0646 /etc/rabbitmq/definitions.json
sudo cat << EOF >> /etc/rabbitmq/rabbitmq.conf
# ======================================= Management section ================ 
## Preload schema definitions from the following JSON file. Related doc guide: 	https://rabbitmq.com/management.html#load-definitions.
##
# management.load_definitions = /path/to/exported/definitions.json
management.load_definitions = /etc/rabbitmq/definitions.json
EOF

sudo cat << EOF >> /etc/rabbitmq/definitions.json
{
    "rabbit_version": "3.7.8",
    "users": [
        {
            "name": "termidesk",
            "password_hash": "x6Z6bT2JlakSR9JiUZmCIjhYGR+10PRRu7CZljrV5FwUVcTh",
            "hashing_algorithm": "rabbit_password_hashing_sha256",
            "tags": ""
        },
        {
            "name": "admin",
            "password_hash": "FXQ9WFNSrsGwRki9BT2dCITnsDwYu2lsy7BEN7+UncsPzCDZ",
            "hashing_algorithm": "rabbit_password_hashing_sha256",
            "tags": "administrator"
        }
    ],
    "vhosts": [
        {
            "name": "/"
        },
        {
            "name": "termidesk"
        }
    ],
    "permissions": [
        {
            "user": "termidesk",
            "vhost": "termidesk",
            "configure": ".*",
            "write": ".*",
            "read": ".*"
        },
        {
            "user": "admin",
            "vhost": "termidesk",
            "configure": ".*",
            "write": ".*",
            "read": ".*"
        }
    ],
    "topic_permissions": [
        {
            "user": "termidesk",
            "vhost": "termidesk",
            "exchange": "",
            "write": ".*",
            "read": ".*"
        }
    ],
    "parameters": [],
    "global_parameters": [
        {
            "name": "cluster_name",
            "value": "rabbit@rabbitmq"
        }
    ],
    "policies": [],
    "queues": [],

        "exchanges": [],
        "bindings": []
}
EOF


sudo chmod 0644 /etc/rabbitmq/rabbitmq.conf
sudo chmod 0644 /etc/rabbitmq/definitions.json

sudo rabbitmq-plugins enable rabbitmq_management
sudo systemctl restart rabbitmq-server || echo "Возникла ошибка, выполните команду journalctl -xe"
msg_ok "Настройка RabbitMQ-server выполнена успешно"

msg_info "Создаем файл ответов для тихой установки Termidesk"
cat << EOF >> answer
#
termidesk-vdi        termidesk-vdi/yes     boolean false
# Пользовательская лицензияx
termidesk-vdi       termidesk-vdi/text-eula note
# Вы принимаете условия пользовательской лицензии?
termidesk-vdi       termidesk-vdi/yesno-eula        boolean true
# true -  интерактивный режим. false - пакетный (тихий) режим:
termidesk-vdi       termidesk-vdi/interactive       boolean false
# ПАРАМЕТРЫ ПОДКЛЮЧЕНИЯ К СУБД
# Адрес сервера СУБД Termidesk:
termidesk-vdi       termidesk-vdi/dbhost    string 127.0.0.1
# Имя базы данных Termidesk:
termidesk-vdi       termidesk-vdi/dbname    string termidesk
# Пользователь базы данных Termidesk:
termidesk-vdi       termidesk-vdi/dbuser    string termidesk
# Пароль базы данных Termidesk:
termidesk-vdi       termidesk-vdi/dbpass    string ksedimret
# ПАРАМЕТРЫ ПОДКЛЮЧЕНИЯ К СЕРВЕРАМ RABBITMQ
# RabbitMQ URL #1
termidesk-vdi   termidesk-vdi/rabbitmq_url1     password amqp://termidesk:termidesk@127.0.0.1:5672/termidesk
# RabbitMQ URL #3
termidesk-vdi   termidesk-vdi/rabbitmq_url3     password
# RabbitMQ URL #2
termidesk-vdi   termidesk-vdi/rabbitmq_url2     password
# Choices: 1 amqp://termidesk:termidesk@127.0.0.1:5672/termidesk, 2 Empty, 3 Empty, Save
termidesk-vdi   termidesk-vdi/rabbitmq_select   select Save
# Role for install
termidesk-vdi   termidesk-vdi/roles    string Broker, Gateway, Task manager
EOF
msg_info "Считываем файл ответов"
sudo debconf-set-selections answer &>>/dev/null
msg_ok "Файл ответов считан"

msg_info "Устанавливаем Termidesk"
sudo apt install -y termidesk-vdi &>/dev/null
msg_ok "Установка Termidesk-VDI завершена"



msg_info "Вносим изменения в apache2.conf"
sudo sed -i "s@.*AstraMode.*on.*@AstraMode off@g" /etc/apache2/apache2.conf
sudo systemctl restart apache2 
msg_ok "Изменения в apache2.conf внесены"


echo "============================================================================"
echo "=====            Установка  Termidesk 4.1 завершена                    ====="
echo "=====    Для доступа требуется перейти в web браузере по адресу:       ====="
echo "=====    https://<FQDN сервера termidesk> && https://<ipaddress>       ====="
echo "============================================================================"
