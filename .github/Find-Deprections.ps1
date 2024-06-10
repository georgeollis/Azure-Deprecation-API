
function getAzureDeprections {
        
    try {
        # [xml]$xmldoc = (iwr -Uri "https://aztty.azurewebsites.net/rss/deprecations").Content.Substring(1) # Get Azure deprecations
        [xml]$xmldoc = (Invoke-WebRequest -Uri "https://aztty.azurewebsites.net/rss/deprecations").Content
    }
    catch {
        throw $_.Exception.Message
    }
    
    $list = [System.Collections.ArrayList]@() # Create an empty list

    foreach ($item in $xmldoc.rss.channel.item) {

        $itemBeingRetired = ($item.description | Select-String -Pattern "\[([^\]]+)\]").Matches.Value.Split(",").Split(":").Replace("[", "").Replace("]", "").Trim()
        $service = $itemBeingRetired[1]
        $date = [datetime]$itemBeingRetired[3]
        $period = $itemBeingRetired[5]
        $title = ($item.title).Trim() # Remove white space from title
        $publishedDate = [datetime]$item.pubDate
        $description = ($item.description | Select-String -Pattern "(?<=^|])([^][]+)(?=\[|$)").Matches.Value.Trim()

        $object = [PSCustomObject]@{
            title          = $title
            deprectionDate = $date
            link           = $item.link.href
            service        = $service
            deprecated     = [bool]($date -lt (Get-Date))
            description    = $description
            publishedDate  = $publishedDate
            targetPeriod   = $period
            id             = ($xmldoc.rss.channel.item).IndexOf($item)
            resourceType   = resourceTypeConversion($service)
        }

        $list.Add($object) | Out-Null # Add custom object to the array.
        

    }

    return $list
    
}

function resourceTypeConversion {
    [CmdletBinding()]
    param (
        [Parameter()][string]$resource
    )

    switch ($resource) {
        "Data Factory" { $value = "Microsoft.DataFactory/factories" } 
        "Virtual Machines" { $value = "Microsoft.Compute/virtualMachines" }
        "Container Apps" { $value = "" }
        "ExpressRoute" { $value = "" }
        "Managed Disks" { $value = "" }
        "Load Balancer" { $value = "" }
        "Logic Apps" { $value = "" }
        "Virtual Desktop" { $value = "" }
        "Application Gateway" { $value = "Microsoft.Network/applicationGateways" }
        "Azure AI Services" { $value = "" }
        "Notification Hubs" { $value = "" }
        "Container Registry" { $value = "" }
        "Microsoft Sentinel" { $value = "" }
        "Virtual Network" { $value = "" }
        "App Service" { $value = "" }
        "Machine Learning" { $value = "Microsoft.MachineLearningServices/workspaces" }
        "Azure Storage" { $value = "" }
        "Cosmos DB" { $value = "" }
        "VPN Gateway" { $value = "" }
        "Kubernetes Service" { $value = "Microsoft.ContainerService/ManagedClusters" }
        "API Management" { $value = "Microsoft.ApiManagement/service" }
        Default { $value = "noResourceType" }
    }

    return $value

}
