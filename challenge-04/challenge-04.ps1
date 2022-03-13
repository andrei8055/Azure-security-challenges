##Challenge 4

##Variables
$resourceGroupName = "0xpwnlab"
$blobStorageAccName = "0xpwnstorageacc"
$appserviceplanName = "0xpwnappserviceplan"
$location = "West Europe"
$storageAccType = "Standard_LRS"
$imagesContainerName = "images"
$flagContainerName = "flags"
$webappName = "0xpwnwebapp"

$ip = Invoke-RestMethod http://ipinfo.io/json

function Init {
    az login
    az group delete --name $resourceGroupName --yes
    az group create --name $resourceGroupName --location $location
}

function Install-PythonReq {
    cd .\webapp
    python3 -m venv .venv
    .venv\scripts\activate
    pip install -r requirements.txt
    deactivate
    cd ..
}

function Create-WebappChallenge {
    ##Create storage account
    az storage account create --resource-group $resourceGroupName --name $blobStorageAccName --location $location --sku $storageAccType --access-tier Cool

    ##Create containers
    az storage container create --name $flagContainerName --public-access "off" --account-name $blobStorageAccName
    az storage container create --name $imagesContainerName --public-access "off" --account-name $blobStorageAccName

    ##Upload blob flag
    az storage blob upload  --account-name $blobStorageAccName --container-name $flagContainerName --file ".\flags\flag.txt" --name "flag.txt"

    ##Upload dummy images
    az storage blob upload --container-name $imagesContainerName --account-name $blobStorageAccName --file ".\resources\1.png" --name "1.png"
    az storage blob upload --container-name $imagesContainerName --account-name $blobStorageAccName --file ".\resources\2.png" --name "2.png"
    az storage blob upload --container-name $imagesContainerName --account-name $blobStorageAccName --file ".\resources\3.png" --name "3.png"

    ##Deploy web app
    cd ".\webapp"
    az webapp up --sku S1 --name $webappName --resource-group $resourceGroupName --plan $appserviceplanName --location $location
    cd ..

    ##Get Storage Account ID
    $storageAccountID = az storage account show --name $blobStorageAccName  --query id -o tsv

    ##Assign web app identity
    az webapp identity assign -g $resourceGroupName -n $webappName --role "Reader and Data Access" --scope $storageAccountID

    ##Whitelist our IP for access the app
    az webapp config access-restriction add --priority 200 --resource-group $resourceGroupName -n $webappName --rule-name "CTF Only" --action Allow --ip-address $ip.ip

}

Install-PythonReq
Init
Create-WebappChallenge
