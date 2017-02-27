<#
.SYNOPSIS
    Le script permet de modifier l'ensemble des quotas de manière automatique.

.DESCRIPTION
    Modification automatique des quotas dépassant un pourcentage défini et
    inférieur à une taille donnée. Un rapport sous forme de tableau regroupant
    les 20 plus gros quotas est également envoyé par mail.

.EXAMPLE
    .\quotas.ps1

.NOTES
    File Name  : quotas.ps1
    Author     : Nicolas Le Gall - contact <at> nlegall <dot> fr
#>

# =============================================================================
# Variables
$i = 0
$j = 0
$year = Get-Date -UFormat %Y
$pathLog = "logs\log_" + $year + ".csv"
$date = Get-Date -Format g

if (!(Test-Path $pathLog))
{
    Add-Content $pathLog "Date;Chemin;Quota"
}

$colItems = Get-FsrmQuota

$modif_quod = "<h1>Augmentations effectuees</h1><table style=`"border-collapse: collapse;`"><tr><td>Nom</td><td>Utilisation (GB)</td><td>Total (GB)</td><td>Occupation (%)</td></tr>"

foreach ($objItem in $colItems)
{ 
    #Write-Host "QuotaUsed : " $objItem.Usage 
    #Write-Host "QuotaLimit: " $objItem.Size
    #Write-Host "Path: " $objItem.Path

    if ( ($objItem.Usage / $objItem.Size -gt 0.95) -and ($objItem.Size -lt 15GB) )
    {
        if ($objItem.Size -lt 1GB)
        {
            $size = $objItem.Size * 1.25
        }
        else
        {
            $size = $objItem.Size * 1.05
        }
        $path = $objItem.Path
        $quota = $size / 1GB
        # Changement de la taille du quota
        Set-FsrmQuota -Path $objItem.Path -Size $size
        # Ajout des informations dans le fichier de log
        Add-Content $pathLog $date";"$path";"$quota
        #Write-Host "NewQuota: " $objItem.QuotaLimit
        $j++

        $modif_quod += "<tr><td>$path</td>"
        $modif_quod += "<td>$([math]::round($objItem.Usage/1GB,2))</td>"
        $modif_quod += "<td>$quota</td>"
        $modif_quod += "<td>$([math]::round(($objItem.Usage/$objItem.Size)*100,2))</td></tr>"
    }

    # Diminution du quota si trop peu rempli
    else if ($objItem.Size -lt 0.75)
    {
        $size = $objItem.Usage / 0.90
        $path = $objItem.Path
        $quota = $size / 1GB
        Set-FsrmQuota -Path $objItem.Path -Size $size
        Add-Content $pathLog $date";"$path";"$quota
    }

    if ( $objItem.Size -gt 15GB )
    {
        $i++
    }
}

$modif_quod += "</table>"

$shares = $colItems | Sort-Object -Descending Size | Select-Object -First 20 -Property Path,Usage,@{Label="Quotas"; Expression={[math]::round($_.Size/1GB,2)}},@{Label="Pourcentage"; Expression={[math]::round(($_.Usage/$_.Size)*100,2)}}

# =============================================================================
# Creation du corps du mail
$tab = "<head><style type=`"text/css`">table{border-collapse:collapse}td,th{border:1px solid #000}</style></head>"
$tab += $modif_quod
$tab += "<h1>Top 20 quotas</h1><table style=`"border-collapse: collapse;`"><tr><td>Nom</td><td>Utilisation (GB)</td><td>Total (GB)</td><td>Occupation (%)</td><td>Responsable</td></tr>"

foreach($s in $shares)
{
    $tab += "<tr>"
    if ($s.Pourcentage -gt 95)
    {
        $tab += "<td><font color=`"red`">$($s.Path)</font></td>"
    }
    else
    {
        $tab += "<td>$($s.Path)</td>"
    }
    $tab += "<td>$([math]::round($s.Usage/1GB,2))</td>"
    $tab += "<td>$($s.Quotas)</td>"
    $tab += "<td>$($s.Pourcentage)</td>"

    $responsable = ""
    if ($s.Path -like "*partage*")
    {
        $name = $($s.Path).Split('\')[2]
        $responsable = (Get-ADGroup -Filter { name -eq $name } -Properties ManagedBy).ManagedBy
        if ($responsable -ne $null)
        {
            $responsable = $responsable.Split(',')[0].Split('=')[1]
        }
    }
    $tab += "<td>$responsable</td>"

    $tab += "</tr>"
}

$tab += "</table>"

$tab += "<h1>Top 20 des augmentation des quotas annuel</h1><table><tr><td>Nom</td><td>Nb augmentation</td></tr>"

$CSV = Import-Csv $pathLog -Delimiter ";"
$count = @{}
foreach ($line in $CSV)
{
    if ($count.ContainsKey($line.Chemin))
    {
        $count[$line.Chemin]++
    }
    else
    {
        $count.Add($line.Chemin,1)
    }
}

$count = $count.GetEnumerator() | Sort-Object -Property key | Sort-Object -Descending -Property Value | select -First 20

foreach ($a in $count)
{
    $tab += "<tr>"
    $tab += "<td>$($a.Name)</td>"
    $tab += "<td>$($a.Value)</td>"
    $tab += "</tr>"
}
$tab += "</table>"

$shares = $colItems | Where-Object { $_.Size -gt 1GB } | Select-Object -Property Path,Usage,@{Label="Quotas"; Expression={[math]::round($_.Size/1GB,2)}},@{Label="Pourcentage"; Expression={[math]::round(($_.Usage/$_.Size)*100,2)}} | Sort-Object Pourcentage | Select-Object -First 20

$tab += "<h1>Les 20 quotas les moins remplis</h1><table><tr><td>Nom</td><td>Utilisation (GB)</td><td>Total (GB)</td><td>Occupation (%)</td><td>Responsable</td></tr>"

foreach($s in $shares)
{
    $tab += "<tr>"
    if ($s.Pourcentage -gt 95)
    {
        $tab += "<td><font color=`"red`">$($s.Path)</font></td>"
    }
    else
    {
        $tab += "<td>$($s.Path)</td>"
    }
    $tab += "<td>$([math]::round($s.Usage/1GB,2))</td>"
    $tab += "<td>$($s.Quotas)</td>"
    $tab += "<td>$($s.Pourcentage)</td>"

    $responsable = ""
    if ($s.Path -like "*partage*")
    {
        $name = $($s.Path).Split('\')[2]
        $responsable = (Get-ADGroup -Filter { name -eq $name } -Properties ManagedBy).ManagedBy
        if ($responsable -ne $null)
        {
            $responsable = $responsable.Split(',')[0].Split('=')[1]
        }
    }
    $tab += "<td>$responsable</td>"

    $tab += "</tr>"
}

$tab += "</table>"

# ==== Mail ===================================================================
# Serveur de mail via le champ MX du domaine
$smtp = (Resolve-DnsName -Type MX -Name $env:USERDNSDOMAIN).NameExchange
$from = "xxx@domain.tld"
$to = "xxx@domain.tld"
$cc = @()
$cc += "xxx@domain.tld"
$cc += "xxx@domain.tld"

Send-MailMessage -From $from -To $to -Cc $cc -BodyAsHtml $tab -Subject "[Quotas] Rapport" -SmtpServer $smtp