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

for($i = 0; $i -le $serviceList.length - 1; $i++)
{
    Write-Host "Service"$serviceList[$i]"desactive" -nonewline
    echo ""
    Set-Service -Name $serviceList[$i] -Computer localhost -StartupType "Disabled"
}