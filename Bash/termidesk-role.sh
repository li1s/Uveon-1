!#/bin/bash
echo "================================================="
echo "===   Установка  Termidesk c выбором роли     ==="
echo "================================================="
echo " "
echo "=== Введите FQDN машины для сервера Termidesk ==="
read hostname
sudo hostnamectl set-hostname $hostname

echo "=== Введите ip address  для сервера Termidesk ==="
read ipadr
echo "===     Введите ip address  gateway           ==="
read ipgateway
sudo echo auto eth0 >> /etc/network/interfaces
sudo echo iface eth0 inet static >> /etc/network/interfaces
sudo echo address $ipadr/24 >> /etc/network/interfaces
sudo echo $ipgateway >> /etc/network/interfaces

echo "===    Вносим изменения в msswitch.conf      ==="
sudo sed -i "s@.*zero_if_notfound.*no.*@zero_if_notfound: yes@g" /etc/parsec/mswitch.conf


echo "===       Устанавливаем базу данных?         ==="
select answer in yes no

do

case $role in

"yes")

    sudo apt install -y postgresql
    sudo su postgres -c "psql -c \"CREATE DATABASE termidesk LC_COLLATE 'ru_RU.utf8' LC_CTYPE 'ru_RU.utf8' TEMPLATE template0;\""
    sudo su postgres -c "psql -c \"CREATE USER termidesk WITH PASSWORD 'ksedimret';\""
    sudo su postgres -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE termidesk TO termidesk;\""
    ;;

"no")
    ;;
*)

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
sudo systemctl daemon-reload

echo "===     Выбираем роль для запуска          ==="
select role in wsproxy taskman vdi all quit; do

case $role in

  wsproxy)

     echo "Start & enable role $role"
     sudo systemctl enable termidesk-wsproxy
     sudo systemctl start termidesk-wsproxy
   ;;

  taskman)

     echo "Start & enable role $role"
     sudo systemctl enable termidesk-taskman
     sudo systemctl start termidesk-taskman
   ;;

  vdi)

     echo "Start & enable role $role"
     sudo systemctl enable termidesk-vdi
     sudo systemctl start termidesk-vdi
   ;;
   
   all)

     echo "Start & enable role $role"
     sudo systemctl enable termidesk-vdi
     sudo systemctl start termidesk-vdi
     sudo systemctl enable termidesk-taskman
     sudo systemctl start termidesk-taskman
     sudo systemctl enable termidesk-wsproxy
     sudo systemctl start termidesk-wsproxy
   ;;
   
   quit)

     echo "Start & enable role $role"
     break
   ;;
*)
echo "Недопустимая опция $role"
;;

  esac

done

echo "===      TERMIDESK установлен           ==="