# Changelog
Все основные изменения серверной части будут документироваться здесь.

Формат базируется на [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [x.x.x] - unreleased
### Added
- .gitignore файл

## [1.0] - unreleased
### Added
- Добавлена русская локализация
- Добавлена проверка среды запуска скрипта. Поддерживается виртуализация oVirt и QEMU
- Добавлена проверка необходимого объема ОЗУ
- Добавлена проверка рекомендованного количества ЦП
- Добавлена проверка использования DHCP адреса на сетевом адаптере
- Добавлена установка необходимых пакетов для SPICE и Termidesk. Перечень устанавливаемых пакетов определен в файле files/pkg_required.txt
- Добавлено удаление пакетов, не рекомендованных для гостевой ОС. Перечень удаляемых пакетов определен в файле files/pkg_remove.txt
- Добавлена останавка служб, не используемые в гостевой ОС. Перечень останавливаемых служб определен в файле files/services.txt
- Добавлена оптимизация рабочего стола fly. Параметры оптимизации определены в файле files/fly-optimization.conf
- Добавлено переопределение кнопки выключения питания в гостевой ОС
- Добавлено обнудение лог-файлов из директорий /var/log и /home/$USER
- Добавлено удаление архивов log файлов в формате gz 
- Добавлена очистка кеша браузера firefox 
- Добавлена очистка истории команд bash
- Добавлена установка скрипта и действий udev для реализации автомасштабирования
- Добавлено отключение службы автообновления
- Добавлена очистка кеша apt
- Добавлен поиск и удаление больших файлов. Размер файла настривается в переменной ${FILESIZE} файла config
- Добавлена очистка журнала системы (journal)
- Добавлена дефрагментация HHD в системе
### Changed
- Изменен способ модификации файлов темы fly
- Изменен скрипт по автоматическому масштабированию экрана в директории hooks/x-resize
- Добавлен скрипт по оптимизации дисковых операций src/defragmentation
- Добавлены изменения в команду по сбору бинарного файла, для возможности работы на ОС аналогичных ОС на которой был собран скрипт ci.sh 


### Fixed

- Исправлен выбор условия вывода версии
- Исправлен механизм определения ОС
- Исправлено удаление истории команд bash
