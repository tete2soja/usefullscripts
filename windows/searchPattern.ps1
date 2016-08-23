<#
.SYNOPSIS
    Permet de recherche une ou plusieurs expressions sur un ensemble de fichiers
    contenu dans un répertoire

.DESCRIPTION

.PARAMETER Path
    Chemin du répertoire. Il peut être relatif ou absolu.

.PARAMETER Pattern
    Ensemble des mots à rechercher dans les fichiers.

.EXAMPLE
    .\searchPattern.ps1
    Le chemin et l'ensemble des expressions vous seront alors demandé un part un

.EXAMPLE
    .\searchPattern.ps1 -Path "C:\"" -Pattern "password","passw0rd"

.NOTES
    File Name  : searchPattern.ps1
    Author     : Nicolas Le Gall - contact <at> nlegall <dot> fr
#>

param(
    [Parameter(Mandatory=$true)]
    [String]$Path,
    [Parameter(Mandatory=$true)]
    [String[]]$Pattern
)

$exclude = @('*.msi', '*.adm')
$files = Get-ChildItem -Recurse $Path -File -Exclude $exclude

$nb = $files.Count
for($i = 0; $i -lt $nb; $i++)
{
    Write-Progress -Activity "Traitement en cours" -Status "$([int]($i/$nb * 100)) % - Fichier $i sur $nb" -PercentComplete ($i/$nb * 100)
	$found = Get-Content "$($files[$i].FullName)" | Select-String -Pattern $Pattern -SimpleMatch

    if ($found -ne $null)
    {
        Write-Host "Fichier : $($files[$i].FullName)"
        Write-Host $found
    }
}
