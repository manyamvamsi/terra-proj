provider "azurerm" {
    features {
      
    }
  subscription_id = "f531b2b6-7cd0-4b22-8fd2-4b0d7c1dc6e0"
  tenant_id       = "3e2a499b-1950-498f-8b33-5bdce1e144b9"
  client_id       = "5834d84a-5e7b-45f5-a916-68b902961ca6"
  client_secret   = "Sv~8Q~IxkjTh6qA~AWZBetWzAuEh47op53eF1cgW"
}

# Define the resource group and virtual network
resource "azurerm_resource_group" "iacrg1" {
  name     = "IAC-rg"
  location = "East US"
}

resource "azurerm_virtual_network" "iacvnet1" {
  name                = "IAC-vnet"
  address_space       = ["10.60.0.0/16"]
  location            = azurerm_resource_group.iacrg1.location
  resource_group_name = azurerm_resource_group.iacrg1.name
}
# Define the virtual network subnet
resource "azurerm_subnet" "iacsb1" {
  name                 = "IAC-subnet"
  resource_group_name  = azurerm_resource_group.iacrg1.name
  virtual_network_name = azurerm_virtual_network.iacvnet1.name
  address_prefixes     = ["10.60.1.0/24"]
}
resource "azurerm_public_ip" "iacip1" {
  name = "IAC-publicip"
  resource_group_name = azurerm_resource_group.iacrg1.name
  location = azurerm_resource_group.iacrg1.location
  allocation_method = "Static"
}
# Define the virtual machine network interface
resource "azurerm_network_interface" "iacnic1" {
  name                = "IAC-nic"
  location            = azurerm_resource_group.iacrg1.location
  resource_group_name = azurerm_resource_group.iacrg1.name

  ip_configuration {
    name                          = "example-ip-config"
    subnet_id                     = azurerm_subnet.iacsb1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.iacip1.id
  }
}

# Define the Linux virtual machine
resource "azurerm_linux_virtual_machine" "iacvm1" {
  name                  = "IAC-vm"
  location              = azurerm_resource_group.iacrg1.location
  resource_group_name   = azurerm_resource_group.iacrg1.name
  size                  = "Standard_DS1_v2"
  admin_username        = "adminuser"
  admin_password        = "V@msi1234567"
  network_interface_ids = [azurerm_network_interface.iacnic1.id]
  admin_ssh_key {
    username = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }
  os_disk {
    name              = "IAC-os-disk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}