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
    .\checkLocalAccount.ps1

.NOTES
    File Name  : checkLocalAccount.ps1
    Author     : Nicolas Le Gall - contact <at> nlegall <dot> fr
#>

# =============================================================================
# Fonctions

function commonCheck
{
    param(
        [String]$target,
        [String]$os,
        [String[]]$groupeNames
    )

    $list_users = $target + ";OK;" + $os + ";"

    foreach($groupeName in $groupeNames)
    {
        # groupe utilisateur bureau à distance
        $local_members = Invoke-Command -ComputerName $target -ScriptBlock { net localgroup $args[0] } -credential $mycred -ArgumentList $groupeName 2>$null
        # Si réponse positive
        if ($local_members.Length -gt 8)
        {
            # Mise sous forme de tableau
            $local_members = $local_members.Split("`r`n")
            # Suppression des lignes de retour de commande
            $taille = ($local_members.Length - 2)

            Write-Host "Utilisateurs"$groupeName" :"
            # Suppression des en-têtes
            for($i = 6; $i -lt $taille; $i++)
            {
                Write-Host $local_members[$i]
                $output += $local_members[$i] + " - "
            }
            $output = $output.Substring(0, $output.Length - 3)
        }
        else
        {
            Write-Host "Aucun utilisateur dans le groupe"
            $output = "-"
        }
        Write-Host "output : "$output
        $list_users += $output + ";"
        $output = "" 
    }
    $output += $list_users
    # Write-Host "file line : "$output
    Add-Content -Path $file_output $output";"
}

# =============================================================================
# Variables

# DC
if(($dc = (Get-ADDomainController).Name) -eq "") { Write-Host "Aucun serveur DC trouvé"; exit -1 }
$partition = (Get-ADDomainController).DefaultPartition
# Crédentials de l'user
$mycred = Get-Credential
# Chemin du fichier de sortie
$file_directory = "$HOME\Desktop\"
# Nom du fichier de sortie
$file_name = "users.csv"
$file_output = $file_directory + $file_name
# Liste des groupes voulus
$groupeNames = @("Utilisateurs du Bureau à distance","Administrateurs","Remote Management Users","Administrators")

# =============================================================================
# Vérification d'un précédent fichier
if (Test-Path $file_output)
{
    $confirm = Read-Host "Le fichier existe déjà. Confirmer la suppression du fichier [o/n]"
    if (!$confirm.Equals("o"))
    {
        Write-Host "Fin du script..." -ForegroundColor Red
        exit 0
    }
    else
    {
        Write-Host "Suppression du fichier..." -ForegroundColor DarkRed
        Remove-Item $file_output
    }
}

Write-Host "Création du fichier..."
New-Item -Path $file_directory -Name $file_name -Type file

# Création des colonnes
$colonnes = "Nom de la machine;Ping;OS;"
foreach($groupeName in $groupeNames)
{
    $colonnes += $groupeName + ";"
}
Add-Content -Path $file_output $colonnes

# -----------------------------------------------------------------------------
# Serveurs
# -----------------------------------------------------------------------------
$serveurs = Get-ADComputer -Filter * -SearchBase "OU=Serveurs,$partition" -Properties OperatingSystem

foreach($serveur in $serveurs)
{
    Write-Host "Verification "$serveur.Name
    $connected = Test-Connection $serveur.Name -Quiet -Count 2
    if ($connected)
    {
        Write-Host "Connexion OK" -ForegroundColor DarkGreen
        commonCheck $serveur.Name $serveur.OperatingSystem $groupeNames
    }
    else
    {
        Write-Host "Connexion KO" -ForegroundColor DarkRed
        $out = $serveur.Name + ";NOK;" + $serveur.OperatingSysten + ";;-;-;-;"
        Add-Content -Path $file_output $out
    }
}

# -----------------------------------------------------------------------------
# Ordinateurs
# -----------------------------------------------------------------------------
$ordinateurs = Get-ADComputer -Filter * -SearchBase "OU=Ordinateurs,$partition" -Properties OperatingSystem

foreach($ordinateur in $ordinateurs)
{
    Write-Host "Verification "$ordinateur.Name
    $connected = Test-Connection $ordinateur.Name -Quiet -Count 2
    if ($connected)
    {
        Write-Host "Connexion OK"

        # ---------------------------------------------------------------------
        # membres de la stratégie locale "connexion à l'ordinateur"
        # ---------------------------------------------------------------------
        # Récupération de la liste des membres
        $users = Invoke-Command -ComputerName $ordinateur.Name -ScriptBlock { secedit /export /cfg C:\Windows\Temp\secpol.ini | Out-Null;
            (Get-Content C:\Windows\Temp\secpol.ini | Select-String -Pattern SeInteractiveLogonRight | %{$_.Line.Split("=")}).Split(",");
            Remove-Item C:\Windows\Temp\secpol.ini } -credential $mycred
        # Cast sous forme de liste
        $users = [System.Collections.Generic.List[System.Object]]$users
        # Suppression du nom de la liste
        $users.RemoveAt(0)

        Write-Host "Utilisateurs autorisé à se connecter :"
        foreach($user in $users)
        {
            # Formatage
            $user = ($user.Replace(" ","")).Replace("*","")
            try
            {
                # Conversion du SID en username
                $userName = (New-Object System.Security.Principal.SecurityIdentifier($user)).Translate([System.Security.Principal.NTAccount]).value
                Write-Host $user "-" $userName
            }
            catch [MethodInvocationException]
            {
                Write-Host $user                
            }
            $userName = ""
        }

        commonCheck $ordinateur.Name $ordinateur.OperatingSystem $groupeNames
    }
    else
    {
        Write-Host "Connexion KO" -ForegroundColor DarkRed
        $out = $ordinateur.Name + ";NOK;" + $ordinateur.OperatingSysten + ";;-;-;-;"
        Add-Content -Path $file_output $out
    }
}