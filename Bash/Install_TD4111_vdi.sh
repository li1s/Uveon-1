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
echo "=====         Установка  Termidesk редакции 4.1.1                      ====="
echo "============================================================================"


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
termidesk-vdi       termidesk-vdi/dbhost    string 10.110.55.43
# Имя базы данных Termidesk:
termidesk-vdi       termidesk-vdi/dbname    string termidesk
# Пользователь базы данных Termidesk:
termidesk-vdi       termidesk-vdi/dbuser    string termidesk
# Пароль базы данных Termidesk:
termidesk-vdi       termidesk-vdi/dbpass    string ksedimret
# ПАРАМЕТРЫ ПОДКЛЮЧЕНИЯ К СЕРВЕРАМ RABBITMQ
# RabbitMQ URL #1
termidesk-vdi   termidesk-vdi/rabbitmq_url1     password amqp://termidesk:ksedimret@10.110.55.49:5672/termidesk
# RabbitMQ URL #3
termidesk-vdi   termidesk-vdi/rabbitmq_url3     password
# RabbitMQ URL #2
termidesk-vdi   termidesk-vdi/rabbitmq_url2     password
# Choices: 1 amqp://termidesk:ksedimretk@10.110.55.49:5672/termidesk, 2 Empty, 3 Empty, Save
termidesk-vdi   termidesk-vdi/rabbitmq_select   select Save
# Role for install
termidesk-vdi   termidesk-vdi/roles    string Broker
EOF
msg_info "Считываем файл ответов"
sudo debconf-set-selections answer &>>/dev/null
msg_ok "Файл ответов считан"

msg_info "Устанавливаем Termidesk"
sudo apt install -y ./home/astra/termidesk-vdi_4.1-astra17_amd64.deb &>/dev/null
msg_ok "Установка Termidesk-VDI завершена"ды



msg_info "Вносим изменения в apache2.conf"
sudo sed -i "s@.*AstraMode.*on.*@AstraMode off@g" /etc/apache2/apache2.conf
sudo systemctl restart apache2 
msg_ok "Изменения в apache2.conf внесены"


echo "============================================================================"
echo "=====            Установка  Termidesk 4.1 завершена                    ====="
echo "=====    Для доступа требуется перейти в web браузере по адресу:       ====="
echo "=====    https://<FQDN сервера termidesk> && https://<ipaddress>       ====="
echo "============================================================================"
