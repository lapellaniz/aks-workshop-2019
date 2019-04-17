variable "client_id" {}
variable "client_secret" {}

variable "agent_count" {
    default = 3
}

variable "ssh_public_key" {
    default = "C:\\Users\\lapellan\\.ssh\\id_rsa.pub"
}

variable "dns_prefix" {
    default = "lra"
}

variable cluster_name {
    default = "aks-workshop-lra-tf"
}

variable resource_group_name {
    default = "akschallenge-tf"
}

variable location {
    default = "Central US"
}

variable log_analytics_workspace_name {
    default = "akschallenge-monitoring-tf"
}

# refer https://azure.microsoft.com/global-infrastructure/services/?products=monitor for log analytics available regions
variable log_analytics_workspace_location {
    default = "eastus"
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing 
variable log_analytics_workspace_sku {
    default = "PerGB2018"
}