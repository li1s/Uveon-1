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

echo "================================================="
echo "===   Установка  Termidesk                    ==="
echo "================================================="

msg_info "Устанавливаем обновления"
apt-get update &>/dev/null
msg_ok "Обновления успешно установлены"

msg_info "Устанавливаем СУБД PostgreSQL"
sudo apt install postgresql &>/dev/null
msg_ok "СУБД PostgreSQL успешно установлена"

msg_info "Создаем БД Termidesk"
echo  "Введите имя создаваемой базы данных: "
read databasename
sudo su postgres -c "psql -c \"CREATE DATABASE $databasename LC_COLLATE 'ru_RU.utf8' LC_CTYPE 'ru_RU.utf8' TEMPLATE template0;\" 2>>/dev/null"
msg_ok "База данных успешно создана"

msg_info "Coздаем пользователя termidesk с паролём ksedimret "
echo "Введите пользователя базы данных: "
read databaseuser
echo "Введите пароль пользователя: $databaseuser"
read userpassword
sudo su postgres -c "psql -c \"CREATE USER $databaseuser WITH PASSWORD '$userpassword';\" 2>>/dev/null"
msg_ok "Пользователь создан"

msg_info "Выдаем права пользователю termidesk на базу данных"
sudo su postgres -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE $database TO termidesk;\" 2>>/dev/null"
msg_ok "Права пользователю выданы"

msg_info "Создаем файл ответов для тихой установки Termidesk"
cat << EOF >> answer
#
termidesk-vdi        termidesk-vdi/yes     boolean false
# Пользовательская лицензия
termidesk-vdi       termidesk-vdi/text-eula note
# Вы принимаете условия пользовательской лицензии?
termidesk-vdi       termidesk-vdi/yes-eula        boolean true
# true -  интерактивный режим. false - пакетный (тихий) режим:
termidesk-vdi       termidesk-vdi/false       boolean true
# ПАРАМЕТРЫ ПОДКЛЮЧЕНИЯ К СУБД
# Адрес сервера СУБД Termidesk:
termidesk-vdi       termidesk-vdi/dbhost    string  127.0.0.1
# Имя базы данных Termidesk:
termidesk-vdi       termidesk-vdi/dbname    string  termidesk
# Пользователь базы данных Termidesk:
termidesk-vdi       termidesk-vdi/dbuser    string  termidesk
# Пароль базы данных Termidesk:
termidesk-vdi       termidesk-vdi/dbpass    string  ksedimret
EOF
msg_ok "Файл ответов создан"

msg_info "Считываем файл ответов"
sudo debconf-set-selections answer &>>/dev/null
msg_ok "Файл считан"

msg_info "Устанавливаем Termidesk"
sudo apt install -y ./$(ls -1 termi*.deb|tail -n1) &>>/dev/null
msg_ok "Установка завершена"


msg_info "Вносим изменения в apache2.conf"
sudo sed -i "s@.*AstraMode.*on.*@AstraMode off@g" /etc/apache2/apache2.conf
msg_ok "Изменения внесены"


msg_info "Запускаем службы Termidesk"
sudo systemctl enable termidesk-vdi termidesk-taskman termidesk-wsproxy
sudo systemctl start termidesk-vdi termidesk-taskman termidesk-wsproxy
msg_ok "Службы запущены"

echo "================================================="
echo "===   Установка  Termidesk  завершена         ==="
echo "================================================="