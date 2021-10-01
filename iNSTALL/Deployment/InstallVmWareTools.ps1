# DownloadInstall Chocolatey as PackageProvider
# Change SecurityProtocol for downloading from Chocolatey
$SavedSecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol
[System.Net.ServicePointManager]::SecurityProtocol = 'Tls12'
Invoke-Expression ( New-Object System.Net.WebClient ).DownloadString( 'https://chocolatey.org/install.ps1' )
# Install vmware-tools version 11.3.5.18557794
Invoke-Expression -Command '& C:\ProgramData\chocolatey\choco install vmware-tools --version=11.3.5.18557794 -y -f'
# Restore Saved SecurityProtocol
[System.Net.ServicePointManager]::SecurityProtocol = $SavedSecurityProtocol
If ( $LASTEXITCODE -eq 3010 ) { Restart-Computer }
