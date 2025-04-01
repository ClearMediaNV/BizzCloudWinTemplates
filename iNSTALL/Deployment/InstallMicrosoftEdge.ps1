# DownloadInstall Chocolatey as PackageManager
# Change SecurityProtocol for downloading from Chocolatey
[System.Net.ServicePointManager]::SecurityProtocol = 'Tls12'
Invoke-Expression ( New-Object System.Net.WebClient ).DownloadString( 'https://chocolatey.org/install.ps1' )
# Install Microsoft Edge for business version 134.0.3124.85
# Microsoft Edge for business @ https://www.microsoft.com/en-us/edge/business/download
# Microsoft Edge for business version 134.0.3124.85 GPO Templates @ https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/f94674ed-88af-484e-b169-7c62f6769c8f/MicrosoftEdgePolicyTemplates.cab
Invoke-Expression -Command '& C:\ProgramData\chocolatey\choco install microsoft-edge --version=134.0.3124.85 -y -f'
