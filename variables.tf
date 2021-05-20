
variable "resourcegroup" {
  description = "Name of the resource group"
  default     = "terraform-k8s-kubeadm"
}

variable "az-backend" {
  description = "Backend for terraform in Azure"
  default     = "mystickenshin "
}

variable "location" {
  description = "Location of the resources"
  default     = "East US"
}

variable "prefix" {
  description = "prefix"
  default     = "k8sdev"
}

variable "vmname" {
  description = "Name of the VM"
  type        = list(string)
  default     = ["k8sdev-master", "k8sdev-slave"]
}

