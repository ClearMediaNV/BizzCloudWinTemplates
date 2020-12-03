# DownloadInstall Chocolatey as PackageProvider
[System.Net.ServicePointManager]::SecurityProtocol = 'Tls,Tls11,Tls12'
Invoke-Expression ( New-Object System.Net.WebClient ).DownloadString( 'https://chocolatey.org/install.ps1' )
# Install vmware-tools version 11.0.6.15940789
Invoke-Expression -Command '& C:\ProgramData\chocolatey\choco install vmware-tools --version=11.1.5.16724464 -y -f'
If ( $LASTEXITCODE -eq 3010 ) { Restart-Computer }
