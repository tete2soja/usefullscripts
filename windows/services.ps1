# =============================================================================
# Perform few actions inorder to optimise Windows :
#  - desactive useless services
#  - reduce waiting time for shutdown
#  - add a folder for all options on desktop
#  - defragmentation on boot
#  - delete unusing dll
#  - one processus for each explorer window
#  - show file extensions and hidden files
#  - starter menu faster
#  - reduce waiting time for processus
#  - increase buffer size
#  - caching kernel
#  - disable UAC
# =============================================================================


echo "=============================="
echo "|     Services Windows       |"
echo "=============================="

# Array for services
$serviceW7 = "hidserv","napagent","PeerDistSvc","SensrSvc","IPBusEnum","CscService","AppMgmt","hkmsvc","p2psvc","WPCSvc","ehSched","ehRecvr","TabletInputService","TBS","idsvc"
$serviceList = "iphlpsvc","lmhosts","SCardSvr","TrkWks","SessionEnv","UI0Detect","QWAVE","WinRM","p2pimsvc","VaultSvc","fdPHost","WdiSystemHost","SNMPTRAP","RpcLocator","lltdsvc","Netlogon","SharedAccess","wercplsupport","AxInstSV","CertPropSvc","PNRPsvc","FDResPub","UmRdpService","RemoteRegistry","WbioSrvc","BDESVC","WwanSvc","PcaSvc","ALG","bthserv","PNRPAutoReg","WerSvc","DPS","WPDBusEnum","WdiServiceHost","MSiSCSI","WMPNetworkSvc","TermService","SCPolicySvc","WcsPlugInService","Fax","WebClient","wcncsvc"

if ((Get-CimInstance Win32_OperatingSystem).Version -like '6.1.*') {
    echo "Windows 7 dedecte"
    for($i = 0; $i -le $serviceList.length - 1; $i++)
    {
        Write-Host "Service"$serviceW7[$i]"desactive" -nonewline
        echo ""
        Set-Service -Name $serviceW7[$i] -Computer localhost -StartupType "Disabled"
    }
}


for($i = 0; $i -le $serviceList.length - 1; $i++)
{
    Write-Host "Service"$serviceList[$i]"desactive" -nonewline
    echo ""
    Set-Service -Name $serviceList[$i] -Computer localhost -StartupType "Disabled"
}


$desktopPath = [Environment]::GetFolderPath("Desktop")
$godFolder = $desktopPath + '\GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}'
New-Item -Path $godFolder -ItemType directory


$RegKey = "HKLM:\Software\Microsoft\Dfrg\BootOptimizeFunction"
Set-ItemProperty -Path $RegKey -Name Optimizecomplete -Value No


$RegKey = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer"
New-ItemProperty $RegKey -Name "AlwaysUnloadDll" -Value 1 -PropertyType "DWord"


$RegKey = "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
New-ItemProperty $RegKey -Name "SeparateProcess" -Value 1 -PropertyType "DWord"


$RegKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Set-ItemProperty -Path $RegKey -Name HideFileExt -Value 0
Set-ItemProperty -Path $RegKey -Name Hidden -Value 1


$RegKey = "HKCU:\Control Panel\Desktop"
Set-ItemProperty -Path $RegKey -Name MenuShowDelay -Value 0


$RegKey = "HKLM:\SYSTEM\CurrentControlSet\Control"
New-ItemProperty $RegKey -Name "WaitToKillServiceTimeout2" -Value 2000 -PropertyType "String"


$RegKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
New-ItemProperty $RegKey -Name "IoPageLockLimit" -Value 983040 -PropertyType "DWord"


$RegKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
Set-ItemProperty -Path $RegKey -Name DisablePagingExecutive -Value 1


$RegKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
Set-ItemProperty -Path $RegKey -Name EnableLUA -Value 0