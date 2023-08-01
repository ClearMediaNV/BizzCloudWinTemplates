# DownloadInstall Chocolatey as PackageManager
# Change SecurityProtocol for downloading from Chocolatey
[System.Net.ServicePointManager]::SecurityProtocol = 'Tls12'
Invoke-Expression ( New-Object System.Net.WebClient ).DownloadString( 'https://chocolatey.org/install.ps1' )
# Install vmware-tools version 12.2.5.21855600
Invoke-Expression -Command '& C:\ProgramData\chocolatey\choco install vmware-tools --version=12.2.5.21855600 -y -f'
If ( $LASTEXITCODE -eq 3010 ) { Restart-Computer }
