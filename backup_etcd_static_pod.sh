#!/bin/bash

TMP_HOSTNAME=`hostname`
ANSIBLE_HOSTNAME=${2:-${TMP_HOSTNAME}}
TIMESTAMP=`date '+%Y-%m-%d_%H%M%S'`
BACKUP_DIR=${1:-/tmp/xfer}
BACKUP_NAME=etcd_master_${ANSIBLE_HOSTNAME}_${TIMESTAMP}
TMP_DIR=/tmp

echo "Creating backup on $ANSIBLE_HOSTNAME in $BACKUP_DIR as $BACKUP_NAME"

## BACKUP_TMP_DIR is a temporary directory for collecting backup files
## contents will be tar-ed and copied to final backup destination BACKUP_DIR
BACKUP_TMP_DIR=$TMP_DIR/tmp_backup_$TIMESTAMP
mkdir -p $BACKUP_TMP_DIR

## copy all /etc/etcd/* to backup dir
mkdir -p $BACKUP_TMP_DIR/etc/etcd
cp -aR /etc/etcd/ $BACKUP_TMP_DIR/etc/etcd/

## create ETCD snapshot
mkdir -p $BACKUP_TMP_DIR/var/lib/etcd
export ETCD_POD_MANIFEST="/etc/origin/node/pods/etcd.yaml"
export ETCD_EP=$(grep https ${ETCD_POD_MANIFEST} | cut -d '/' -f3)
echo "DEBUG: using etcd endpoint '${ETCD_EP}'"

## execute the backup on the current ansible node
/usr/bin/oc login -u system:admin
export ETCD_POD=$(oc get pods -n kube-system | grep ${ANSIBLE_HOSTNAME} | grep -o -m 1 '\S*etcd\S*')
echo "DEBUG: using etcd pod '${ETCD_POD}'"

/usr/bin/oc project kube-system
/usr/bin/oc exec ${ETCD_POD} -c etcd -- /bin/bash -c "ETCDCTL_API=3 etcdctl --cert /etc/etcd/peer.crt --key /etc/etcd/peer.key --cacert /etc/etcd/ca.crt --endpoints ${ETCD_EP} snapshot save /var/lib/etcd/snapshot.db"
/usr/bin/cp -p /var/lib/etcd/snapshot.db $BACKUP_TMP_DIR/var/lib/etcd/

# tar everything to backup directory
(cd $BACKUP_TMP_DIR && tar -zcf $BACKUP_DIR/$BACKUP_NAME.tgz *)

# remove temporary directory
rm -fr $BACKUP_TMP_DIR

