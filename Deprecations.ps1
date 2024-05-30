
function Get-AzureDeprections {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][bool]$FutureOnly = $false
    )
    
    try {
        [xml]$xmldoc = (Invoke-WebRequest -Uri "https://aztty.azurewebsites.net/rss/deprecations").Content.Substring(1) # Get Azure deprecations
    }
    catch {
        throw $_.Exception.Message
    }
    
    
    $list = [System.Collections.ArrayList]@() # Create an empty array

    foreach ($item in $xmldoc.rss.channel.item) {

        $date = (((($item.description).Split(",")[1]).Trim() | Select-String -Pattern "\d{1,2}/\d{1,2}/\d{4}").Matches.Value) # Regex find date pattern
        $service = ($item.description).Split(",")[0].Split(":")[1].Trim() # Select the service name
        $title = ($item.title).Trim() # Remove white space from title


        $object = [PSCustomObject]@{
            title          = $title
            deprectionDate = [datetime]$date
            link           = $item.link.href
            service        = $service
            deprecated     = [bool]([datetime]$date -lt (Get-Date))
        }

        $list.Add($object) | Out-Null # Add custom object to the array.
        

    }
    
}
