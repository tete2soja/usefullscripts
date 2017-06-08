<#
.SYNOPSIS
    Le script permet de forcer la synchronisation d'un objet ou ensemble
    d'objets AD entre l'ensemble des DC présents dans l'AD

.DESCRIPTION
    Le script permet de forcer la synchronisation d'un objet ou ensemble
    d'objets AD entre l'ensemble des DC présents dans l'AD

.EXAMPLE
    .\syncAD.ps1 nlegall

    Synchronise l'objet spécifié sur l'ensemble des DC

.EXAMPLE
    .\syncAD.ps1 users

    Synchronise l'ensemble des utilisateurs de l'AD sur l'ensemble des DC

.EXAMPLE
    .\syncAD.ps1 computers

    Synchronise l'ensemble des ordinateurs de l'AD sur l'ensemble des DC

.NOTES
    File Name  : syncAD.ps1
    Author     : Nicolas Le Gall - contact <at> nlegall <dot> fr
    Date       : 30/12/2016
#>

# =============================================================================
# Fonctions

# Update the object for each DC in the AD domain
function updateDC
{
    param(
        [Object]$object
    )

    $i = 0
    $count = $dcs.Count

    foreach($dc in $dcs.Keys)
    {
        Write-Progress -Id 2 -Activity "DC" -Status "$($dc) $i/$count" -PercentComplete (($i/$count) * 100)
        Start-Sleep -Seconds 1
        try
        {
            Sync-ADObject -Object $object -Destination $dc
        }
        catch [Exception]
        {
            Write-Host -ForegroundColor Red "$($object.Name) sur $dc : NOK"
        }
        $i++
    }
}


# =============================================================================
# Variables

# Get the domain name
$domain = (Get-ADDomain).Forest
# Get all DC in the domain
$temp = (Get-ADForest $domain).GlobalCatalogs
$filter = $args[0]
$i = 0

# =============================================================================

if ($filter -eq $null -or $filter -eq "")
{
    Write-Host ".\syncAD.ps1 [filter]"
    exit -1
}

# Hashmap because need dynamic add
$dcs = @{}

# Check connection for each DC
foreach($dc in $temp)
{
    if (Test-Connection -Count 1 -Quiet $dc)
    {
        $dcs.Add($dc, "OK")
    }
}

# If the string ending by two digits
if ($filter -match '\B\d\d')
{
    $objects = Get-ADObject -Filter { name -eq $filter }
}
elseif ($filter -eq "computers")
{
    $objects = Get-ADComputer -Filter *
}
elseif ($filter -eq "users")
{
    $objects = Get-ADUser -Filter *
}
else
{
    $objects = Get-ADObject -Filter { SamAccountName -eq $filter }
}

if ($objects -eq $null)
{
    Write-Host "Aucun objet trouvé avec le filtre spécifié"
    exit -2
}

# Total of objects for show progression
$count = $objects.Count

if ($count -gt 1) {
    foreach($object in $objects)
    {
        Write-Progress -Id 1 -Activity "Update" -Status "$($object.Name) $i/$count" -PercentComplete (($i/$count) * 100)
        #Write-Host "Mise à jour de : "$object.Name
        updateDC($object)
        Write-Host ""
        $i++
    }
}
else
{
    updateDC($objects)    
}