# DownloadInstall Chocolatey as PackageManager
[System.Net.ServicePointManager]::SecurityProtocol = 'Tls12'
Invoke-Expression ( [System.Net.WebClient]::New().DownloadString( 'https://chocolatey.org/install.ps1' )
# Install SysInternals
Invoke-Expression -Command '& C:\ProgramData\chocolatey\choco install sysinternals -y -f'
# Install SpaceSniffer
Invoke-Expression -Command '& C:\ProgramData\chocolatey\choco install spacesniffer -y -f'
# Install SetUserFTA
Invoke-Expression -Command '& C:\ProgramData\chocolatey\choco install setuserfta -y -f'
# Install WinDirStat
Invoke-Expression -Command '& C:\ProgramData\chocolatey\choco install windirstat -y -f'
