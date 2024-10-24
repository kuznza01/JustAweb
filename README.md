# JustAweb Project
Objective: To become familiar with Azure Bicep.  Using Bicep to be able to deploy generic web tier application, Csomosdb, and Azure Key Vault.

In order to use project you will need Azure CLI and a Resource Group in Azure.

1. Download to your execution environment

2. Open PowerShell

3. Navigate to your templates folder
      Set-Location -Path templates

4. Connect to your AZ subscription
      Connect-AzAccount

5. Optionally ensure you are conencted to the correct context ( you should have selected this when you ran the previous command)
      $context = Get-AzSubscription -SubscriptionName '...'
      Set-AzContext $context

6. If you do not a resource group setup them please set one up.  Once it is created then set the context for the execution
      Set-AzDefault -ResourceGroupName <your resurce group name>

7. Run the Bicep deployment command
      New-AzResourceGroupDeployment -TemplateFile .\main.bicep -environmentType nonprod -rootName <basename> -objectId $(az ad signed-in-user show --query id -o tsv)

      Note: <basename> must start with a letter, can be between 3 and 15 characters, must have some numbers in it, cannot have special characters, and must be lowercase letters.