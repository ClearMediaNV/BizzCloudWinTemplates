##########################################################
#  Please DO NOT Deploy RDS on a Standalone Server 2019  #
#           Please contact ClearMedia Support            #
##########################################################
# Installation of RDS Session Host will Restart the System
# Set RDS related Services to Automatic Start
Set-Service -Name 'WSearch' -StartupType 'Auto'
Set-Service -Name 'SCardSvr' -StartupType 'Auto'
Set-Service -Name 'Audiosrv' -StartupType 'Auto'
Set-Service -Name 'Spooler' -StartupType 'Auto'
# Install Essential RDS Features and Roles
Install-WindowsFeature -Name 'Windows-TIFF-IFilter'
Install-WindowsFeature -Name 'RDS-RD-Server'
Install-WindowsFeature -Name 'RDS-Licensing'
Install-WindowsFeature -Name ( 'RDS-Licensing-UI' , 'RSAT-RDS-Licensing-Diagnosis-UI' )
# Disable RDS Fair Share on ( Cpu , Disk , Network ) Aka HandBrake
Get-CimInstance -Namespace 'root/cimv2/TerminalServices' -ClassName 'Win32_TerminalServiceSetting' | Set-CimInstance -Argument  @{ EnableDFSS = 0 ; EnableDiskFSS = 0 ; EnableNetworkFSS = 0 }
# Add Local GPO for RDS Licensing
REG.exe ADD 'HKLM\Software\Policies\Microsoft\Windows NT\Terminal Services' /v 'LicensingMode' /t REG_DWORD /d 4 /f
REG.exe ADD 'HKLM\Software\Policies\Microsoft\Windows NT\Terminal Services' /v 'LicenseServers' /t REG_SZ /d '127.0.0.1' /f 
# Restart the System
Restart-Computer
