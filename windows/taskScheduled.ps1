<#
.SYNOPSIS
    Le script permet de modifier l'ensemble des quotas de manière automatique.

.DESCRIPTION
    Liste l'ensemble des tâches planifiées des serveurs sous forme de fichier
    CSV.

.EXAMPLE
    .\taskScheduled.ps1

.NOTES
    File Name  : taskScheduled.ps1
    Author     : Nicolas Le Gall - contact <at> nlegall <dot> fr
#>

# =============================================================================
# Variables
# Chemin du fichier de sortie
$year = Get-Date -UFormat %Y
$moth = Get-Date -UFormat %m
$day = Get-Date -UFormat %d
$path = "logs\" + $year + "_" + $moth + "_" + $day
$file_output = "logs\" + $year + "_" + $moth + "_" + $day + "\comptes_locaux.csv"

New-Item -ItemType Directory -Path "logs" -Name $($year + "_" + $moth + "_" + $day)

Add-Content -Path $file_output "Nom;Tache;Utilisateur"

$ComputerName = Get-ADComputer -Filter * -SearchBase "OU=Serveurs,DC=domain,DC=tld" | Select-Object -Property Name

foreach ($computer in $ComputerName)
{
	$schedule = new-object -ComObject Schedule.Service 
	
	try
	{
		$schedule.connect($computer.Name)
	}
	catch
	{
		Add-Content -Path $file_output -Value $computer.Name
	}
	if ($Schedule.connected)
	{
		$tasks = $Schedule.getfolder("\").gettasks(0) |  Select-Object Name, State, Path, LastRunTime, LastTaskResult, Xml
		foreach($task in $tasks)
		{
			$xml = [xml]$task.Xml
			$user = $xml.Task.Principals.FirstChild.UserId
            $value = $computer.Name + ";" + $task.Name + ";" + $user
            Add-Content -Path $file_output -Value $value
		}
	}
	
}