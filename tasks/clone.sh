#!/bin/bash

# Puppet Task Name: protoahv::clone
#
# This is where you put the shell code for your task.
#
# You can write Puppet tasks in any language you want and it's easy to
# adapt an existing Python, PowerShell, Ruby, etc. script. Learn more at:
# http://puppet.com/docs/bolt/latest/converting_scripts_to_tasks.html
#
# Puppet tasks make it easy for you to enable others to use your script. Tasks
# describe what it does, explains parameters and which are required or optional,
# as well as validates parameter type. For examples, if parameter "instances"
# must be an integer and the optional "datacenter" parameter must be one of
# portland, sydney, belfast or singapore then the .json file
# would include:
#   "parameters": {
#     "instances": {
#       "description": "Number of instances to create",
#       "type": "Integer"
#     },
#     "datacenter": {
#       "description": "Datacenter where instances will be created",
#       "type": "Enum[portland, sydney, belfast, singapore]"
#     }
#   }
# Learn more at: https://puppet.com/docs/bolt/latest/task_metadata.html
#

# Set a bunch of defaults
if [ -n $PT_name]; then
  $NAME = $PT_name
else
  $NAME = "bolt-${RANDOM}"
fi

if [ -n $PT_domain]; then
  $DOMAIN = $PT_domain
else
  $DOMAIN = "local"
fi

if [ -n $PT_ram]; then
  $RAM = $PT_ram
else
  $RAM = "1024"
fi

if [ -n $PT_cores]; then
  $CORES = $PT_cores
else
  $CORES = "1"
fi

if [ -n $PT_vcpus]; then
  $VCPUS = $PT_vcpus
else
  $VCPUS = "1"
fi

if [ -n $PT_container]; then
  $CONTAINER = $PT_container
else
  $CONTAINER = "default"
fi

# Fail if some required data is not set
if [ -z $PT_key ]; then
 echo "Setting SSH key is required"
 exit 1
fi

if [ -z $PT_source ]; then
 echo "Setting name of source VM is required"
 exit 1
fi

cat <<EOF > /tmp/userdata-$NAME.yaml
#cloud-config
users:
  - name: nutanix
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh-authorized-keys:
      - $PT_key
    lock-passwd: false
    passwd: RANDOM
hostname: $NAME
fqdn: $NAME.$DOMIAN
EOF

acli uhura.vm.clone_with_customize $NAME clone_from_vm=$PT_source cloudinit_userdata_path=file:///tmp/userdata-$NAME.yaml memory="${RAM}M" num_cores_per_vcpu=$CORES num_vcpus=$VCPUS container=$CONTAINER

rm /tmp/userdata-$PT_name.yaml
