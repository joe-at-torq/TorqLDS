
#Azure Provider
provider "azurerm" {
  features {}
  skip_provider_registration = true

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

#Deployment Variables
#----------------------------------------------------------------------------------

variable "client_side_region" {
  type = string
  default  = "eastus"
}

#Resouce Group
resource "azurerm_resource_group" "client_rg" {
  name     = "Torq_LDS_UI"
  location = var.client_side_region
}

#Network
resource "azurerm_virtual_network" "client_rg_network" {
  name                = "client_network"
  resource_group_name = azurerm_resource_group.client_rg.name
  location            = azurerm_resource_group.client_rg.location
  address_space       = ["10.0.0.0/16"]
}


#User Subnet
resource "azurerm_subnet" "client_rg_user_subnet" {
  name                 = "user_subnet"
  resource_group_name  = azurerm_resource_group.client_rg.name
  virtual_network_name = azurerm_virtual_network.client_rg_network.name
  address_prefixes       = ["10.0.10.0/24"]
}

#Public Ip
resource "azurerm_public_ip" "client_pip" {
    name                  = "ClientPublicIP"
    location              = azurerm_resource_group.client_rg.location
    resource_group_name   = azurerm_resource_group.client_rg.name
    allocation_method     = "Dynamic"
}

#Windows Host Nic
resource "azurerm_network_interface" "cgc_windows_client_nic" {
    name                = "myNIC"
    location              = azurerm_resource_group.client_rg.location
    resource_group_name   = azurerm_resource_group.client_rg.name

    ip_configuration {
      name                          = "NicConfiguration"
      subnet_id                     = azurerm_subnet.client_rg_user_subnet.id
      private_ip_address_allocation = "Static"
      private_ip_address            = "10.0.10.20"
      public_ip_address_id          = azurerm_public_ip.client_pip.id
    }
}

#Windows Client
resource "azurerm_virtual_machine" "ubuntuserver_2004_vm" {
  name                  = "UbuntuServer20.04"
  location              = azurerm_resource_group.client_rg.location
  resource_group_name   = azurerm_resource_group.client_rg.name
  vm_size               = "Standard_B1s"
  network_interface_ids = ["${azurerm_network_interface.cgc_windows_client_nic.id}"]
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  storage_os_disk {
    name          = "ubuntu-osdisk1"
    caching       = "ReadWrite"
    create_option = "FromImage"
    os_type       = "Linux"
  }

  os_profile {
    computer_name  = "UbuntuServer"
    admin_username = "ubuntu"
    admin_password = "1qaz!QAZ1qaz!QAZ"
  }
  
    os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "torq-lds"
  }
}
