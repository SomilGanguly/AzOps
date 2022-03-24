foreach ($resource in ($resources )) {
    $exportParameters = @{
        Resource                = $resource.ResourceId
        ResourceGroupName       = $resourceGroup.ResourceGroupName
        SkipAllParameterization = $true
        Path                    = $tempExportPath
        DefaultProfile          = $Context | Select-Object -First 1
    }
    Export-AzResourceGroup @exportParameters -Confirm:$false -Force | Out-Null
    $exportResources = (Get-Content -Path $tempExportPath | ConvertFrom-Json).resources
    foreach ($exportResource in ($exportResources)) {
            Write-PSFMessage -Level Verbose @msgCommon -String 'Get-AzOpsResourceDefinition.Subscription.Processing.ChildResource' -StringValues $exportResource.Name, $resourceGroup.ResourceGroupName -Target $exportResource
            $ChildResource = @{
                resourceProvider = $exportResource.type -replace '/', '_'
                resourceName     = $exportResource.name -replace '/', '_'
                parentResourceId = $resourceGroup.ResourceId
            }
            if (Get-Member -InputObject $exportResource -name 'dependsOn') {
                $exportResource.PsObject.Members.Remove('dependsOn')
            }
            $resourceHash = @{resources = @($exportResource) }
            # & $azOps {
            #     ConvertTo-AzOpsState -Resource $resourceHash -ChildResource $ChildResource -StatePath $runspaceData.Statepath
            # }
        
    }
}