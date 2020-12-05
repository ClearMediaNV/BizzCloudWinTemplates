DownloadInstall Chocolatey as PackageProvider
[System.Net.ServicePointManager]::SecurityProtocol = 'Tls,Tls11,Tls12'
Invoke-Expression ( New-Object System.Net.WebClient ).DownloadString( 'https://chocolatey.org/install.ps1' )
# Install SysiInternals version 2020.11.25
Invoke-Expression -Command '& C:\ProgramData\chocolatey\choco install Sysinternals -y -f'
# Install SpaceSniffer version 1.3.0.2
Invoke-Expression -Command '& C:\ProgramData\chocolatey\choco install spacesniffer -y -f'
