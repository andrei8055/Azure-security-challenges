$resourceGroupName = "AZ-CTF"
$vmName = "0xpwnvm"
$vmUser = "0xpwn"
$vmPass = "0xPwn0xPwn!!!"
$location = "West Europe"

az login

az group delete --name $resourceGroupName --yes
az group create --name $resourceGroupName --location $location

az vm create --resource-group $resourceGroupName --name $vmName --image "UbuntuLTS" --admin-username $vmUser --admin-password $vmPass --authentication-type "password" --location $location --custom-data cloud-init.txt

az vm open-port --port 80 --resource-group $resourceGroupName --name $vmName