resource "azurerm_virtual_network" "terra-vnet-terra" {
  name                = "vnet-terra"
  address_space       = ["10.0.0.0/16"]
  location            = "westeurope"
  resource_group_name = "${azurerm_resource_group.terra-RG-testTerraform.name}"
}

resource "azurerm_subnet" "terra-s01" {
  name                 = "s01"
  resource_group_name  = "${azurerm_resource_group.terra-RG-testTerraform.name}"
  virtual_network_name = "${azurerm_virtual_network.terra-vnet-terra.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_network_interface" "terra-netint" {
  name                = "netint"
  location            = "westeurope"
  resource_group_name = "${azurerm_resource_group.terra-RG-testTerraform.name}"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${azurerm_subnet.terra-s01.id}"
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_managed_disk" "terra-datadisk" {
  name                 = "datadisk_existing"
  location             = "westeurope"
  resource_group_name  = "${azurerm_resource_group.terra-RG-testTerraform.name}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1023"
}

resource "azurerm_virtual_machine" "terra-vmtest" {
  name                  = "vmtest"
  location              = "westeurope"
  resource_group_name   = "${azurerm_resource_group.terra-RG-testTerraform.name}"
  network_interface_ids = ["${azurerm_network_interface.terra-netint.id}"]
  vm_size               = "Standard_DS1_v2"


  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name            = "${azurerm_managed_disk.terra-datadisk.name}"
    managed_disk_id = "${azurerm_managed_disk.terra-datadisk.id}"
    create_option   = "Attach"
    lun             = 1
    disk_size_gb    = "${azurerm_managed_disk.terra-datadisk.disk_size_gb}"
  }

  os_profile {
    computer_name  = "vmtest"
    admin_username = "adminvm"
    admin_password = "Password123$"
  }

      
  os_profile_windows_config {
    enable_automatic_upgrades = false
  }

}