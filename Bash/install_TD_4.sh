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
  echo -e "${BFR} ${CM} ${GN}${msg}${CL}"
}
echo "============================================================================"
echo "=====          Установка  Termidesk стандартной редакции               ====="
echo "============================================================================"

msg_info "Проверяем наличие репозитория Termidesk"
for apt in $(find /etc/apt/ -name \*.list); do
        repos+=$(grep -Po "(?<=^deb\s).*?(?=#|$)" $apt)
done

for repo in ${repos[*]}; do
        if [[ $repo == *"termidesk"* ]]; then
         tdskrepo+="1"
        else
         tdskrepo+="0"
        fi
done

if [[ "${tdskrepo[*]}" =~ "1" ]]; then
       printf "\e[32m Репозиторий Termidesk настроек верно! \n"
        repostat="Passed"
else
          
        sudo sh -c 'echo "deb https://termidesk.ru/repos/astra $(lsb_release -cs) non-free" > /etc/apt/sources.list.d/termidesk.list'
        wget -O - https://termidesk.ru/repos/astra/GPG-KEY-PUBLIC | sudo apt-key add -    
        printf "\e[32m Репозиторий Termidesk успешно доабвлен! \n" 

fi

msg_info "Устанавливаем обновления используя команды apt update"
sudo apt update &>/dev/null
sudo apt dist-upgrade -y &>/dev/null
msg_ok "Обновления успешно установлены"

msg_info "Устанавливаем СУБД PostgreSQL командой: sudo apt install postgresql"
sudo apt install postgresql -y &>/dev/null
msg_ok "СУБД PostgreSQL успешно установлена"

msg_info "Создаем БД Termidesk \n"
echo  "Введите имя создаваемой базы данных: "
read databasename
sudo su postgres -c "psql -c \"CREATE DATABASE $databasename LC_COLLATE 'ru_RU.utf8' LC_CTYPE 'ru_RU.utf8' TEMPLATE template0;\" 2>>/dev/null"
msg_ok "База данных успешно создана"

msg_info "Coздаем пользователя \n"
echo "Введите пользователя базы данных: "
read databaseuser
echo "Введите пароль пользователя: $databaseuser"
read userpassword
sudo su postgres -c "psql -c \"CREATE USER $databaseuser WITH PASSWORD '$userpassword';\" 2>>/dev/null"
msg_ok "Пользователь создан"

msg_info "Выдаем права пользователю $databaseuser на базу данных $databasename"
sudo su postgres -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE $databasename TO $databaseuser;\" 2>>/dev/null"
msg_ok "Права пользователю выданы"

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
            "password_hash": "pnXiDJtUdk7ZceL9iOqx44PeDgRa+X1+eIq+7wf/PTONLb1h",
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
sudo systemctl restart rabbitmq-server
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
termidesk-vdi       termidesk-vdi/dbname    string $databasename
# Пользователь базы данных Termidesk:
termidesk-vdi       termidesk-vdi/dbuser    string $databaseuser
# Пароль базы данных Termidesk:
termidesk-vdi       termidesk-vdi/dbpass    string $userpassword
# ПАРАМЕТРЫ ПОДКЛЮЧЕНИЯ К СЕРВЕРАМ RABBITMQ
# RabbitMQ URL #1
termidesk-vdi   termidesk-vdi/rabbitmq_url1     password amqp://termidesk:termidesk@127.0.0.1:5672/termidesk
# RabbitMQ URL #3
termidesk-vdi   termidesk-vdi/rabbitmq_url3     password
# RabbitMQ URL #2
termidesk-vdi   termidesk-vdi/rabbitmq_url2     password
# Choices: 1 amqp://termidesk:termidesk@127.0.0.1:5672/termidesk, 2 Empty, 3 Empty, Save
termidesk-vdi   termidesk-vdi/rabbitmq_select   select Save
#Временные переменные для промежуточного хранения параметров подключения к серверу RabbitMQ, из которых создаются строки  termidesk-vdi/rabbitmq_url1, termidesk-vdi/rabbitmq_url2, termidesk-vdi/rabbitmq_url3
# Termidesk RabbitMQ host
termidesk-vdi   termidesk-vdi/rabbitmq_host     string 127.0.0.1
# Termidesk RabbitMQ port
termidesk-vdi   termidesk-vdi/rabbitmq_port     string 5672
# Termidesk RabbitMQ user
termidesk-vdi   termidesk-vdi/rabbitmq_user     string termidesk
# Termidesk RabbitMQ pass
termidesk-vdi   termidesk-vdi/rabbitmq_pass     string termidesk
# Termidesk RabbitMQ Virtual Host
termidesk-vdi   termidesk-vdi/rabbitmq_vhost    string termidesk
EOF
msg_ok "Файл ответов создан"

msg_info "Считываем файл ответов"
sudo debconf-set-selections answer &>>/dev/null
msg_ok "Файл считан"

msg_info "Устанавливаем Termidesk"
if [ "$(ls -1 termi*.deb|tail -n1)" ]; then
        #Эта команда работает, если предварительно положить в каталог со скриптом пакет с Термидеском
        sudo apt install -y ./$(ls -1 termi*.deb|tail -n1) &>/dev/null
else
        #Установка из репозитория
        sudo apt install -y termidesk-vdi &>/dev/null
fi
msg_ok "Установка завершена"


msg_info "Вносим изменения в apache2.conf"
sudo sed -i "s@.*AstraMode.*on.*@AstraMode off@g" /etc/apache2/apache2.conf
sudo systemctl restart apache2 
msg_ok "Изменения внесены"


msg_info "Запускаем службы Termidesk"
sudo systemctl enable termidesk-vdi termidesk-taskman termidesk-wsproxy termidesk-celery-beat.service termidesk-celery-worker.service	
sudo systemctl start termidesk-vdi termidesk-taskman termidesk-wsproxy termidesk-celery-beat.service termidesk-celery-worker.service	
msg_ok "Службы запущены"

echo "============================================================================"
echo "=====          Установка  Termidesk стандартной редакции завершена     ====="
echo "=====    Для доступа требуется перейти в web браузере по адресу:       ====="
echo "=====    https://<FQDN сервера termidesk> && https://<ipaddress>       ====="
echo "============================================================================"
