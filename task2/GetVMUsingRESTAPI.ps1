#Invoke-RestMethod -Headers @{"Metadata"="true"} -Method GET -NoProxy -Uri "http://169.254.169.254/metadata/instance?api-version=2021-02-01" | ConvertTo-Json -Depth 64 

#Generate access token
Login-AzAccount
$azContext = Get-AzContext
$azProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
$profileClient = New-Object -TypeName Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient -ArgumentList ($azProfile)
$token = $profileClient.AcquireAccessToken($azContext.Subscription.TenantId)
$authHeader = @{
   'Content-Type'  = 'application/json'
   'Authorization' = 'Bearer ' + $token.AccessToken
}

#get vm details via REST call 
$restUri = "https://management.azure.com/subscriptions/e935453b-2b6a-4694-ae9f-75cba85ee3bc/resourceGroups/testrg/providers/Microsoft.Compute/virtualMachines/testvm?api-version=2018-10-01"
$response = Invoke-RestMethod -Uri $restUri -Method Get -Headers $authHeader |  ConvertTo-Json -Depth 64 
$response

#save json output to file
cd C:\
$response > ./testvminstance.json