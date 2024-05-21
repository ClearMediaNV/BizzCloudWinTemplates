# DownloadInstall Chocolatey as PackageManager
# Change SecurityProtocol for downloading from Chocolatey
[System.Net.ServicePointManager]::SecurityProtocol = 'Tls12'
Invoke-Expression ( New-Object System.Net.WebClient ).DownloadString( 'https://chocolatey.org/install.ps1' )
# Install Microsoft Edge for business version 124.0.2478.105
# Microsoft Edge for business @ https://www.microsoft.com/en-us/edge/business/download
# Microsoft Edge for business version 124.0.2478.97 GPO Templates @ https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/75eeb64a-9021-4366-b602-840c2d3b343e/MicrosoftEdgePolicyTemplates.cab
Invoke-Expression -Command '& C:\ProgramData\chocolatey\choco install microsoft-edge --version=124.0.2478.105 -y -f'
