##Challenge 2 

##Variables
$resourceGroupName = "0xpwnlab"
$webappStorageAccName = "0xpwnstorageacc"
$appserviceplanName = "0xpwnserviceplan"
$location = "West Europe"
$storageAccType = "Standard_LRS"
$containerName = "public"
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
    ##Deploy web app
    cd ".\webapp"
    az webapp up --sku S1 --name $webappName --resource-group $resourceGroupName --plan $appserviceplanName --location $location
    cd ..

    ##Whitelist our IP for access the app
    az webapp config access-restriction add --priority 200 --resource-group $resourceGroupName --name $webappName --rule-name "CTF Only" --action Allow --ip-address $ip.ip

    ##Set environment variables
    az webapp config appsettings set --resource-group $resourceGroupName  --name $webappName --settings "flag=e98bd50154903c87ecce53e1ecd217a9"
}  

Install-PythonReq
Init
Create-WebappChallenge
