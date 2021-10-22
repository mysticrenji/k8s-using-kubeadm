# Create resouce group
resource "azurerm_resource_group" "resourcegroup" {
  name     = var.resourcegroup
  location = var.location
}

#Create VNET with Subnet
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
  address_space       = ["172.10.0.0/16"]

  # subnet {
  #   name           = "${var.prefix}-subnet"
  #   address_prefix = "172.10.1.0/24"
  # }

  tags = {
    environment = "k8sdev"
  }
}

#Create subnet within VNET
resource "azurerm_subnet" "subnet" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.resourcegroup.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["172.10.1.0/24"]
}

#Create Public IP
resource "azurerm_public_ip" "publicip" {
  for_each = toset(var.vmname)
  name     = join("-nic", [each.value])
  #name                = "${var.prefix}-publicip"
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
  allocation_method   = "Static"
  domain_name_label   = join("-node", [each.value])


  tags = {
    environment = "k8sdev"
  }
}

#Create network interface card 
resource "azurerm_network_interface" "nic" {
  for_each            = toset(var.vmname)
  name                = join("-nic", [each.value])
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name

  ip_configuration {
    name                          = "testconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip[each.key].id #azurerm_public_ip.publicip.id
  }
}

module "compute" {
  source           = "./modules/compute"
  for_each         = toset(var.vmname)
  vmname           = each.value
  resourcegroup    = azurerm_resource_group.resourcegroup.name
  location         = azurerm_resource_group.resourcegroup.location
  nic              = [azurerm_network_interface.nic[each.key].id]
  publickey        = file("~/.ssh/id_rsa.pub")
  vmsize           = each.value == "k8sdev-master" ? "Standard_D2s_v3" : "Standard_B2s" # "Standard_D2S_v3"
  public_ip        = [azurerm_public_ip.publicip[each.key].fqdn]
  private_key_path = "~/.ssh/id_rsa"
  depends_on       = [azurerm_network_interface.nic]
}


