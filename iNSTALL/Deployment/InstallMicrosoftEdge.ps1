# DownloadInstall Chocolatey as PackageProvider
[System.Net.ServicePointManager]::SecurityProtocol = 'Tls,Tls11,Tls12'
Invoke-Expression ( New-Object System.Net.WebClient ).DownloadString( 'https://chocolatey.org/install.ps1' )
# Install Microsoft Edge for business version 87.0.664.60
# Microsoft Edge for business @ https://www.microsoft.com/en-us/edge/business/download
# Microsoft Edge for business version 87.0.664.60 GPO Templates @ https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/18e904a4-9e4a-46be-a34a-176fb3e90465/MicrosoftEdgePolicyTemplates.zip
Invoke-Expression -Command '& C:\ProgramData\chocolatey\choco install microsoft-edge --version=87.0.664.60 -y -f'
