#!/usr/bin/env bash

# This wrapper script runs a playbook ON ALREADY CREATED and provisioned VMs, 
# as it runs with the GCE dynamic inventory gce.py, located under inventory/
# We get the running instances, and we apply the playbook to those.
#
# usage: ./script PLAYBOOK extra_vars:var1=value,var2=value..varn=value
# eg:    ./script add_nginx.yml extra_vars:env=staging,vhost_path=/etc/
# In order to create and provision GCE instances we'd use:
# ansible-playbook -vvvv  -e "env=staging" create_instance.yml
# - env=staging will get the envirnments/staging variables -
# In order to delete/decommision them after creation obviously,
# ansible-playbook -vvvv  -e "env=staging" delete_instance.yml
#
 
# @ Yospace - all rights reserved. 


PLAYBOOK="$1"
ANSIBLE_PLAYBOOK="$(which ansible-playbook)"
SSH_PORT=2201

if [[ -z "$PLAYBOOK" ]]; then
  echo "You need to pass a playbook as argument to this script."
  exit 1
fi

if [[ -z "$2" ]]; then
  echo 'WARN: no extra variables passed' 
  NO_EXTVARS=1
fi

export SSL_CERT_FILE=
export ANSIBLE_HOST_KEY_CHECKING=False
export ANSIBLE_REMOTE_PORT=$SSH_PORT

if [[ ! -f "$SSL_CERT_FILE" ]]; then
  curl -O http://curl.haxx.se/ca/cacert.pem
fi

if [[ -z "$NO_EXTVARS" ]]; then
  typeset -a array
  VARS="$(echo $2 | awk -F":" '{print $2}')"
  read -ra EVAR <<< "$VARS"
  for i in "${EVAR[@]}"; do
    array+=("$1")
  done
 
  echo "[+] array: ${array[@]}"

  $ANSIBLE_PLAYBOOK -vvvv -e "${array[@]}" -i inventory/ "$PLAYBOOK"

else
  $ANSIBLE_PLAYBOOK -vvvv -i inventory/ "$PLAYBOOK"   
fi

