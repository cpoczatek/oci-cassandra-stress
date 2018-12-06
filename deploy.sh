#!/usr/bin/env bash


if [ -z "$1" ]; then
  echo "No args passed, need path to TF that deployed cluster..."
  exit 1
fi

CLUSTER_TF_PATH=$1

STATE="$CLUSTER_TF_PATH/terraform.tfstate"

subnet_ocid=$(cat $STATE | jq '.modules[0].resources."oci_core_subnet.subnet".primary.id')
availability_domain=$(cat $STATE | jq '.modules[0].resources."oci_core_subnet.subnet".primary.attributes.availability_domain')
nodes=$(cat $STATE | jq '.modules[0].outputs."Node private IPs".value')

echo $subnet_ocid
echo $availability_domain
echo $nodes

terraform init
terraform plan \
  -var "subnet_ocid=$subnet_ocid" \
  -var "availability_domain=$availability_domain" \
  -var "nodes=$nodes"
terraform apply \
  -var "subnet_ocid=$subnet_ocid" \
  -var "availability_domain=$availability_domain" \
  -var "nodes=$nodes"
