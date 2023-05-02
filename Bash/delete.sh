sudo su postgres -c "psql -c \"DROP DATABASE termidesk;\""
sudo su postgres -c "psql -c \"DROP USER termidesk;\""
aptitude purge postgresql -y
aptitude purge rabbitmq-server -y
aptitude purge termidesk-vdi -y
rm -rf /opt/termidesk/
aptitude purge ~c -y