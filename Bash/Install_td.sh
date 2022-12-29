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
echo "=====  Шаг 3: Посмотрим редакцию ОС ALCE, для этого воспользуемся      ====="
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
echo "=====  Шаг 4:     Устанавливаем СУБД PostgreSQL                        ====="
echo "=====                                                                  ====="
echo "=====  Для этого используем команду: sudo apt install -y postgresql    ====="
sleep 3
sudo apt install -y postgresql
sleep 1
echo "===== Термидеск требует наличия предварительно настроенной БД          ====="
sleep 1
echo "===== Переключаемся на пользователя postgres (через пользователя root) ====="
sleep 1
echo "===== Запускаем терминальный клиент СУБД Postgre командой:  psql       ====="
sleep 1
echo "===== Используя интерактивный интерфейс терминального клиента СУБД     ====="
sleep 2
echo "===== Создаем базу данных для Термидеск командой:                      ====="
sleep 1
echo "===== CREATE DATABASE termidesk LC_COLLATE 'ru_RU.utf8' LC_CTYPE 'ru_RU.utf8'TEMPLATE template0; ====="
sleep 2
sudo su postgres -c "psql -c \"CREATE DATABASE termidesk LC_COLLATE 'ru_RU.utf8' LC_CTYPE 'ru_RU.utf8' TEMPLATE template0;\" 2>>/dev/null"
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
sleep 2
echo "===== Выдаем права пользователю termidesk на базу данных командой:     ====="
sleep 1
echo "===== GRANT ALL PRIVILEGES ON DATABASE termidesk TO termidesk;         ====="
sleep 2
sudo su postgres -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE termidesk TO termidesk;\" 2>>/dev/null"
echo "============================================================================"
sleep 3
echo "============================================================================"
echo "=====  Шаг 5:      Приступаем к установке пакета Termidesk-vdi         ====="
echo "=====                                                                  ====="
echo "===== Для этого выполним команду: sudo apt install termidesk-vdi       ====="
sleep 2
if [ "$(ls -1 termi*.deb|tail -n1)" ]; then
        #Эта команда работает, если предварительно положить в каталог со скриптом пакет с Термидеском
        sudo apt install -y ./$(ls -1 termi*.deb|tail -n1)
else
        #Установка из репозитория
        sudo apt install -y termidesk-vdi
fi
echo "============================================================================"
sleep 3
echo "============================================================================"
echo "=====  Шаг 6:  Вносим изменения в файл /etc/apache2/apache2.conf       ====="
echo "=====  В файле apache2.conf требуется изменить                         ====="
echo "=====  В поле Astra Security                                           ====="
echo "=====  Значение AstraMode off на AstraMode on                          ====="
sleep 2
sudo sed -i "s@.*AstraMode.*on.*@AstraMode off@g" /etc/apache2/apache2.conf
sudo systemctl restart apache2
echo "============================================================================"
sleep 2
echo "============================================================================"
echo "=====  Шаг 7:    Запускаем службы Termidesk                            ====="
echo "=====                                                                  ====="
sleep 2
echo "=====    Запускаем службу брокера подключений  / termidesk-vdi         ====="
sleep 2
echo "=====    Запускаем службу планировщика заданий / termidesk-taskman     ====="
sleep 2
echo "=====    Запускаем службу шлюза подключений    / termidesk-wsproxy     ====="
sleep 2
sudo systemctl enable termidesk-vdi termidesk-taskman termidesk-wsproxy
sudo systemctl start termidesk-vdi termidesk-taskman termidesk-wsproxy

echo "============================================================================"
echo "=====          Установка  Termidesk стандартной редакции завершена     ====="
echo "=====    Для доступа требуется перейти в web браузере по адресу:       ====="
echo "=====    https://<FQDN сервера termidesk> && https://<ipaddress>       ====="
echo "============================================================================"
