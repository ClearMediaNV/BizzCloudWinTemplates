# Installation of RDS Session Host will restart the System
# Set RDS related Services to Automatic Start
Set-Service -Name 'WSearch' -StartupType 'Auto'
Set-Service -Name 'SCardSvr' -StartupType 'Auto'
Set-Service -Name 'Audiosrv' -StartupType 'Auto'
# Install Essential RDS Features & Roles
Install-WindowsFeature -Name Windows-TIFF-IFilter
Install-WindowsFeature -Name RDS-RD-Server
Install-WindowsFeature -Name RDS-Licensing
Install-WindowsFeature -Name RDS-Licensing-UI, RSAT-RDS-Licensing-Diagnosis-UI
# Disable RDS Fair Share on Cpu,Disk,Network Aka Handbrake
Get-CimInstance -Namespace 'root/cimv2/TerminalServices' -ClassName 'Win32_TerminalServiceSetting' | Set-CimInstance -Argument  @{EnableDFSS=0;EnableDiskFSS=0;EnableNetworkFSS=0}
Restart-Computer
