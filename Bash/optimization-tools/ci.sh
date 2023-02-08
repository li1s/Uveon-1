TARFILE="termidesk-optimization-tools-astra"
POTFILE="termidesk"

case "$1" in
    "--pot")
    if [ -f locale/ru/${POTFILE}.po ]; then
    echo "PO file exists. Backup it"
    bash --dump-po-strings start.sh > ${POTFILE}.start.pot
    for file in $(ls src | grep -v logs); do
     bash --dump-po-strings src/${file} > "${POTFILE}.${file}.pot"
    done
    cp locale/ru/${POTFILE}.po locale/ru/${POTFILE}.po.old
    cat ${POTFILE}.*.pot > ${POTFILE}.pot
    msgmerge --update locale/ru/${POTFILE}.po ${POTFILE}.pot
    rm -f ${POTFILE}.*.pot
    rm -f ${POTFILE}.pot
    echo "Congratulations! PO file ready"
    else
    bash --dump-po-strings start.sh > ${POTFILE}.start.pot
     for file in $(ls src | grep -v logs); do
     bash --dump-po-strings src/${file} > "${POTFILE}.${file}.pot"
    done
    cat ${POTFILE}.*.pot > ${POTFILE}.pot
    cp ${POTFILE}.pot locale/ru/${POTFILE}.po
    rm -f ${POTFILE}.*.pot
    rm -f ${POTFILE}.pot
    echo "Congratulations! POT file ready"
    fi
    exit 1
    ;;
    "--mo")
     if [ -f locale/ru/${POTFILE}.po ]; then
     msgfmt -o locale/ru/LC_MESSAGES/${POTFILE}.mo locale/ru/${POTFILE}.po
     echo "Congratulations! MO file ready"
     exit 1
     else
     echo "MO file not exists. Exit"
     exit 1
     fi
      ;;
    "--build")
    echo "Install shc compiller"
    sudo apt install shc &>/dev/null
    if [ -d _build ]; then
    rm -rf _build
    fi 
    echo "Create tools..."
    mkdir _build
    rm -f logs/*
    rm -rf backup/*
    cp -r backup config files hooks locale logs src README LICENSE README.start start.sh changelog.md  _build/ 
    shc -f _build/start.sh
    rm -f _build/start.sh
    rm -f _build/start.sh.x.c
    mv _build/start.sh.x _build/start
    echo "Tools ready for TAR"
    ;;
    "--tar")
      if [ -d _build ]; then
      if [ -f ${TARFILE}.tar.gz ]; then
      echo "TAR exists"
      read -p $"Do you want to delete the tar? ([Y]/n): " yn 2>&1
      yn=${yn:-Y}
	case ${yn} in
	[Yy]* )
	   rm -f ${TARFILE}.tar.gz
	   echo "TAR deleted"
	   tar -czvf ${TARFILE}.tar.gz -C _build .
           echo "Congratulations! TAR ready"
           exit 1;;
	[Nn]* )
		echo "TAR an archive named ${TARFILE}.$(date +"%Y%m%d%H%M").tar.gz"
		tar -czvf ${TARFILE}.$(date +"%Y%m%d%H%M").tar.gz -C _build .
                echo "Congratulations! TAR ready"
           	exit 1;;
        * ) echo $"Please answer yes or no";;
	esac
      else
      tar -czvf ${TARFILE}.tar.gz -C _build .
      echo "Congratulations! TAR ready"
      fi
      else
	echo "Build dir does not exist"
	echo "Use --buil the parameter to create it"
        exit
      fi
      exit 1
      ;;
      *)
      echo "You must specify the parameters:"
      echo "--tar" "	Create tar archive"
      echo "--pot" "	Create pot file"
      echo "--mo" "	Create mo file from pot"
      echo "--build" "	Create bin files from scripts"
      exit 1
      ;;
esac
