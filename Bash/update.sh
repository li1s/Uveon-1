#!/bin/bash
echo "================================================"
echo "===     Обновление Termidesk c версии 3.*    ==="
echo "===   до обьедененной редакции Termidesk 4   ==="
echo "================================================"
echo "===     Оcтанавливаем службы Termidesk       ==="
sudo systemctl stop termidesk-vdi termidesk-wsproxy termidesk-taskman
echo "===     Удаляем кеш файла ответов            ==="
sudo rm -f /var/cache/debconf/config.dat
sudo rm -f /var/cache/debconf/config.dat-old
echo "===     Начинаем процедуру обновлени         ==="
echo "  Выполним команду lsblk для просмотра подключенного CD-ROM"
sudo lsblk
echo "  Выберите устройство подключенного CD-ROM      "
echo "  для использованного его в качестве репозитория"
read dev
echo "  Вами выбрано устройстро /dev/$dev  "
sudo mkdir /mnt/termideskrepo
mount -o loop /dev/$dev /mnt/termideskrepo
sudo sh -c 'echo "deb file:/mnt/termideskrepo/repos/astra $(lsb_release -cs) non-free" > /etc/apt/sources.list.d/termidesk_local.list'
sudo cat /mnt/termideskrepo/repos/astra/GPG-KEY-PUBLIC | sudo apt-key add -
echo "===     Проверяем список ключей              === "
sudo apt-key list
sudo apt update
sudo apt install termidesk-for-astra
echo "=== Для корректной работы требуется перезагрузить сервер"
echo "===     Выполнить перезагрузку сейчас?       === "
echo "Выберите y или n"
read answer
if [ $answer = n ]; then
echo "Перезагрузите машину самостоятельно"
else
sudo reboot
fi
done
echo "================================================"
echo "===       Обновление выполнено               ==="
echo "================================================"