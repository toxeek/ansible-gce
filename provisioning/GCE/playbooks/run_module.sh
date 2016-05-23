#!/bin/bash

# also could be a one liner: 
# e.g: ANSIBLE_REMOTE_PORT=2201 ansible all -i inventory/ -m setup

ANSIBLE=$(which ansible)
MODULE="$1"

[ -z "$1" ] && echo "no module passed." >&2 && exit 1

ANSIBLE_REMOTE_PORT=2201 ${ANSIBLE} all -i inventory/ -m ${MODULE}

