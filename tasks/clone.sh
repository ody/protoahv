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
if [[ -z ${PT_name+x} ]]; then
  export NAME="bolt-${RANDOM}"
else
  export NAME="$PT_name"
fi

if [[ -z ${PT_domain+x} ]]; then
  export DOMAIN="local"
else
  export DOMAIN="$PT_domain"
fi

if [[ -z ${PT_ram+x} ]]; then
  export RAM="1024"
else
  export RAM="$PT_ram"
fi

if [[ -z ${PT_cores+x} ]]; then
  export CORES="1"
else
  export CORES="$PT_cores"
fi

if [[ -z ${PT_vcpus+x} ]]; then
  export VCPUS="1"
else
  export VCPUS="$PT_vcpus"
fi

if [[ -z ${PT_container+x} ]]; then
  export CONTAINER="default"
else
  export CONTAINER="$PT_container"
fi

# Fail if some required data is not set
if [[ -z ${PT_key+x} ]]; then
 echo "Setting SSH key is required"
 exit 1
fi

if [[ -z ${PT_source+x} ]]; then
 echo "Setting name of source VM is required"
 exit 1
fi

if [[ -z ${PT_userdata+x} ]]; then
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
EOF
else
cat <<EOF > /tmp/userdata-$NAME.yaml
$PT_userdata
EOF
fi

/usr/local/nutanix/bin/acli -o json uhura.vm.clone_with_customize $NAME clone_from_vm=$PT_source cloudinit_userdata_path=file:///tmp/userdata-$NAME.yaml memory="${RAM}M" num_cores_per_vcpu=$CORES num_vcpus=$VCPUS container=$CONTAINER
/usr/local/nutanix/bin/acli -o json vm.on $NAME

rm /tmp/userdata-$NAME.yaml
