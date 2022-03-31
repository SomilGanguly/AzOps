$context = Get-AzContext
$context.Subscription.Id = "eeb60d7a-bd88-4f37-ba87-195374cdbf2a"
$odataFilter = "`$filter=subscriptionId eq 'eeb60d7a-bd88-4f37-ba87-195374cdbf2a'"
$parameters = @{
    DefaultProfile = $Context | Select-Object -First 1
    ODataQuery     = $odataFilter
}
    $parameters.ResourceGroupName = "biceptest"
    $resourceGroup.ResourceGroupName = "biceptest"
$resources=Get-AzResource @parameters -ExpandProperties -ErrorAction Stop

foreach ($resource in ($resources )) {
    $exportParameters = @{
        Resource                = $resource.ResourceId
        ResourceGroupName       = "biceptest"
        SkipAllParameterization = $true
        Path                    = $tempExportPath
        DefaultProfile          = $Context | Select-Object -First 1
    }
    Export-AzResourceGroup @exportParameters -Confirm:$false -Force | Out-Null
    $exportResources = (Get-Content -Path $tempExportPath | ConvertFrom-Json).resources
    foreach ($exportResource in ($exportResources)) {
            
            if (Get-Member -InputObject $exportResource -name 'dependsOn') {
                $exportResource.PsObject.Members.Remove('dependsOn')
            }
            $resourceHash = @{resources = @($exportResource) }
            # & $azOps {
            #     ConvertTo-AzOpsState -Resource $resourceHash -ChildResource $ChildResource -StatePath $runspaceData.Statepath
            # }
        
    }
}