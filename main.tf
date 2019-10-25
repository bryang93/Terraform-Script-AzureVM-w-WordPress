# Create Resource Group
resource "azurerm_resource_group" "WordPress" {
  name     = "${var.rg}"
  location = "${var.loc}"
}

# Network Security Group
resource "azurerm_network_security_group" "WordPressNSG" {
  name                = "WordPressNSG"
  location            = "${var.loc}"
  resource_group_name = "${var.rg}"
  
  security_rule {
    name                       = "SSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  
  security_rule {
    name                       = "HTTP"
    priority                   = 2000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# VNet
resource "azurerm_virtual_network" "WordPressVNet" {
  name                = "WordPressVNet"
  location            = "${var.loc}"
  resource_group_name = "${var.rg}"
  address_space       = ["10.0.0.0/16"]
}

# Subnet Config
resource "azurerm_subnet" "SubnetWp" {
  name                 = "SubnetWp"
  resource_group_name  = "${var.rg}"
  virtual_network_name = "${azurerm_virtual_network.WordPressVNet.name}"
  address_prefix       = "10.0.2.0/24"
}

# public IP address
resource "azurerm_public_ip" "WordPressIP" {
  name                = "${var.wp}IP"
  location            = "${var.loc}"
  resource_group_name = "${var.rg}"
  allocation_method   = "Dynamic"
  domain_name_label   = "myfirstwpvm"
}

# Nic
resource "azurerm_network_interface" "WordPressNic" {
  name                      = "WordPressNic"
  location                  = "${var.loc}"
  resource_group_name       = "${var.rg}"
  network_security_group_id = "${azurerm_network_security_group.WordPressNSG.id}"

  ip_configuration {
    name                          = "WordPressConfiguration"
    subnet_id                     = "${azurerm_subnet.SubnetWp.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.WordPressIP.id}"
  }
}

# VM
resource "azurerm_virtual_machine" "WordPressVM" {
  name                  = "${var.wp}VM"
  location              = "${var.loc}"
  resource_group_name   = "${var.rg}"
  network_interface_ids = ["${azurerm_network_interface.WordPressNic.id}"]
  vm_size               = "Standard_DS1_v2"

  delete_data_disks_on_termination = true
  delete_os_disk_on_termination    = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.wp}osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "host"
    admin_username = "ScriptUser"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

# VMExtension for WP
resource "azurerm_virtual_machine_extension" "WordPressVMExt" {
  name                       = "WordPressVMExt"
  location                   = "${var.loc}"
  resource_group_name        = "${var.rg}"
  virtual_machine_name       = "${azurerm_virtual_machine.WordPressVM.name}"
  publisher                  = "Microsoft.Azure.Extensions"
  type                       = "CustomScript"
  type_handler_version       = "2.0"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
        "fileUris":["https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/wordpress-single-vm-ubuntu/install_wordpress.sh"],"commandToExecute":"sh install_wordpress.sh"
    }
SETTINGS
}
