# openshift-custom-backup

## Create a backup of an openshift cluster 
This backup is based on the Day2Ops Environment Backup instructions.
Assumptions:
- There is a directory '/backup' that is writable on all masters / nodes
- ETCD is running as a static pod on the master nodes

These Scripts and Playbooks are distributed WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND

## Usage
```bash
ansible-playbook <-i inventory> openshift-custom-backup.yml -e ocp_env=<environment name without spaces>
```
