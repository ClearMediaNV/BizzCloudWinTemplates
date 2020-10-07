# Installation of RDS Session Host will restart the System
Set-Service -Name 'WSearch' -StartupType 'Auto'
Set-Service -Name 'SCardSvr' -StartupType 'Auto'
Set-Service -Name 'Audiosrv' -StartupType 'Auto'
Install-WindowsFeature -Name Windows-TIFF-IFilter
Install-WindowsFeature -Name RDS-RD-Server
Install-WindowsFeature -Name RDS-Licensing
Install-WindowsFeature -Name RDS-Licensing-UI, RSAT-RDS-Licensing-Diagnosis-UI
Get-CimInstance -Namespace 'root/cimv2/TerminalServices' -ClassName 'Win32_TerminalServiceSetting' | Set-CimInstance -Argument  @{EnableDFSS=0;EnableDiskFSS=0;EnableNetworkFSS=0}
Restart-Computer
