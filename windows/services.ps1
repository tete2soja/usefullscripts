# Array for services
echo "=============================="
echo "|     Services Windows       |"
echo "=============================="

$serviceList = "AdobeARMservice","CscService"

for($i = 0; $i -le $serviceList.length - 1; $i++)
{
    Write-Host "Service"$serviceList[$i]"desactive" -nonewline
    echo ""
    Set-Service -Name $serviceList[$i] -Computer localhost -StartupType "Disabled"
}