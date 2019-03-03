#!/bin/bash

TIMESTAMP=`date '+%Y-%m-%d_%H%M%S'`
BACKUP_DIR=${1:-/tmp/xfer}
BACKUP_NAME=project-export_$TIMESTAMP
TMP_DIR=/tmp


## BACKUP_TMP_DIR is a temporary directory for collecting backup files
## contents will be tar-ed and copied to final backup destination BACKUP_DIR
BACKUP_TMP_DIR=$TMP_DIR/tmp_backup_$TIMESTAMP
mkdir -p $BACKUP_TMP_DIR

for prj in `oc get project --no-headers | awk '{ print $1 }'`; do 
	echo "Exporting data for namespace '$prj'"

	# export all (exports deplyoment config, build config, etc.)
	oc export all -n $prj -o yaml >$BACKUP_TMP_DIR/oc-project-export-$prj-all.yaml 2>&1 | grep -v "no resources found"

	# export all additional objects	
	for object in rolebindings serviceaccounts secrets imagestreamtags podpreset configmap egressnetworkpolicies rolebindingrestrictions limitranges resourcequotas pvc templates cronjobs statefulsets hpa deployments replicasets poddisruptionbudget endpoints
	do
		oc export $object -n $prj -o yaml >$BACKUP_TMP_DIR/oc-project-export-$prj-$object.yaml 2>&1 | grep -v "no resources found" 
	done
done

# tar everything to backup directory
(cd $BACKUP_TMP_DIR && tar -zcf $BACKUP_DIR/$BACKUP_NAME.tgz *)

# remove temporary directory
rm -fr $BACKUP_TMP_DIR

