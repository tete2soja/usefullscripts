$i = 0
$j = 0
$fsrmremote = New-Object -com Fsrm.FsrmQuotaManager
$colItems = $fsrmremote.EnumQuotas("")
foreach ($objItem in $colItems) { 
    Write-Host "QuotaUsed : " $objItem.QuotaUsed 
    Write-Host "QuotaLimit: " $objItem.QuotaLimit
    Write-Host "Path: " $objItem.Path
    Write-Host "Des: " $objItem.Description
    Write-Host "Flag: " $objItem.QuotaFlags

    <#
    if ( $objItem.QuotaUsed -lt 90000000 )
    {
        $objItem.QuotaLimit = 100000000
    }
    elseif ( $objItem.QuotaUsed -lt 1000000000 )
    {
        $objItem.QuotaLimit = $objItem.QuotaUsed * 100 / 60
    }
    elseif ( $objItem.QuotaUsed -lt 3000000000 )
    {
        $objItem.QuotaLimit = $objItem.QuotaUsed * 100 / 80
    }
    elseif ( $objItem.QuotaUsed -gt 15000000000 )
    {
        $objItem.QuotaLimit = $objItem.QuotaUsed * 100 / 95
    }
    else
    {
        $objItem.QuotaLimit = $objItem.QuotaUsed * 100 / 90
    }
    #>

    $date = Get-Date -Format g

    if ( ($objItem.QuotaUsed / $objItem.QuotaLimit -gt 0.95) -and $objItem.QuotaLimit -lt 15000000000 )
    {
        $objItem.QuotaLimit = $objItem.QuotaLimit * 1.05
        $path = $objItem.Path
        $quota = $objItem.QuotaLimit / 1024 / 1024 / 1024
        Add-Content "log.csv" $date";"$path";"$quota
        $j++
    }
    if ( $objItem.QuotaLimit -lt 15000000000 )
    {
        $i++
    }

    Write-Host "NewQuota: " $objItem.QuotaLimit
    $objItem.commit()
}

Write-Host "Quotas > 15Go : "$i
Write-Host "Quotas modifiés : "$j