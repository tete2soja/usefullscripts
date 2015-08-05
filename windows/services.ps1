# =============================================================================
# Perform few actions inorder to optimise Windows :
#  - desactive useless services
#  - reduce waiting time for shutdown
# =============================================================================


echo "=============================="
echo "|     Services Windows       |"
echo "=============================="

# Array for services
$serviceW7 = "hidserv","napagent","PeerDistSvc","SensrSvc","IPBusEnum","CscService","AppMgmt","hkmsvc","p2psvc","WPCSvc","ehSched","ehRecvr","TabletInputService","TBS","idsvc"
$serviceList = "iphlpsvc","lmhosts","SCardSvr","TrkWks","SessionEnv","UI0Detect","QWAVE","WinRM","p2pimsvc","VaultSvc","fdPHost","WdiSystemHost","SNMPTRAP","RpcLocator","lltdsvc","Netlogon","SharedAccess","wercplsupport","AxInstSV","CertPropSvc","PNRPsvc","FDResPub","UmRdpService","RemoteRegistry","WbioSrvc","BDESVC","WwanSvc","PcaSvc","ALG","bthserv","PNRPAutoReg","WerSvc","DPS","WPDBusEnum","WdiServiceHost","MSiSCSI","WMPNetworkSvc","TermService","SCPolicySvc","WcsPlugInService","Fax","WebClient","wcncsvc"

if ((Get-CimInstance Win32_OperatingSystem).Version -like '6.1.*') {
    echo "Windows 7 dececte"
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