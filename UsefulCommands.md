# Useful Commands

## az commands:

```
az account list-locations \
  --query "[].{Name: name, DisplayName: displayName}" \
  --output table
  ...
  
Name                DisplayName
------------------  --------------------
eastasia            East Asia
southeastasia       Southeast Asia
centralus           Central US
eastus              East US
eastus2             East US 2
westus              West US
northcentralus      North Central US
southcentralus      South Central US
northeurope         North Europe
westeurope          West Europe
japanwest           Japan West
japaneast           Japan East
brazilsouth         Brazil South
australiaeast       Australia East
australiasoutheast  Australia Southeast
southindia          South India
centralindia        Central India
westindia           West India
canadacentral       Canada Central
canadaeast          Canada East
uksouth             UK South
...
  ```

```
az webapp list --resource-group my-rg --output table
```

```
az group list \
  --query "[?contains(@.name, 'my-rg')].{name: name}" \
  --output tsv
```
