#!/bin/bash

NAME_VM1="Web"
NAME_VM2="Data"

function vm_test {
  echo "Testing ${1}"
  py.test -v --ansible-inventory=inventory/aws_ec2.yml --hosts="ansible://${1}" --connection=ansible --force-ansible "test-${1}-vm.py"
}

vm_test $NAME_VM1
vm_test $NAME_VM2
