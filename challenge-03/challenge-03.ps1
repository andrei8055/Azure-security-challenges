##Challenge 1 

##Variables
$resourceGroupName = "0xpwnlab"
$webappStorageAccName = "0xpwnwebappstorageacc"
$appserviceplanName = "0xpwnappserviceplan"
$location = "West Europe"
$storageAccType = "Standard_LRS"
$containerName = "images"
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
    az storage account create --resource-group $resourceGroupName --name $webappStorageAccName --location $location --sku $storageAccType --access-tier Cool

    ##Create container 
    az storage container create --name $containerName --public-access "off" --account-name $webappStorageAccName

    ##Enable soft delete
    az storage account blob-service-properties update --account-name $webappStorageAccName --resource-group $resourceGroupName --enable-delete-retention true --delete-retention-days 7

    ##Upload webapp benign files
    az storage blob upload --container-name $containerName --account-name $webappStorageAccName --file ".\resources\1.png" --name "1.png"
    az storage blob upload --container-name $containerName --account-name $webappStorageAccName --file ".\resources\2.png" --name "2.png"
    az storage blob upload --container-name $containerName --account-name $webappStorageAccName --file ".\resources\3.png" --name "3.png"
    az storage blob upload --container-name $containerName --account-name $webappStorageAccName --file ".\resources\flag.txt" --name "flag.txt"
    az storage blob delete --container-name $containerName --account-name $webappStorageAccName --name "flag.txt" 

    ##Get connection string
    $ConnString = az storage account show-connection-string -g $resourceGroupName -n $webappStorageAccName --query "connectionString" -o tsv
    
    ##Replace connection string in application source code
    Copy-Item .\config\app.py.bak -Destination .\webapp\app.py
    ((Get-Content -path .\webapp\app.py -Raw) -replace 'AZURE_CTF_CONNECTION_STRING', $ConnString) | Set-Content -Path .\webapp\app.py
    ((Get-Content -path .\webapp\app.py -Raw) -replace 'AZURE_CTF_CONTAINER_NAME', 'images') | Set-Content -Path .\webapp\app.py

    ##Deploy web app
    cd ".\webapp"
    az webapp up --sku S1 --name $webappName --resource-group $resourceGroupName --plan $appserviceplanName --location $location
    cd ..

    ##Remove connection string in application source code
    Copy-Item .\config\app.py.bak -Destination .\webapp\app.py

    ##Whitelist our IP for access the app
    az webapp config access-restriction add --priority 200 --resource-group $resourceGroupName -n $webappName --rule-name "CTF Only" --action Allow --ip-address $ip.ip

}

Install-PythonReq
Init
Create-WebappChallenge
