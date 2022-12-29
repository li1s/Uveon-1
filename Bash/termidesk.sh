echo "================================================="
echo "===   Установка  Termidesk                    ==="
echo "================================================="

echo "===    Вносим изменения в msswitch.conf       ==="
sudo sed -i "s@.*zero_if_notfound.*no.*@zero_if_notfound: yes@g" /etc/parsec/mswitch.conf

echo "===       Устанавливаем базу данных           ==="
sudo apt install -y postgresql
sudo su postgres -c "psql -c \"CREATE DATABASE termidesk LC_COLLATE 'ru_RU.utf8' LC_CTYPE 'ru_RU.utf8' TEMPLATE template0;\""
sudo su postgres -c "psql -c \"CREATE USER termidesk WITH PASSWORD 'ksedimret';\""
sudo su postgres -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE termidesk TO termidesk;\""

sudo debconf-set-selections answer

if [ "$(ls -1 termi*.deb|tail -n1)" ]; then
        #Эта команда работает, если предварительно положить в каталог со скриптом пакет с Термидеском
        sudo dpkg -i $(ls -1 termi*.deb|tail -n1)
else
        #Установка из репозитория
        sudo apt install -y termidesk-vdi
fi
sudo /opt/termidesk/sbin/termidesk-vdi-manage migrate
sudo /opt/termidesk/sbin/termidesk-vdi-manage createcachetable

echo "===    Вносим изменения в apache2.conf      ==="
sudo sed -i "s@.*AstraMode.*on.*@AstraMode off@g" /etc/apache2/apache2.conf
sudo systemctl restart apache2

echo "===      Запускаем службы Termidesk         ==="
sudo systemctl enable termidesk-vdi termidesk-taskman termidesk-wsproxy
sudo systemctl start termidesk-vdi termidesk-taskman termidesk-wsproxy
