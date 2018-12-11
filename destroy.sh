#!/usr/bin/env bash


STATE="$CLUSTER_TF_PATH/terraform.tfstate"

subnet_ocid=$(cat $STATE | jq '.modules[0].resources."oci_core_subnet.subnet".primary.id')
availability_domain=$(cat $STATE | jq '.modules[0].resources."oci_core_subnet.subnet".primary.attributes.availability_domain')
nodes=$(cat $STATE | jq '.modules[0].outputs."Node private IPs".value')

echo $subnet_ocid
echo $availability_domain
echo $nodes

terraform destroy \
  -var "subnet_ocid=$subnet_ocid" \
  -var "availability_domain=$availability_domain" \
  -var "nodes=$nodes" \
  -var "test_name"=$TEST_NAME \
  -var "par=$PAR"
