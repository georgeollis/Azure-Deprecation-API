
function getAzureDeprections {
        
    try {
        [xml]$xmldoc = (iwr "https://aztty.azurewebsites.net/rss/deprecations").Content.Substring(1) # Get Azure deprecations
    }
    catch {
        throw $_.Exception.Message
    }
    
    
    $list = [System.Collections.ArrayList]@() # Create an empty array

    foreach ($item in $xmldoc.rss.channel.item) {

        $date = [datetime](((($item.description).Split(",")[1]).Trim() | Select-String -Pattern "\d{1,2}/\d{1,2}/\d{4}").Matches.Value) # Regex find date pattern
        $service = ($item.description).Split(",")[0].Split(":")[1].Trim() # Select the service name
        $period = $item.description.Split(",")[2].Split(":")[1].Trim()
        $title = ($item.title).Trim() # Remove white space from title
        $publishedDate = [datetime]$item.pubDate


        $object = [PSCustomObject]@{
            title          = $title
            deprectionDate = $date
            link           = $item.link.href
            service        = $service
            deprecated     = [bool]($date -lt (Get-Date))
            publishedDate  = $publishedDate
            targetPeriod   = $period
        }

        $list.Add($object) | Out-Null # Add custom object to the array.
        

    }

    return $list
    
}
