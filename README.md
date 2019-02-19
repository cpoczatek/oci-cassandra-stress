# Why

The purpose of this repo is to easily spin up many VMs, install `cassandra-stress`,
run a test against an existing cluster, and upload the results to object storage.

# Setup

The terraform and shell in this repo assumes you've correctly installed and
configured terraform. Clone this repo, cd into it, and run `terraform init`.

You should see something like:
```
jpoczate-mac:oci-cassandra-stress jpoczate$ terraform init

Initializing provider plugins...
- Checking for available provider plugins on https://releases.hashicorp.com...
- Downloading plugin for provider "oci" (3.15.0)...

The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, it is recommended to add version = "..." constraints to the
corresponding provider blocks in configuration, with the constraint strings
suggested below.

* provider.oci: version = "~> 3.15"

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

You also need to create a [bucket](https://docs.cloud.oracle.com/iaas/Content/Object/Tasks/managingbuckets.htm) in object storage and a [PAR](https://docs.cloud.oracle.com/iaas/Content/Object/Tasks/usingpreauthenticatedrequests.htm) to access it in the OCI console.

# Deployed resources and actions

The workflow these templates go through is as follows:
- parse the terraform.tfstate of a deployed cluster. **Note**, this will not work
- create 10 VMs in the provided subnet
- on each VM
  - install java
  - install C* 3.11.latest
  - using the embedded `stress.yaml` file run through load/warmup/test calls to `cassandra-stress`
  - upload results and info files using the PAR


# Running

The test can be run by issuing the usual terraform `init/plan/apply` commands.
Desired changes to `test.sh` should be made before running.

There are 5 variables that need to be defined that are purposefully unset
in the `variables.tf` file. These can be set on the CLI when calling `terraform`
as shown below.

```
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
```

A note on these variables:
- `subnet_ocid` is the id of the subnet the client VMs will be deployed to, which
should be the same subnet as the cluster nodes.
- `availability_domain` is the AD of this subnet, eg `YVsm:EU-FRANKFURT-1-AD-1`
- `nodes` is a comma separated string of cluster node IPs, eg `10.0.0.4,10.0.0.2,10.0.0.3`
- `test_name` is any name for your test
- `par` is the PAR URL used to upload results, eg `https://objectstorage.eu-frankfurt-1.oraclecloud.com/p/HHO7R_4sjAnR1BdYP0NC7RJb48HZuvheoVjsRnvTHCY/n/intmahesht/b/pdfs-test/o/`

Alternatively, some or all of the variables can be set in the `variables.tf` file
following the form:
```
variable "key" {
  type    = "string"
  default = "value"
}
```

On a unix like system testing a cluster deployed with TF that has node IPs in
its outputs (specifically an output called `Node private IPs`) you can simply run
the following. Note, `deploy.sh` attempts to parse `terraform.tfstate` using `jq` at
`CLUSTER_TF_PATH` and can fail if this is unset to the file has unexpected values.

```
export CLUSTER_TF_PATH="/path/to/cluster_tf"
export PAR='https://your_par_url'
export TEST_NAME='some_test_name'
./deploy.sh
```
