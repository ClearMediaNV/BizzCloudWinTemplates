# Download & Install Chocolatey as PackageProvider
[System.Net.ServicePointManager]::SecurityProtocol = 'Tls,Tls11,Tls12'
Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')
# Install vmware-tools version 11.0.5.15389592
Invoke-Expression -Command '& C:\ProgramData\chocolatey\choco install vmware-tools --version 11.0.5.15389592 -y --force'
If ( $LASTEXITCODE -eq 3010 ) { Restart-Computer }
