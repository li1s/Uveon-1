#! /bin/bash
#

echo $1
if [ "$1" != '' ] ; then
case "$1" in
    "--version")
	echo "Termidesk preparation and optimization tools for Astra Linux"
	echo "Version: 1.0"
        exit 1
;;
    esac
else

#-------Variables and Functions-------
# Some Variables

CROSS="[!]"
green='\e[32m'
cyan='\e[36m'
red='\e[31m'

# Spinner
function spinner {
pid=$!
i=0
sp="/-\|"
while kill -0 $pid 2>/dev/null
	do
	i=$(( (i+1) %4 ))
	printf "\r[${sp:$i:1}]"
	sleep 1
done
}

# Header
function printhead {
clear
printf $green"$header"
}


#-------EULA------
if (whiptail --title "Об установщике" --scrolltext --yes-button "OK" --no-button "Exit" --yesno "$(cat README)" 20 60); then
printf $cyan""
exec 2>&1
	select_functions=$(whiptail --title $"Установщик Термидеск с выбором" --checklist --separate-output \
	$"Выберете что требуется сделать, насальника: " 15 60 9 \
	"1" $"Обновить пакеты" OFF \
	"2" $"Установить СУБД PostgreSQL" OFF \
	"3" $"Установить брокер сообщией RabbitMQ" OFF \
	"4" $"Настроить базу данных на стандартные значения" OFF \
    "5" $"Настроить брозу сообщений на стандартные значения" OFF \
    "6" $"Удалить СУБД PostgreSQL" OFF \
    "7" $"Удалить брокер сообщений RabbitMQ" OFF \
    "8" $"Удалить Термидеск" OFF \ 
    "9" $"Установить Термидеск все в одном" OFF 3>&1 1>&2 2>&3)

	exitstatus=$?
	if [ $exitstatus = 0 ]; then
		if [ -z "$select_functions" ]; then
  		echo $"No option was selected (user hit Cancel or unselected all options)"
		exit 1
		else
	#--------Display Header-------
	header=' _____                   _     _           _    
|_   _|__ _ __ _ __ ___ (_) __| | ___  ___| | __
  | |/ _ \ |__| `_ `_ \ | |/ _` |/ _ \/ __| |/ /
  | |  __/ |  | | | | | | | (_| |  __/\__ \   < 
  |_|\___|_|  |_| |_| |_|_|\__,_|\___||___/_|\_\'

	#-------Start-------
	printhead
	echo
	echo $"На абордаж, салаги!!!!"
	echo
######################################
#           Cheking system           #
######################################
printf $cyan$"Проверка состояния системы...\n"$reset
echo
sleep 2 & spinner
#source checksystem
#source usershome
#homedir

if [ ${vendorstat} != "Failed" ]; then
		for select_function in $select_functions; do
	    	case "$select_function" in
    "1")
	#-------Update-------
	printf $cyan$"Обновляем пакеты...\n"$reset
	echo
	sleep 2 & spinner
	sudo apt update -y 
      ;;
    "2")
	#-------Stoping services-------
	printf $cyan$"Checking services...\n"$reset
	echo
	sleep 2 & spinner
	source src/services
	services_stop
      ;;
    "3")
	#-------Remove packages-------
	printf $cyan$"Checking packages for remove...\n"$reset
	echo
	sleep 2 & spinner
	source src/pkgoperation
	pkgremove
      ;;
      *)
      echo $"Unsupported item %s" "$CHOICE!" >&2
      exit 1
      ;;
    esac
 done
 fi
fi
	else
		echo $"You chose Cancel. Exit"
	    	exit 1
	fi
else
echo $"You chose Exit"
exit 1
fi
fi