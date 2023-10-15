provider "azurerm" {
  client_id       = "58ee68b7-b696-4aa1-b586-2f0af1f5098e"
  client_secret   = "dzH8Q~Kchdy0xbmk1TDV~L8mEb2T3d6t6mqPHcc2"
  subscription_id = "58ee68b7-b696-4aa1-b586-2f0af1f5098e"
  tenant_id       = "3eff799d-0a57-4672-b97f-3690098ef323"
  features        = {}
}

resource "azurerm_resource_group" "example" {
  name     = "VMrg"
  location = "East US"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "example" {
  name                = "nic1"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "example" {
  name                  = "vm001"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.example.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "example-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = "adminuser"
  }

  os_profile_linux_config {
    disable_password_authentication = true
  }
}
