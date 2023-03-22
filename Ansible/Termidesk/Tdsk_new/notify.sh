#!/bin/sh -e
SELF_BIN=$(realpath ${0})
SELF_DIR=$(dirname ${SELF_BIN})
TYPE=${1}
NAME=${2}
STATE=${3}
PRIORITY=${4}
TASKMAN_SYSTEMCTL_NAME="termidesk-taskman"
TASKMAN_SYSTEMCTL_DESCRIPTION="Termidesk-VDI Taskman daemon"
TASKMAN_SYSTEMCTL_PIDFILE="/run/termidesk-taskman/pid"
msg2log () {
logger -i "Termidesk: ${1}"
}
taskman_stop () {
msg2log "Stopping ${TASKMAN_SYSTEMCTL_NAME} service"
systemctl is-active -q ${TASKMAN_SYSTEMCTL_NAME} && systemctl stop -q ${TASKMAN_SYSTEMCTL_NAME}
}
taskman_start () {
msg2log "Starting ${TASKMAN_SYSTEMCTL_NAME} service"
systemctl is-active -q ${TASKMAN_SYSTEMCTL_NAME} || systemctl start -q ${TASKMAN_SYSTEMCTL_NAME}
}
# VRRP event type: INSTANCE, name: lsb_40, state: BACKUP, priority: 64
msg2log "VRRP event type: ${TYPE}, name: ${NAME}, state: ${STATE}, priority: ${PRIORITY}"
case ${STATE} in
BACKUP)
[ "${NAME}" = "${TASKMAN_SYSTEMCTL_NAME}" ] && taskman_stop
;;
FAULT)
[ "${NAME}" = "${TASKMAN_SYSTEMCTL_NAME}" ] && taskman_stop
;;
MASTER)
[ "${NAME}" = "${TASKMAN_SYSTEMCTL_NAME}" ] && taskman_start
;;
*)
msg2log "Error: unknown state ${STATE}"
exit 1
;;
esac
exit 0
