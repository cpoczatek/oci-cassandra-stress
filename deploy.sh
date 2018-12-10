#!/usr/bin/env bash


if [ -z "$CLUSTER_TF_PATH" ]; then
  echo "CLUSTER_TF_PATH not defined, need path to TF that deployed cluster."
  echo "call: export CLUSTER_TF_PATH=\"some_path\" "
  exit 1
fi

if [ -z "$PAR" ]; then
  echo "PAR not defined, need PAR to upload results"
  echo "call: export PAR='par_url' "
  exit 1
fi

if [ -z "$TEST_NAME" ]; then
  echo "TEST_NAME not defined, need TEST_NAME to upload results"
  echo "call: export TEST_NAME='test-foo' "
  exit 1
fi

STATE="$CLUSTER_TF_PATH/terraform.tfstate"

subnet_ocid=$(cat $STATE | jq '.modules[0].resources."oci_core_subnet.subnet".primary.id')
availability_domain=$(cat $STATE | jq '.modules[0].resources."oci_core_subnet.subnet".primary.attributes.availability_domain')
nodes=$(cat $STATE | jq '.modules[0].outputs."Node private IPs".value')
test_name="test"

echo "Info gathered: "
echo $subnet_ocid
echo $availability_domain
echo $nodes

terraform init
terraform plan \
  -var "subnet_ocid=$subnet_ocid" \
  -var "availability_domain=$availability_domain" \
  -var "nodes=$nodes" \
  -var "test_name"=$TEST_NAME \
  -var "par=$PAR"
terraform apply \
  -var "subnet_ocid=$subnet_ocid" \
  -var "availability_domain=$availability_domain" \
  -var "nodes=$nodes" \
  -var "test_name"=$TEST_NAME \
  -var "par=$PAR"
