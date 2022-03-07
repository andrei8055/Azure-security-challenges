##Challenge 1 

##Variables
$resourceGroupName = "0xpwnlab"
$blobStorageAccName = "0xpwnstorageacc"
$location = "West Europe"
$storageAccType = "Standard_LRS"
$containerName = "public"


function Init {
    az login
    az group delete --name $resourceGroupName --yes
    az group create --name $resourceGroupName --location $location
}

function Create-PublicBlobChallenge  {
    ##Create storage account
    az storage account create --resource-group $resourceGroupName --name $blobStorageAccName --location $location --sku $storageAccType --access-tier Cool

    ##Create container 
    az storage container create --name $containerName --public-access container --account-name $blobStorageAccName

    ##Upload blob flag
    az storage blob upload  --account-name $blobStorageAccName --container-name $containerName --file ".\flags\flag.txt" --name "flag.txt"
}  


Init
Create-PublicBlobChallenge
