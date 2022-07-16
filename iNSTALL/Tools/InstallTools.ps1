# DownloadInstall Chocolatey as PackageManager
[System.Net.ServicePointManager]::SecurityProtocol = 'Tls12'
Invoke-Expression ( New-Object System.Net.WebClient ).DownloadString( 'https://chocolatey.org/install.ps1' )
# Install SysInternals
Invoke-Expression -Command '& C:\ProgramData\chocolatey\choco install sysinternals -y -f'
# Install SpaceSniffer
Invoke-Expression -Command '& C:\ProgramData\chocolatey\choco install spacesniffer -y -f'
# Install SetUserFTA
Invoke-Expression -Command '& C:\ProgramData\chocolatey\choco install setuserfta -y -f'
# Install windirstat
Invoke-Expression -Command '& C:\ProgramData\chocolatey\choco install windirstat -y -f'
