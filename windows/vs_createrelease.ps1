C:\Windows\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe /nologo /ds /t:build /p:Configuration=Release
Copy-Item .\bin\Release .\bin\Final -Recurse
rm .\bin\Final\*vshost*
rm .\bin\Final\*.pdb
Compress-Archive -Path .\bin\Final\* -DestinationPath .\bin\release.zip
Write-Host "SHA256 :"(Get-FileHash -Algorithm SHA256 .\bin\release.zip).Hash
Write-Host "MD5 :"(Get-FileHash -Algorithm MD5 .\bin\release.zip).Hash
Remove-Item -Force -Recurse .\bin\Final