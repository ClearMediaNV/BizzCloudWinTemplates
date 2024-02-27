# DownloadInstall Chocolatey as PackageManager
# Change SecurityProtocol for downloading from Chocolatey
[System.Net.ServicePointManager]::SecurityProtocol = 'Tls12'
Invoke-Expression ( New-Object System.Net.WebClient ).DownloadString( 'https://chocolatey.org/install.ps1' )
# Install Microsoft Edge for business version 121.0.2277.128
# Microsoft Edge for business @ https://www.microsoft.com/en-us/edge/business/download
# Microsoft Edge for business version 121.0.2277.128 GPO Templates @ https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/224658bc-d5fa-426d-92ae-fd5b64566108/MicrosoftEdgePolicyTemplates.cab
Invoke-Expression -Command '& C:\ProgramData\chocolatey\choco install microsoft-edge --version=121.0.2277.128 -y -f'
