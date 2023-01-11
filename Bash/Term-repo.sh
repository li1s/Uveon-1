!#/bin/bash


echo "Проверим добавлен ли официальный репозиторий Termidesk"

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
        printf $green$"Репозиторий Termidesk настроек верно!\n"$reset
        repostat="Passed"
else

printf $red$"Репозиторий Termidesk не настроен.\n"$reset

printf $green$"Добавим официальный репозиторий Termidesk? \n"$reset

select answer in yes no quit

         do

case $answer in

        "yes")

sudo sh -c 'echo "deb https://termidesk.ru/repos/astra $(lsb_release -cs) non-free" > /etc/apt$(lsb_release -cs) non-free" > /etc/apt/sources.list.d/termidesk.list'
wget -O - https://termidesk.ru/repos/astra/GPG-KEY-PUBLIC | sudo apt-key add -    
printf $green$"Репозиторий успешно добавлен \n"$reset  
    break
    ;;

        "no")

echo "Для продолжения установки потребуется поместить файл Termidesk-vdi.deb в папку с установ"
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