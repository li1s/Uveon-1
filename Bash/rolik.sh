#!/bin/bash
echo "===     Имя машины     ==="
sleep 2
echo "cat /etc/hostname"
cat /etc/hostname
sleep 3

echo "===     Файл /etc/hosts    ===" 
sleep 2
echo "cat /etc/hosts"
cat /etc/hosts
sleep 3

echo "===     Файл /etc/resolv.conf    ===" 
sleep 2
echo "cat /etc/resolv.conf"
cat /etc/resolv.conf
sleep 3

echo "===    Сетевые настройки     ==="
echo "cat /etc/network/inerfaces"
cat /etc/network/interfaces
sleep 3

echo "===    Обновление репозиториев и установка свежих обновлений   ==="
sleep 2
echo "sudo apt update"
sudo apt update

echo "sudo apt dist-upgrade"
sudo apt dist-upgrade 

echo "===    Устанавливаем пакет     ==="
echo "===    astra-freeipa-client    ==="
sleep 2
echo sudo apt install astra-freeipa-client postgresql -y
sudo apt install astra-freeipa-client postgresql -y
sleep 2


echo "===    Вводим ВРМ в домен FreeIpa    ==="
sleep 2
echo sudo astra-freeipa-client -d dvis.local -u admin
sudo astra-freeipa-client -d dvis.local -u admin
sleep 2


echo "===    Проверяем ввод в домен    ==="
echo sudo astra-freeipa-client -i
sleep 3
sudo astra-freeipa-client -i
sleep 1

echo "===    Выполняем kinit admin     ==="
echo sudo kinit admin
sleep 2
sudo kinit admin
sleep 2

echo "===    Создаем сервисный аккаунт на КД FreeIpa    ==="
sleep 2
echo sudo ipa service-add HTTP/termidesk.dvis.uveon
sudo ipa service-add HTTP/termidesk.dvis.uveon
sleep 2

echo "===     Создаем файл ключей keytab    ==="
sleep 2
echo sudo ipa-getkeytab -s tstb06-ipa01.dvis.uveon -p HTTP/termidesk.dvis.uveon -k /home/astra/termidesk.keytab
sudo ipa-getkeytab -s tstb06-ipa01.dvis.uveon -p HTTP/termidesk.dvis.uveon -k /home/astra/termidesk.keytab
sleep 2

echo "===    Устанавливаем пакет     ==="
echo "===        postgresql          ==="
sleep 2
echo sudo apt install postgresql -y
sudo apt install postgresql -y
sleep 2

echo "===    Создаем базу данных termidesk   === "
sleep 2
echo "sudo su postgres -c "psql -c \"CREATE DATABASE termidesk LC_COLLATE 'ru_RU.utf8' LC_CTYPE 'ru_RU.utf8' TEMPLATE template0;\"""
sudo su postgres -c "psql -c \"CREATE DATABASE termidesk LC_COLLATE 'ru_RU.utf8' LC_CTYPE 'ru_RU.utf8' TEMPLATE template0;\""
sleep 2

echo "===    Создаем пользователя базы данных termidesk с паролем "ksedimret"  === "
sleep 2
echo "sudo su postgres -c "psql -c \"CREATE USER termidesk WITH PASSWORD 'ksedimret';\"""
sudo su postgres -c "psql -c \"CREATE USER termidesk WITH PASSWORD 'ksedimret';\""
sleep 2

echo "===    Выдаем права пользователю termidesk на базу termidesk    === "
sleep 2
echo "sudo su postgres -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE termidesk TO termidesk;\"""
sudo su postgres -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE termidesk TO termidesk;\""
sleep 2

echo "===    Вносим изменения в msswitch.conf      ==="
sleep 2
sudo sed -i "s@.*zero_if_notfound.*no.*@zero_if_notfound: yes@g" /etc/parsec/mswitch.conf
sleep 2


echo "===    Устанавливаем Termidesk For Astra c диска    === "
sleep 2
echo sudo apt install termidesk-for-astra
sudo apt install termidesk-for-astra
sleep 2


echo "===    Вносим изменения в apache2.conf      ==="
sleep 2
sudo sed -i "s@.*AstraMode.*on.*@AstraMode off@g" /etc/apache2/apache2.conf # ^57&Fr0d)<kz@Sh0n
echo "===    Перезапускаем службу Apache2         ==="
sleep 2
sudo systemctl restart apache2
sudo systemctl daemon-reload

echo "===     Запускаем роли Termidesk            ==="
sleep2

echo "===     Запускаем роль termidesk-vdi        ==="
sleep 2
echo sudo systemctlctl enable termidesk-vdi.service
systemctlctl enable termidesk-vdi.service
sleep 2
echo sudo systemctlctl start termidesk-vdi.service
sleep 2
systemctlctl start termidesk-vdi.service
sleep 2


echo "===     Запускаем роль termidesk-taskman    ==="
sleep 2
echo sudo systemctlctl enable termidesk-taskman.service
systemctlctl enable termidesk-taskman.service
sleep 2
echo sudo systemctlctl start termidesk-taskman.service
systemctlctl start termidesk-vdi.service
sleep 2


echo "===     Запускаем роль termidesk-wsproxy    ==="
sleep 2
echo sudo systemctlctl enable termidesk-wsproxy.service
systemctl enable termidesk-wsproxy.service
sleep 2
echo sudo systemctlctl start termidesk-wsproxy.service
systemctl start termidesk-wsproxy.service
sleep 2

echo "===     Проверяем статус служб             ==="
sleep 2
echo systemctlctl status -a | grep termidesk
systemctl status -a | grep termidesk



