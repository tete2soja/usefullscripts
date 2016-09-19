<#
.SYNOPSIS
    to do

.DESCRIPTION
    to do

.EXAMPLE
    .\rightsShares.ps1

.NOTES
    File Name  : rightsShares.ps1
    Author     : Nicolas Le Gall - contact <at> nlegall <dot> fr
#>

$i = 0

$exclude = @("BUILTIN\Administrateurs", "CREATEUR PROPRIETAIRE")
$filePath = "C:\temp\tmp.csv"

Remove-Item $filePath
$servers = (Get-ADComputer -Filter * -SearchBase "OU=Serveurs,DC=kermene,DC=fr" -Properties Description) | Select Name, Description
Add-Content $filePath "Gestionnaire;Serveur;Partage;Chemin;Membres;Autorisations"
foreach($server in $servers)
{
    write-progress -id 1 -activity "Serveurs" -status "$($server.name)" -percentComplete (($i/$servers.Count) * 100)
    $i++
    try
    {
        $shares = Get-WmiObject win32_share -ComputerName $($server.name) -ErrorAction Stop
        $j = 0
        ForEach($share in $shares)
        {
            write-progress -id 2 -parentId 1 -activity "Partages" -status "$($share.Name)" -percentComplete (($j/$shares.Count) * 100)
            $j++
            if(!($share.Name.Contains('$')))
            {
                try
                {
                    $acls = Get-WmiObject win32_LogicalShareSecuritySetting -Filter "name='$($share.Name)'" -ComputerName $($server.name)
                    $acls = $acls.GetSecurityDescriptor().Descriptor.DACL
                    foreach($acl in $acls)
                    {
                        switch($acl.AccessMask) 
                        { 
                            2032127 {$Perm = "Full Control"} 
                            1245631 {$Perm = "Change"} 
                            1179817 {$Perm = "Read"} 
                        }
                        Add-Content $filePath "$($server.Description);$($server.name);$($share.name);$($share.Path);$($acl.Trustee.Name);$Perm"
                    }
                    try
                    {
                        $rights = get-acl "\\$($server.name)\$($share.name)" -ErrorAction Stop | select AccessToString
                        $rights = $rights -split '[\r\n]'
                        $total = ""
                        foreach($right in $rights)
                        {
                            $tmp = ($right -split " A")[0]
                            if (!($exclude.Contains($tmp)))
                            {
                                $total += $tmp + " - "
                            }
                        }
                        $total = $total.Substring("17")
                        Add-Content $filePath "$($server.Description);$($server.name);$($share.name);$($share.Path);;;$total"
                    }
                    catch [System.Management.Automation.ActionPreferenceStopException]
                    {
                        Add-Content $filePath ";;;;;NA"
                    }
                }
                catch [System.Management.Automation.RuntimeException]
                {
                    Add-Content $filePath ""
                }
            }
         }
    }
    catch [Exception]
    {
        Add-Content $filePath "$($server.Description);$($server.name);NOK"
    }
}