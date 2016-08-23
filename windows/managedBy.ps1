<#
.SYNOPSIS
Permet le création d'un fichier Excel avec l'ensemble des groupes et le gestionnaire si il existe

.DESCRIPTION
Script permettant la création d'un fichier Excel regroupant, par feuille, l'ensemble des groupes dans un OU donée avec le gestionnaire associé.

.EXAMPLE
.\managedBy.ps1

.NOTES
    File Name  : managedBy.ps1
    Author     : Nicolas Le Gall - contact <at> nlegall <dot> fr
#>

# =============================================================================
# Variables

if(($dc = (Get-ADDomainController).Name) -eq "") { $dc = Read-Host "Nom/IP du DC" }
$domaine = $env:USERDNSDOMAIN.Split(".")
$partition = "DC=$($domaine[0]),DC=$($domaine[1])"
# Crédentials de l'user
$mycred = Get-Credential
$file_directory = "$HOME\Desktop\"
# Nom du fichier de sortie
$file_name = "ManagedBy.xlsx"
$file_output = $file_directory + $file_name

$list = @("OU=Partages,$partition", "OU=Imprimantes,$partition", "OU=Interfaces,$partition", "OU=Applications,$partition")

$excel = New-Object -ComObject "Excel.Application"
 
$WorkBook = $excel.Workbooks.Add()
 
foreach($search in $list)
{
    $WorkSheet = $WorkBook.WorkSheets.Add()
    $WorkSheet.Name = $search.Split("=")[1].Split(",")[0]
    $WorkSheet.Select()
    $partages = Invoke-Command -ComputerName $dc -ScriptBlock { (Get-ADGroup -Filter * -SearchBase $args[0] -Properties Name,ManagedBy) } -credential $mycred -ArgumentList $search
    for($i = 0; $i -lt $partages.Length; $i++)
    {
        $WorkSheet.Cells.Item($i,1) = $partages[$i].name
        if ($partages[$i].ManagedBy -ne $null) { $WorkSheet.Cells.Item($i,2) = $partages[$i].ManagedBy.Split(",")[0].Split("=")[1] }
        #Write-Host $partages[$i].name
    }
}

$WorkBook.SaveAs($file_output)

$excel.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel)