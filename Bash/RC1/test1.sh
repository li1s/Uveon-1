if (whiptail --title "About tools" --scrolltext --yes-button "OK" --no-button "Exit" --yesno "$(cat README)" 20 60); then
printf $cyan""
exec 2>&1
	select_functions=$(whiptail --title $"OPTIMIZATION FUNCTIONS" --checklist --separate-output \
	$"Select function for optimization" 15 60 9 \
	"1"  $"Installing required packages" OFF \
	"2"  $"Stop recommended services" OFF \
	"3"  $"Remove recommended packages" OFF \
	"4"  $"Deleting large files" OFF \
    "5"  $"Cleaning up user logs" OFF \
    "6"  $"Cleaning up system logs" OFF \
    "7"  $"Cleaning web browsers" OFF \
    "8"  $"Cleaning bash history" OFF \
    "9"  $"Optimize fly desktop" OFF \
    "10" $"Cleaning temp files" OFF \
    "11" $"Cleaning apt cache" OFF \
    "12" $"Cleaning journal" OFF \
    "13" $"Optimize power button" OFF \
    "14" $"Install display resize script" OFF \
    "15" $"Stop auto upgrade" OFF 3>&1 1>&2 2>&3)
