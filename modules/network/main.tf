# Create resouce group
resource "azurerm_resource_group" "resourcegroup" {
  name     = var.resourcegroup
  location = var.location
}

#Create VNET with Subnet
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  location            = var.resourcegroup
  resource_group_name = var.location
  address_space       = ["172.10.0.0/16"]

  tags = {
    environment = "k8sdev"
  }
}

#Create subnet within VNET
resource "azurerm_subnet" "subnet" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = var.resourcegroup
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["172.10.1.0/24"]
}

#Create Public IP
resource "azurerm_public_ip" "publicip" {
  for_each            = toset(var.vmname)
  name                = join("-nic", [each.value])
  location            = var.location
  resource_group_name = var.resourcegroup
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
  location            = var.location
  resource_group_name = var.resourcegroup

  ip_configuration {
    name                          = "testconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip[each.key].id #azurerm_public_ip.publicip.id
  }
}