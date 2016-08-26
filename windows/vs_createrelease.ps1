Copy-Item .\Release\* .\Final\ -Recurse
rm .\Final\*vshost*
rm .\Final\*.pdb
Compress-Archive -Path .\Final\* -DestinationPath release.zip
Write-Host "SHA256 :"(Get-FileHash -Algorithm SHA256 .\release.zip).Hash
Write-Host "MD5 :"(Get-FileHash -Algorithm SHA256 .\release.zip).Hash
Remove-Item -Force -Recurse .\Final