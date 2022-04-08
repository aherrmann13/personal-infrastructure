#! /bin/bash

ansible all -m ping -i ../terraform/inventory.cfg --key-file "~/.ssh/id_rsa" --user root -e 'ansible_python_interpreter=/usr/bin/python3'
