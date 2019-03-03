#!/bin/bash

HOSTNAME=`hostname`
TIMESTAMP=`date '+%Y-%m-%d_%H%M%S'`
BACKUP_DIR=${1:-/tmp/xfer}
BACKUP_NAME=master_${HOSTNAME}_${TIMESTAMP}
TMP_DIR=/tmp

echo "Creating backup on $HOSTNAME in $BACKUP_DIR as $BACKUP_NAME"

## BACKUP_TMP_DIR is a temporary directory for collecting backup files
## contents will be tar-ed and copied to final backup destination BACKUP_DIR
BACKUP_TMP_DIR=$TMP_DIR/tmp_backup_$TIMESTAMP
mkdir -p $BACKUP_TMP_DIR

## copy all /etc/origin/* to backup dir
mkdir -p $BACKUP_TMP_DIR/etc/origin
cp -aR /etc/origin $BACKUP_TMP_DIR/etc/origin/

## copy all /etc/sysconfig/* to backup dir (atomic-*, iptables, docker-*)
mkdir -p $BACKUP_TMP_DIR/etc/sysconfig
cp -aR /etc/sysconfig/atomic-* $BACKUP_TMP_DIR/etc/sysconfig/
cp -aR /etc/sysconfig/{iptables,docker-*} $BACKUP_TMP_DIR/etc/sysconfig/

## copy dnsmasq, cni and pki configurations
mkdir -p $BACKUP_TMP_DIR/etc/pki/ca-trust/source/anchors
cp -aR /etc/dnsmasq* /etc/cni $BACKUP_TMP_DIR/etc/
cp -aR /etc/pki/ca-trust/source/anchors/* $BACKUP_TMP_DIR/etc/pki/ca-trust/source/anchors/

# tar everything to backup directory
(cd $BACKUP_TMP_DIR && tar -zcf $BACKUP_DIR/$BACKUP_NAME.tgz *)

# remove temporary directory
rm -fr $BACKUP_TMP_DIR

