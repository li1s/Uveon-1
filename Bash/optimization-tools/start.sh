#! /bin/bash
#
#-------Include files-------
source ~/config
source ~/src/logs
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
#srv_file="files/services.txt"
#fly_file="files/fly-optimization.conf"
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
if (whiptail --title "About tools" --scrolltext --yes-button "OK" --no-button "Exit" --yesno "$(cat README)" 20 60); then
printf $cyan""
exec 2>&1
	select_functions=$(whiptail --title $"OPTIMIZATION FUNCTIONS" --checklist --separate-output \
	$"Select function for optimization" 15 60 9 \
	"1" $"Installing required packages" OFF \
	"2" $"Stop recommended services" OFF \
	"3" $"Remove recommended packages" OFF \
	"4" $"Deleting large files" OFF \
        "5" $"Cleaning up user logs" OFF \
        "6" $"Cleaning up system logs" OFF \
        "7" $"Cleaning web browsers" OFF \
        "8" $"Cleaning bash history" OFF \
        "9" $"Optimize fly desktop" OFF \
        "10" $"Cleaning temp files" OFF \
        "11" $"Cleaning apt cache" OFF \
        "12" $"Cleaning journal" OFF \
        "13" $"Optimize power button" OFF \
        "14" $"Install display resize script" OFF \
        "15" $"Stop auto upgrade" OFF 3>&1 1>&2 2>&3)
source src/logs
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
	echo $"Termidesk preparation and optimization tools for Astra Linux"
	echo
######################################
#           Cheking system           #
######################################
printf $cyan$"Checking system requirements...\n"$reset
echo
sleep 2 & spinner
source src/checksystem
source src/usershome
homedir

if [ ${vendorstat} != "Failed" ]; then
		for select_function in $select_functions; do
	    	case "$select_function" in
    "1")
	#-------Checking package requirements-------
	printf $cyan$"Checking packages requirements...\n"$reset
	echo
	sleep 2 & spinner
	source src/pkgoperation
	pkginstall
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
    "4")
	printf $cyan$"Checking large files...\n"$reset 
	echo
	sleep 2 & spinner
	source src/usershome
	bigfiles
      ;;
    "5")
	printf $cyan$"Cheking user log files...\n"$reset
	echo
	sleep 2 & spinner
	source src/usershome
	ulog_clean
      ;;
    "6")
	printf $cyan$"Cheking system log files...\n"$reset
	echo
	sleep 2 & spinner
	source src/systems
	slog_clean
      ;;
    "7")
	printf $cyan$"Cheking web browsers files...\n"$reset
	echo
	sleep 2 & spinner
	source src/usershome
	mozilla_wb_clean
      ;;
    "8")
	printf $cyan$"Cheking bash history files...\n"$reset
	echo
	sleep 2 & spinner
	source src/usershome
	baqshhistory
      ;;
    "9")
	printf $cyan$"Optimize fly desktop...\n"$reset
	echo
	sleep 2 & spinner
	source src/flydesktop
      ;;
    "10")
	printf $cyan$"Cheking temp files...\n"$reset
	echo
	sleep 2 & spinner
	source src/systems
	tmpclean
      ;;
    "11")
	printf $cyan$"Cheking apt cache...\n"$reset
	echo
	sleep 2 & spinner
	source src/systems
	aptclean
      ;;
    "12")
	printf $cyan$"Cheking journal...\n"$reset
	echo
	sleep 2 & spinner
	source src/systems
	purgejournal
      ;;
    "13")
	printf $cyan$"Cheking power button file...\n"$reset
	echo
	sleep 2 & spinner
	source src/systems
	powerbutton
	#xsize
      ;;
    "14")
	printf $cyan$"Install resize script...\n"$reset
	echo
	sleep 2 & spinner
	source src/systems
	xsize
      ;;
    "15")
	printf $cyan$"Stop auto update...\n"$reset
	echo
	sleep 2 & spinner
	source src/services
	stopautoupgreade
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

######################################
#          Generate report           #
######################################

echo
printf $cyan$"Checks and actions report...\n"$reset
echo
sleep 2 & spinner
if [ ${vendorstat} == "Failed" ]; then
	outputFormat="|%-27s|%-7s|\n"; 
	whiptail --title $"Report" --ok-button "Exit" --msgbox "$( 
	printf "+------------------------------------+\n"
	printf $"|            System check            |\n" 
	printf "+------------------------------------+\n" 
	printf ${outputFormat} $"Check" $" Result "
        printf "+---------------------------+--------+\n"
	printf ${outputFormat} $"Virtualization for guest OS" " "$vendorstat" "
	printf "+------------------------------------+\n")"  20 42
	exit 1
else
	outputFormat="|%-30s|%-7s|\n"; 
	whiptail --title "Report" --scrolltext --ok-button "Exit" --msgbox "$( 
	printf "+---------------------------------------+\n"
	printf "|               System check            |\n" 
	printf "+---------------------------------------+\n" 
	printf ${outputFormat} "Check" " Result "
        printf "+---------------------------+-----------+\n"
	printf ${outputFormat} $"OS is $distro" " "$distrostat" "
	printf ${outputFormat} "Virtualization for guest OS" " "$vendorstat" "
	printf ${outputFormat} $"CPU for guest OS" " "$cpustat" "
	printf ${outputFormat} $"RAM for guest OS" " "$ramstat" "
	printf ${outputFormat} $"NIC for guest OS" " "$nicstat" "
	printf ${outputFormat} $"DHCP for guest OS" " "$dhcpstat" "
	printf ${outputFormat} $"Termidesk repo" " "$repostat" "
	printf "+---------------------------------------+\n"
	printf $"|            Packages operation         |\n" 
	printf "+---------------------------------------+\n" 
	printf ${outputFormat} $"Install req pkgs" " "$pkgstat" "
	printf ${outputFormat} $"Remove selected pkgs" " "$pkgrmstat" "
	printf ${outputFormat} $"Remove apt cache" " "$aptstat" "
	printf "+---------------------------------------+\n"
	printf $"|           Ssservices operation         |\n" 
	printf "+---------------------------------------+\n" 
	printf ${outputFormat} $"Service stopped" " "$srvstat" "
	printf ${outputFormat} $"Auto upgrade stopped" " "$atustat" "
	printf "+---------------------------------------+\n"
	printf $"|              Files operation          |\n" 
	printf "+---------------------------------------+\n"
	printf ${outputFormat} "Deleting large files" " "$bfilestat" "
	printf ${outputFormat} $"Cleaning user log files" " "$ulogstat" "
	printf ${outputFormat} $"Cleaning system log files" " "$slogstat" "
	printf ${outputFormat} $"Cleaning system archive log files" " "$sgzlogstat" "
	printf ${outputFormat} $"Cleaning browsers files" " "$mwbfilestat" "
	printf ${outputFormat} $"Cleaning tmp files" " "$tmpstat" "
	printf ${outputFormat} "Cleaning journal" " "$jourstat" "
	printf "+---------------------------------------+\n"
	printf $"|               Optimization            |\n" 
	printf "+---------------------------------------+\n"
	printf ${outputFormat} $"FLY desktop" " "$flystat" "
	printf ${outputFormat} $"Powerr button" " "$pbstat" "
	printf ${outputFormat} $"Install resize script" " "$xszstat" "
	printf "+---------------------------------------+\n")"  30 45
exit 1
fi

fi
