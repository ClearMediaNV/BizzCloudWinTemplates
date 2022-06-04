# DownloadInstall Chocolatey as PackageManager
[System.Net.ServicePointManager]::SecurityProtocol = 'Tls12'
Invoke-Expression ( New-Object System.Net.WebClient ).DownloadString( 'https://chocolatey.org/install.ps1' )
# Install StickyNotes
Invoke-Expression -Command '& C:\ProgramData\chocolatey\choco install simple-sticky-notes -y -f'
