# Terraform-Rancher-GCP-Nodes-Example
Terraform configuration for quickly standup k8s workers in an existing Rancher Server.

I used this for a quick hello world.

# Set Up
1.- Put `credentials.json` GCP file in root of the project.

2.- I create a variables.conf file in project source and put this values:
```
export TF_VAR_token="<RANCHER_TOKEN>"
export TF_VAR_checksum="<RANCHER_CHECKSUM>"
export TF_VAR_address="<RANCHER_SERVER_ADDRESS>"
export TF_VAR_gcp_project="<PROJECT_NAME>"
export TF_VAR_gcp_region="us-west1"
export TF_VAR_nodes=2
```

You can create also a `terraform.tfvars` for this :)