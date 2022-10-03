# DownloadInstall Chocolatey as PackageManager
# Change SecurityProtocol for downloading from Chocolatey
[System.Net.ServicePointManager]::SecurityProtocol = 'Tls12'
Invoke-Expression ( New-Object System.Net.WebClient ).DownloadString( 'https://chocolatey.org/install.ps1' )
# Install Microsoft Edge for business version 105.0.1343.53
# Microsoft Edge for business @ https://www.microsoft.com/en-us/edge/business/download
# Microsoft Edge for business version 105.0.1343.53 GPO Templates @ https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/2fcd5b49-8774-4541-a5a8-5714b9569859/MicrosoftEdgePolicyTemplates.cab
Invoke-Expression -Command '& C:\ProgramData\chocolatey\choco install microsoft-edge --version=105.0.1343.53 -y -f'
