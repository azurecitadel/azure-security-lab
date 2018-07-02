$rg = (new-azurermresourcegroup -name Contoso-IaaS -Location westus2).ResourceGroupName
$rg2 = (new-azurermresourcegroup -name Contoso-PaaS -Location westus2).ResourceGroupName
$outputs = (new-azurermresourcegroupdeployment -Name infraSecLab -ResourceGroupName $rg -TemplateUri https://raw.githubusercontent.com/azurecitadel/azure-security-lab/master/azuredeploy/azuredeploy.json).Outputs

$DestStorageAccount = $outputs.storageAccountName.Value
$SourceStorageAccount = "infraseclab"
$destStorageKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $rg -accountName $DestStorageAccount).value[0]
$sasToken = "?sv=2017-04-17&sr=c&si=infraseclab&sig=ONnlr56sGeZt0Qekgs8NFHquG5gGZU2jaFRnKp4bdXM%3D"
$SourceStorageContext = New-AzureStorageContext –StorageAccountName $SourceStorageAccount -SasToken $sasToken
$DestStorageContext = New-AzureStorageContext –StorageAccountName $DestStorageAccount -StorageAccountKey $DestStorageKey
$SourceStorageContainer = 'infraseclab'
$DestStorageContainer = (new-azurestoragecontainer -Name contoso -permission Container -context $DestStorageContext).name

$Blobs = (Get-AzureStorageBlob -Context $SourceStorageContext -Container $SourceStorageContainer)
foreach ($Blob in $Blobs)
{
   Write-Output "Moving $Blob.Name"
   Start-CopyAzureStorageBlob -Context $SourceStorageContext -SrcContainer $SourceStorageContainer -SrcBlob $Blob.Name `
      -DestContext $DestStorageContext -DestContainer $DestStorageContainer -DestBlob $Blob.Name
}

Write-Output "***** IaaS Lab Ready :-) *****"
new-azurermresourcegroupdeployment -Name infraSecpaasLab -ResourceGroupName $rg2 -TemplateUri https://raw.githubusercontent.com/azurecitadel/azure-security-lab/master/azuredeploy/azuredeploy-paas.json
Write-Output "***** PaaS Lab Ready :-) *****"