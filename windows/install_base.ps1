# =============================================================================
# Install the basic requirements for Windows software
# =============================================================================

# Url and path for each executable

$url_dx = "http://download.microsoft.com/download/8/4/A/84A35BF1-DAFE-4AE8-82AF-AD2AE20B6B14/directx_Jun2010_redist.exe"
$path_dx = "C:\temp\directx.exe"
 
$url_net4 = "http://download.microsoft.com/download/9/5/A/95A9616B-7A37-4AF6-BC36-D6EA96C8DAAE/dotNetFx40_Full_x86_x64.exe"
$path_net4 = "C:\temp\dotNetFx40.exe"

$url_net45 = "http://download.microsoft.com/download/E/2/1/E21644B5-2DF2-47C2-91BD-63C560427900/NDP452-KB2901907-x86-x64-AllOS-ENU.exe"
$path_net45 = "C:\temp\dotNetFx45.exe"

$WebClient = New-Object System.Net.WebClient

# Download each file

$WebClient.DownloadFile($url_dx, $path_dx)
$WebClient.DownloadFile($url_net4, $path_net4)
$WebClient.DownloadFile($url_net45, $path_net45)

# Launch each installation in silent mode

Start-Process $path_dx "/q" -Wait
Start-Process $path_net4 "/q" -Wait
Start-Process $path_net45 "/q" -Wait