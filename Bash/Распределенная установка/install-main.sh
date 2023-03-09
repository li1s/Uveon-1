#! /bin/bash
#
#-------Include files-------
# Указываем пути на файлы, которые потрубется в момент установки
source ~/keepalived.conf        # Файлы для настройки keepalived
source ~/notify.sh              # Скрипт для запуска служб
source ~/server/vdi.txt         # Список серверов c ролью TERMIDESK-VDI
source ~/server/tsk.txt         # Список серверов c ролью TERMIDESK-TASKMAN
source ~/server/wsproxy.txt     # Список серверов c ролью TERMIDESK-WSPROXY
source ~/server/pg.txt          # Список серверов c ролью PostgreSQL

#
# Начала запуска, предпологается наличие списка серверов на которых будет производиться установка 
#
# Установка начинается с установки Базы Данных, на том IP адрессе, который был указан в файле 
# pg.txt
# 

for i in (server/pg.txt);
    do 
        ssh u@"{$i}" << EOF
        sudo apt update &>/dev/null
        sudo apt dist-upgrade -y &>/dev/null
        sudo apt install postgresql -y &>/dev/null
        sudo su postgres -c "psql -c \"CREATE DATABASE termidesk LC_COLLATE 'ru_RU.utf8' LC_CTYPE 'ru_RU.utf8' TEMPLATE template0;\" &>>/dev/null"
        sudo su postgres -c "psql -c \"CREATE USER termidesk WITH PASSWORD 'ksedimret';\" &>>/dev/null"
        sudo su postgres -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE termidesk TO termidesk;\" &>>/dev/null"
        EOF
    done

