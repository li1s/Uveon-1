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
sleep 3
echo "=====          Для начала посмотрим настройки машины                   ====="
echo "=====                                                                  ====="
sleep 2
echo "=====  Шаг 1:  Имя машины с помощью команды: hostname                  ====="
echo "=====                                                                  ====="
sleep 2
hostname
echo "============================================================================"
sleep 3
echo "============================================================================"
echo "=====  Шаг 2:  Посмотрим сетевые настройки                             ====="
echo "=====                                                                  ====="
sleep 1
echo "=====  для правильной работы требуется настройка статического IP       ====="
sleep 1
echo "=====  настройки сети вносим в:          /etc/network/interfaces       ====="
sleep 2
sudo cat /etc/network/interfaces
echo "============================================================================"
sleep 3
echo "============================================================================"
echo "=====  Шаг 3:  Посмотрим наличие официального репозитория Termidesk    ====="
echo "=====                                                                  ====="
sleep 1
echo "=====  Проверим добавлен ли официальный репозиторий Termidesk          ====="
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
        msg_ok "Репозиторий Termidesk настроек верно"
        #printf $green$"Репозиторий Termidesk настроек верно!\n"$reset
        repostat="Passed"
else

printf $red$"Репозиторий Termidesk не настроен.\n"$reset

printf $green$"Добавим официальный репозиторий Termidesk? \n"$reset

select answer in yes no quit

         do

case $answer in

        "yes")
                sudo sh -c 'echo "deb https://termidesk.ru/repos/astra $(lsb_release -cs) non-free" > /etc/apt/sources.list.d/termidesk.list'
                wget -O - https://termidesk.ru/repos/astra/GPG-KEY-PUBLIC | sudo apt-key add -      
                printf $green$"Репозиторий успешно добавлен \n"$reset  
                break
                ;;

        "no")

                echo "Для продолжения установки потребуется поместить файл Termidesk-vdi.deb в папку с установ
                break
                ;;
        "quit")
                break
                ;;
        *)
;;
                esac
        done

fi
sleep 2
echo "============================================================================"
echo "=====  Шаг 4: Посмотрим редакцию ОС ALCE, для этого воспользуемся      ====="
echo "=====                                                                  ====="
sleep 1
echo "=====            командой: sudo astra-modeswitch get                   ====="
sleep 1
echo "=====               вывод данной команды цифровой:                     ====="
sleep 1
echo "=====               0 - уровень защищенности "Орел"                      ====="
sleep 1
echo "=====               1 - уровень защищенности "Воронеж"                   ====="
sleep 1
echo "=====               2 - уровень защищенности "Смоленск"                  ====="
sleep 2
echo "===== В данном случае нас интересует: 0 - уровень защищенности "Орел"    ====="
sleep 2
sudo astra-modeswitch get
echo "============================================================================"
sleep 3
echo "============================================================================"
echo "=====  Шаг 5:     Устанавливаем СУБД PostgreSQL                        ====="
echo "=====                                                                  ====="
echo "=====  Для этого используем команду: sudo apt install -y postgresql    ====="
sleep 3
sudo apt install -y postgresql &>/dev/null
msg_ok "СУБД PostgreSQL-11 успешно установлена"
sleep 2
echo "===== Термидеск требует наличия предварительно настроенной БД          ====="
sleep 1
echo "===== Переключаемся на пользователя postgres (через пользователя root) ====="
sleep 1
echo "===== Запускаем терминальный клиент СУБД Postgres командой:  psql      ====="
sleep 1
echo "===== Используя интерактивный интерфейс терминального клиента СУБД     ====="
sleep 2
echo "===== Создаем базу данных для Термидеск командой:                      ====="
sleep 1
echo "CREATE DATABASE termidesk LC_COLLATE 'ru_RU.utf8' LC_CTYPE 'ru_RU.utf8'TEMPLATE template0;"
sleep 2
sudo su postgres -c "psql -c \"CREATE DATABASE termidesk LC_COLLATE 'ru_RU.utf8' LC_CTYPE 'ru_RU.utf8' TEMPLATE template0;\" 2>>/dev/null"
msg_ok "База данных c именем Termidesk успешно создана"
sleep 2
echo "===== Coздаем пользователя termidesk с паролём ksedimret командой:     ====="
sleep 1
echo "===== CREATE USER termidesk WITH PASSWORD 'ksedimret';                 ====="
sleep 1
echo "===== Заметим, что в приведенной команде имя пользователя и пароль     ====="
sleep 1
echo "===== Используются в качестве примера.                                 ====="
sleep 2
sudo su postgres -c "psql -c \"CREATE USER termidesk WITH PASSWORD 'ksedimret';\" 2>>/dev/null"
msg_ok "Пользователь Termidesk успешно создан"
sleep 2
echo "===== Выдаем права пользователю termidesk на базу данных командой:     ====="
sleep 1
echo "===== GRANT ALL PRIVILEGES ON DATABASE termidesk TO termidesk;         ====="
sleep 2
sudo su postgres -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE termidesk TO termidesk;\" 2>>/dev/null"
msg_ok "права пользователю termidesk на базу данных успешно выданы"
echo "============================================================================"
sleep 3
echo "============================================================================"
echo "=====  Шаг 6:      Приступаем к установке пакета Termidesk-vdi         ====="
echo "=====                                                                  ====="
echo "===== Для этого выполним команду: sudo apt install termidesk-vdi       ====="
sleep 1
echo "===== Во время установки в TUI (Text User Interfaces) потребуется:     ====="
sleep 1
echo "===== Указать IP address базы данных PostrgreSQL \ Имя базы данных     ====="
sleep 1
echo "===== Пользователя с паролем для подключения к базе данных             ====="
sleep 1
echo "===== Так как мы используем стандартные значения                       ====="
slepp 1
echo "===== На все вопросы мы нажимаем Enter                                 ====="
sleep 3
if [ "$(ls -1 termi*.deb|tail -n1)" ]; then
        #Эта команда работает, если предварительно положить в каталог со скриптом пакет с Термидеском
        sudo apt install -y ./$(ls -1 termi*.deb|tail -n1) 2>/dev/null
else
        #Установка из репозитория
        sudo apt install -y termidesk-vdi 2>/dev/null
fi
msg_ok "Termidesk-VDI успешно установлен"
echo "============================================================================"
sleep 3
echo "============================================================================"
echo "=====  Шаг 7:  Вносим изменения в файл /etc/apache2/apache2.conf       ====="
echo "=====  В файле apache2.conf требуется изменить                         ====="
echo "=====  В поле Astra Security                                           ====="
echo "=====  Значение AstraMode off на AstraMode on                          ====="
sleep 2
sudo sed -i "s@.*AstraMode.*on.*@AstraMode off@g" /etc/apache2/apache2.conf 
msg_ok "Изменения в файле apache2.conf внесены"
sudo systemctl restart apache2
msg_ok "Служба apache2.service перезапущена"
echo "============================================================================"
sleep 2
echo "============================================================================"
echo "=====  Шаг 8:    Запускаем службы Termidesk                            ====="
echo "=====                                                                  ====="
sleep 2
echo "=====    Запускаем службу брокера подключений  / termidesk-vdi         ====="
sudo systemctl enable termidesk-vdi
sudo systemctl start termidesk-vdi
msg_ok "Служба брокера подключений запущена"
sleep 2
echo "=====    Запускаем службу планировщика заданий / termidesk-taskman     ====="
sudo systemctl enable termidesk-taskman
sudo systemctl start termidesk-taskman
msg_ok "Служба планировщика заданий запущена"
sleep 2
echo "=====    Запускаем службу шлюза подключений    / termidesk-wsproxy     ====="
sudo systemctl enable termidesk-wsproxy
sudo systemctl start termidesk-wsproxy
msg_ok "Служба шлюза подключений запущена"
sleep 2
echo "============================================================================"
echo "=====          Установка  Termidesk стандартной редакции завершена     ====="
echo "=====    Для доступа требуется перейти в web браузере по адресу:       ====="
echo "=====    https://<FQDN сервера termidesk> && https://<ipaddress>       ====="
echo "============================================================================"
