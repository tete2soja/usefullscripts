<#
.SYNOPSIS
    Donne une ensemble d'information sur le poste cible avec un rendu sous format HTML
.DESCRIPTION
    Le script affiche un ensemble d'informations sur le poste cible via un ensemble de 
    requetes CIM (ou WMI si CIM non disponible). L'ensemble des donnees est ensuite 
    mis en forme dans un fichier HTML portant le nom de la machine cible stocké a la
    racine du lecteur logique C.
.PARAMETER Target
    Nom du pc cible. Si le parametre n'est pas renseigne, le nom du PC courrant sera utilise.
.INPUTS
    Nom du PC cible
.OUTPUTS
    Fichier HTML portant le nom de la cible avec l'ensemble des informations
.EXAMPLE
    .\infoPC.ps1
    Lance le script sur le PC courrant
.EXAMPLE
    .\infoPC.ps1 -Target ComputerName
    Lance le script sur ComputerName
.NOTES
    File Name  : infoPC.ps1
    Author     : Nicolas Le Gall - contact <at> nlegall <dot> fr
#>

[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline=$True)]
    [string]$Target = $env:COMPUTERNAME
)

$computerName = $Target

# =============================================================================
# Vérification de l'existance du poste du le réseau
if (!(Test-Connection -computername $computerName -Quiet -Count 1)) {
    Write-Host -BackgroundColor Red "Le nom du PC n'est pas correct"
    exit -1
}

# =============================================================================
# Style CSS pour le rendu HTML
$style = "<style>
body {
    font-family: Tahoma, Geneva, Kalimati, sans-serif;
}
table, th, td {
    border: 1px solid black;
    border-collapse: collapse;
}
</style>"

# =============================================================================

Write-Host "Inventaire du poste $computerName"

Write-Host "Get informations about network..."
$networkCard = Get-CimInstance -ComputerName $computerName -Class Win32_NetworkAdapterConfiguration -Filter "IPEnabled='$true'" | select IPAddress,Speed,Index

Write-Host "Get informations about shares..."
$shares = (Get-CimInstance -ComputerName $computerName -Class Win32_Share).Name

Write-Host "Get informations about disks..."
$disks = Get-CimInstance -ComputerName $computerName -Class Win32_LogicalDisk | where {$_.MediaType -eq 12} | select Name,Size,FreeSpace,@{n="UseSpace";e={$_.Size - $_.FreeSpace}}

Write-Host "Get informations about PC..."
$infoPC = Get-CimInstance -ComputerName $computerName -class Win32_ComputerSystem | select username,Name,Domain,Manufacturer,Model,TotalPhysicalMemory

Write-Host "Get informations about OS..."
$os = (Get-CimInstance -ComputerName $computerName -Class Win32_OperatingSystem | select caption,buildnumber,version,OSLanguage)

Write-Host "Get informations about CPU..."
$cpu = Get-CimInstance -ComputerName $computerName -Class Win32_Processor | select Name,NumberOfCores

Write-Host "Get informations about serial..."
$serial = $((Get-CimInstance -ComputerName $computerName -Class Win32_Bios).SerialNumber)

Write-Host "Get informations about installed softwares..."
#$applications = Get-WMIObject -ComputerName $computerName win32_SoftwareFeature | select ProductName,Version -Unique | sort ProductName

$ip = $networkCard.IPAddress

$speed = ""
foreach($card in $networkCard) {
    $tmp = Get-CimInstance Win32_NetworkAdapter | where { $_.Index -eq $card.Index }| select speed
    $tmp = $tmp.Speed / 1MB
    $speed = $('{0:N0}' -f $tmp) + " MB"
}

$content = "<h1>Informations sur le poste</h1>"
Write-Host "Nom d'utilisateur : $($infoPC.username)"
$content += "<u>Nom d'utilisateur :</u> $($infoPC.username)<br/>"
Write-Host "Nom du PC : $($infoPC.Name)"
$content += "<u>Nom du PC :</u> $($infoPC.Name)<br/>"
Write-Host "Domaine : $($infoPC.Domain)"
$content += "<u>Domaine :</u> $($infoPC.Domain)<br/>"

$content += "<h1>Informations sur le matériel</h1>"
Write-Host "Modèle : $($infoPC.Manufacturer) $($infoPC.Model)"
$content += "<u>Modèle :</u> $($infoPC.Manufacturer) $($infoPC.Model)<br/>"
Write-Host "Serial : $serial"
$content += "<u>Serial :</u> $serial<br/>"

$osName = $os.Caption
Write-Host "OS : $osName"
$content += "<u>OS :</u> $osName<br/>"
Write-Host "Version : $($os.Version)"
$content += "<u>Version :</u> $($os.Version)<br/>"

# Langue système
if ($os.OSLanguage -eq 1036) {
    $langue = "Français"
}
elseif ($os.OSLanguage -eq 1033) {
    $langue = "Anglais"
}
else { $langue = "Inconnue" }
Write-Host "Langue : $langue"
$content += "<u>Langue :</u> $langue<br/>"

Write-Host "CPU : $($cpu.Name)"
$content += "<u>CPU :</u> $($cpu.Name)<br/>"
$ram = $infoPC.TotalPhysicalMemory / 1GB
$ram = $('{0:N0}' -f $ram)
Write-Host "RAM : $ram GB"
$content += "<u>RAM :</u> $ram GB<br/>"

Write-Host "Adresse IP : $ip"
$content += "<u>Adresse IP :</u> $ip<br/>"
Write-Host "Vitesse de la carte : $speed"
$content += "<u>Vitesse de la carte :</u> $speed<br/><br/>"
$content += "<h2>Disques</h2>"
Write-Host "Disques :"
$content += "<table><tr><td>Nom</td><td>Espace total</td><td>Utilisé</td><td>Libre</td><td>Pourcentage</td></tr>"
foreach($disk in $disks) {
    $content += "<tr>"
    $name = $disk.Name
    $total = $disk.Size / 1GB
    $used = $disk.UseSpace / 1GB
    $free = $disk.FreeSpace / 1GB
    $pourcentage = $disk.UseSpace / $disk.Size * 100

    Write-Host "    Nom : $name"
    $content += "<td>$name</td>"
    Write-Host "    Espace total : $('{0:N2}' -f $total) GB"
    $content += "<td>$('{0:N2}' -f $total)</td>"
    Write-Host "    Utilisé : $('{0:N2}' -f $used) GB"
    $content += "<td>$('{0:N2}' -f $used)</td>"
    Write-Host "    Libre : $('{0:N2}' -f $free) GB"
    $content += "<td>$('{0:N2}' -f $free)</td>"
    Write-Host "    Pourcentage : $('{0:N2}' -f $pourcentage) %"
    $content += "<td>$('{0:N2}' -f $pourcentage)</td></tr>"
}
$content += "</table><br/>"
$content += "<table><tr><td>Nom</td></tr>"
$content += "<h2>Partages ouverts</h2>"
Write-Host "Partages ouverts :"
foreach($share in $shares) {
    $content += "<tr>"
    Write-Host "Nom : $share"
    $content += "<td>$share</td>"
    $content += "</tr>"
}
$content += "</table>"

Write-Host "Liste des applications"
$content += "<h2>Liste des applications</h2>"
Write-Host $applications
$content += "<table><tr><td>Nom</td><td>Version</td><td>Date d'installation</td></tr>"
foreach($application in $applications) {
    $content += "<tr>"
    $content += "<td>$($application.ProductName)</td>"
    $content += "<td>$($application.Version)</td>"
    $content += "</tr>"
}
$content += "</table>"

$office = Get-WMIObject -ComputerName $computerName win32_SoftwareFeature | select ProductName,Version -Unique | sort ProductName | where {$_.ProductName -like "Microsoft Office*" }

# Ecriture du résultat dans le fichier HTML
ConvertTo-Html -Title "$computerName - Infos" -Body $content - $style | Out-File C:\$computerName.html

# MaJ du fichier pour les statistiques
if ( !(Test-Path C:\stats.csv) ) { Out-File -FilePath C:\stats.csv -Encoding "utf8" -InputObject "buildnumber,name,ram,cpu,coeur,office,officeVersion" }
Out-File -Append -FilePath C:\stats.csv -Encoding "utf8" -InputObject "$($os.buildnumber),$($os.Caption),$ram,$($cpu.Name),$($cpu.NumberOfCores),$($office.ProductName),$($office.Version)"