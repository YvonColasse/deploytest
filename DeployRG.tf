# création du ressources group
resource "azurerm_resource_group" "terra-RG-testTerraform" {
    name = "RG-testTerraform"
    location = "westeurope"
}