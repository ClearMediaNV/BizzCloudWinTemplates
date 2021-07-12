# DownloadInstall Chocolatey as PackageProvider
[System.Net.ServicePointManager]::SecurityProtocol = 'Tls,Tls11,Tls12'
Invoke-Expression ( New-Object System.Net.WebClient ).DownloadString( 'https://chocolatey.org/install.ps1' )
# Install vmware-tools version 11.2.5.17337674
Invoke-Expression -Command '& C:\ProgramData\chocolatey\choco install vmware-tools --version=11.2.5.17337674 -y -f'
If ( $LASTEXITCODE -eq 3010 ) { Restart-Computer }
