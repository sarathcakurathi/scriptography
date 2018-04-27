#!/bin/bash

#######################################
#	Author: Sarath C Akurathi		  #
#	Date: 27/04/2018				  #
#	Purpose: Jenkins backup & restore #
#######################################

# Logger utility
function log()
{
	echo "[$(date +"%m-%d-%Y %H:%M:%S")] : $@" >> $log_file
}

# Backup function
function do_backup()
{
	log "BEGIN: Backup process"
	run_backup_cmd=$(tar --exclude="*workspace*" --exclude="*builds*" --exclude="*logs*" -pcvzf ${BACKUP_PATH}/jenkins.tar.gz ${JENKINS_HOME} 2>&1)
	retVal=$(echo $?)
	[ ${retVal} -ne 0 ] && log "Backup process failed, please verify the log ${log_file}"
	log "${run_backup_cmd}"
	log "END: Backup proccess"
}

# Restore function
function do_restore()
{
	log "BEGIN: Restore process"
	run_restore_cmd=$(tar -pxvzf ${BACKUP_PATH}/jenkins.tar.gz -C ${JENKINS_HOME} 2>&1)
	retVal=$(echo $?)
	[ ${retVal} -ne 0 ] && log "Restore process failed, please verify the log ${log_file}"
	log "${run_restore_cmd}"
	log "END: Restore proccess"
}

# Read configuration
function readargs()
{
	if [[ $# -ne 3 ]]; then
		echo "Usage: -a=*|--action=* -j=*|--jenkins-home=* -b=*|--backup-path=*"
		exit 1
	fi
	for arg in "$@"
	do
		case $arg in
			-a=*|--action=*)
				ACTION="${arg#*=}"
				export ACTION
				shift
				;;
			-j=*|--jenkins-home=*)
				JENKINS_HOME="${arg#*=}"
				export JENKINS_HOME
				shift
				;;
			-b=*|--backup-path=*)
				BACKUP_PATH="${arg#*=}"
				export BACKUP_PATH
				shift
				;;
			*)
				echo "Usage: -a=*|--action=* -j=*|--jenkins-home=* -b=*|--backup-path=*"
				exit 1
				;;
		esac
	done
}

# Variable declaration
date_extn=$(date +"%m-%d-%Y")
log_file="/tmp/jenkins_backup_restore_${date_extn}.log"

readargs "$@"
if [[ "${ACTION}" == "backup" ]]; then
	do_backup
elif [[ "${ACTION}" == "restore" ]]; then
	do_restore
else
	echo "Undefined action, exiting.."
	exit 2
fi
