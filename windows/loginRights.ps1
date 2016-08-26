<#
.SYNOPSIS
    Le script permet d'avoir l'ensemble des utilisateurs présents dans différents groupes
    sur l'ensemble des ordinateurs et serveurs présent dans l'AD. Le résultat est ensuite
    sorti sous format CSV.

.DESCRIPTION
    Script permettant de lister l'ensemble des utilisateurs présents dans les groupes
    "Utilisateurs du Bureau à distance" et "Administrateur" ainsi qu'autorisé à se connecter
    à distance

.EXAMPLE
    .\loginRights.ps1

.NOTES
    File Name  : loginRights.ps1
    Author     : Nicolas Le Gall - contact <at> nlegall <dot> fr
#>

# =============================================================================
# Run once

$users = Get-ADUser -Filter * | Select SamAccountName

foreach($user in $users)
{
    Write-Host "Modification de l'utilisateur"$user.SamAccountName
    #Set-ADUser $user.SamAccountName -LogonWorkstations $null
}
# =============================================================================

# =============================================================================
# For each boot

$computerName = [Environment]::MachineName
# Check AD module
if (Get-Module -ListAvailable -Name ActiveDirectory)
{
    # Get DC name
    if(($dc = (Get-ADDomainController).Name) -eq "") { Write-Host "Aucun serveur DC trouvé"; exit -1 }
    # Get domain name
    $domain = (Get-ADDomain).Forest

    $user_dn = (Get-ADComputer -Filter { Name -eq $computerName } -Properties ManagedBy).ManagedBy
    $user_san = (Get-ADUser -Filter { DistinguishedName -eq $user_dn } -Properties SamAccountName).SamAccountName
}
else
{
    # Use old LDAP request
    $rootDSE = [adsi]"LDAP://rootDSE"
    $query = new-object system.directoryservices.directorysearcher $rootDSE.defaultNamingContext
    $domain = $rootDSE.dnsHostName.ToString().Split('.')
    $domain = $domain[1] + "." + $domain[2]

    $query.filter = "(&(objectCategory=Computer)(name=$computerName))"
    $query.PropertiesToLoad.Add("name")
    $query.PropertiesToLoad.Add("managedby")
    $result = $query.findAll()

    $user_dn = $result[0].Properties.managedby

    $query.filter = "(&(objectCategory=User)(DistinguishedName=$user_dn))"
    $query.PropertiesToLoad.Add("samaccountname")
    $result = $query.findAll()

    $user_san = $result[0].Properties.samaccountname
}

secedit /export /cfg C:\Windows\Temp\secpol.ini

# Adimistrateurs locaux
$allow = "SeInteractiveLogonRight = *S-1-5-32-544"

if ($user_san -ne $null)
{
    $objUser = New-Object System.Security.Principal.NTAccount($domain, $user_san)
    $strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
    
    # Ajout du gestionnaire du PC
    $allow += ",*" + $strSID.Value
}
else
{
    # utilisateurs authentifiés
    $allow += ",*S-1-5-11"
}

$back = Get-Content C:\Windows\Temp\secpol.ini | Select-String -Pattern SeInteractiveLogonRight
$back = $back.ToString()
$back = $back.Replace("*","\*")

(Get-Content C:\Windows\Temp\secpol.ini) | Foreach-Object { $_ -replace $back, $allow } | Set-Content C:\Windows\Temp\secpol.ini

secedit /configure /cfg C:\Windows\Temp\secpol.ini /db C:\Windows\Temp\secpol.db

Remove-Item C:\Windows\Temp\secpol.ini
# =============================================================================