resource "azurerm_network_interface" "interface" {
  for_each = toset(local.function)
  name                = "${each.key}-interface"
  location            = local.location  
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnetA.id
    private_ip_address_allocation = "Dynamic"    
  }

  depends_on = [
    azurerm_virtual_network.appnetwork
  ]
}


resource "azurerm_windows_virtual_machine" "vm" {
  for_each = toset(local.function)
  name                = "${each.key}vm"
  resource_group_name = local.resource_group_name
  location            = local.location 
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"
  admin_password      = "Azure@123"      
    network_interface_ids = [
    azurerm_network_interface.interface[each.key].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  depends_on = [
    azurerm_virtual_network.appnetwork,
    azurerm_network_interface.interface
  ]
}