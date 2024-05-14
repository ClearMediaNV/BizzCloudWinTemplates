# DownloadInstall Chocolatey as PackageManager
# Change SecurityProtocol for downloading from Chocolatey
[System.Net.ServicePointManager]::SecurityProtocol = 'Tls12'
Invoke-Expression ( New-Object System.Net.WebClient ).DownloadString( 'https://chocolatey.org/install.ps1' )
# Install Microsoft Edge for business version 124.0.2478.97
# Microsoft Edge for business @ https://www.microsoft.com/en-us/edge/business/download
# Microsoft Edge for business version 124.0.2478.97 GPO Templates @ https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/587098a7-2662-4a9d-94ab-4704c588c09e/MicrosoftEdgePolicyTemplates.cab
Invoke-Expression -Command '& C:\ProgramData\chocolatey\choco install microsoft-edge --version=124.0.2478.97 -y -f'
