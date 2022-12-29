#!/bin/bash

### Скрипт по настройке файла notify.sh && keepalived.conf в папке /etc/keepalived
### 
### В файле /etc/keepalived/keepalived.conf требуется изменить следующие поля
### 
### router_id - FQDN
### script_user root - Пользователь от которого мы запускаем скрипт
### unicast_src_ip - IP адресс хоста с ролью Termidesk - Taskman
### VIRTUAL_IP_ADDREESS/MASK dev eth0 label eth0:106 - VIP для службы keepalived
###
sudo apt install keepalived ipset -y
sudo mkdir -p /etc/keepalived

cat << EOF >> /etc/keepalived/notify.sh
#!/bin/bash
SELF_BIN=\$(realpath \${0})
SELF_DIR=\$(dirname \${SELF_BIN})
 
TYPE=\${1}
NAME=\${2}
STATE=\${3}
PRIORITY=\${4}
 
TASKMAN_SYSTEMCTL_NAME="termidesk-taskman"
TASKMAN_SYSTEMCTL_DESCRIPTION="Termidesk-VDI Taskman daemon"
TASKMAN_SYSTEMCTL_PIDFILE="/run/termidesk-taskman/pid"
 
msg2log () {
    logger -i "Termidesk: \${1}"
}
 
taskman_stop () {
    msg2log "Stoping \${TASKMAN_SYSTEMCTL_NAME} service"
    systemctl is-active -q \${TASKMAN_SYSTEMCTL_NAME} && systemctl stop -q \${TASKMAN_SYSTEMCTL_NAME}
}
 
taskman_start () {
    msg2log "Starting \${TASKMAN_SYSTEMCTL_NAME} service"
    systemctl is-active -q \${TASKMAN_SYSTEMCTL_NAME} || systemctl start -q \${TASKMAN_SYSTEMCTL_NAME}
}
 
# VRRP event type: INSTANCE, name: lsb_40, state: BACKUP, priority: 64
msg2log "VRRP event type: \${TYPE}, name: \${NAME}, state: \${STATE}, priority: \${PRIORITY}"
 
case \${STATE} in
    BACKUP)
        [ "\${NAME}" = "\${TASKMAN_SYSTEMCTL_NAME}" ] && taskman_stop
    ;;
    FAULT)
        [ "\${NAME}" = "\${TASKMAN_SYSTEMCTL_NAME}" ] && taskman_stop
    ;;
    MASTER)
        [ "\${NAME}" = "\${TASKMAN_SYSTEMCTL_NAME}" ] && taskman_start
    ;;
    *)
        msg2log "Error: unknown state \${STATE}"
        exit 1
    ;;
esac
exit 0

EOF

sudo chmod +x /etc/keepalived/notify.sh

cat << EOF >> /etc/keepalived/keepalived.conf
global_defs {
 
    router_id NAME_OF_ROUTER_ID # CHANGE_ON: hostname хоста  
    script_user root # CHANGE_ON: имя пользователя, от имени которого запускается keepalived
    enable_script_security
}
  
vrrp_script check_httpd {
    script "/usr/bin/pgrep apache" # path of the script to execute
    interval 1  # seconds between script invocations, default 1 second
    timeout 3   # seconds after which script is considered to have failed
    #weight <INTEGER:-254..254>  # adjust priority by this weight, default 0
    rise 1              # required number of successes for OK transition
    fall 2              # required number of successes for KO transition
    #user USERNAME [GROUPNAME]   # user/group names to run script under
    init_fail                   # assume script initially is in failed state
}
 
# Для каждого виртуального IPv4-адреса создается свой экземпляр vrrp_instance
vrrp_instance termidesk-taskman {
    notify /etc/keepalived/notify.sh
 
    # Initial state, MASTER|BACKUP
    # As soon as the other machine(s) come up,
    # an election will be held and the machine
    # with the highest priority will become MASTER.
    # So the entry here doesn't matter a whole lot. 
    state BACKUP
 
    # interface for inside_network, bound by vrrp
    # CHANGE_ON: eth0 -> интерфейс, смотрящий в Интернет
    interface eth0
 
    # arbitrary unique number from 0 to 255
    # used to differentiate multiple instances of vrrpd
    # running on the same NIC (and hence same socket).
    # CHANGE_ON: 106 -> номер экземпляра vrrp_instance
    virtual_router_id 106
 
    # for electing MASTER, highest priority wins.
    # to be MASTER, make this 50 more than on other machines.
    # CHANGE_ON: заменить на приоритет  экземпляра vrrp_instance
    priority 128
     
    preempt_delay 5 # Seconds
 
    # VRRP Advert interval in seconds (e.g. 0.92) (use default)
    advert_int 1
 
    # CHANGE_ON: 192.0.2.2 -> IPv4-адрес интрефейса, смотрящего в Интернет
    unicast_src_ip IP_ADDRESS_OF_THIS_HOST
         
    authentication {       
        auth_type PASS
        # CHANGE_ON: ksedimret -> заменить на безопасный пароль
        auth_pass ksedimret
    }
                          
    virtual_ipaddress {
        # CHANGE_ON: 192.168.16.106/24 -> виртуальный IPv4-адрес и сетевой префикс с интрефейса, смотрящего в Интернет
        # CHANGE_ON: eth0 -> интерфейс, смотрящий в Интернет
        # CHANGE_ON: eth0:106 -> интерфейс, смотрящий в Интернет:4-й октет виртульного IPv4-адреса
        VIRTUAL_IP_ADDREESS/MASK dev eth0 label eth0:106
    }
                 
    track_script {
        check_httpd
    }
}



EOF


