# Push Current Directory
Push-Location -Path 'C:\install\bginfo'
# Copy Shortcut to current Desktop
Copy-Item -Path 'PresetBginfo.lnk' -Destination "$Env:USERPROFILE\Desktop" -Force
# Set Registry after SysPrep Reset - Windows Annoyances
If ( 'Z' -notin ( Get-PSDrive ).Name ) { Get-CimInstance -Namespace 'root\cimv2' -ClassName 'Win32_Volume' -Filter 'DriveType = 5' | Set-CimInstance -Argument  @{ DriveLetter = 'Z:' } }
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Disk' -Name 'TimeOutValue' -Value 600
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\ServerManager' -Name 'DoNotOpenServerManagerAtLogon' -Value 1
# Get Public IP @
Try { [System.Net.ServicePointManager]::SecurityProtocol = 'Tls12' ; Set-Item -Path 'ENV:\IpAddressPublic' -Value ( Invoke-WebRequest -Uri 'https://api.ipify.org' -UseBasicParsing ).Content }
    Catch { Set-Item -Path 'ENV:\IpAddressPublic' -Value '0.0.0.0' }
# Get NLA state
Set-Item -Path 'ENV:\NetworkCategory' -Value ( Get-NetConnectionProfile ).NetworkCategory
Set-Item -Path 'ENV:\IPv4Connectivity' -Value ( Get-NetConnectionProfile ).IPv4Connectivity
# Get Last Installed HotFixes
$HotFixList = Get-HotFix | Select-Object -Property HotFixID , InstalledOn | Sort-Object -Property InstalledOn
$LastHotFix = "$( ( $HotFixList | Where-Object { $PSItem.InstalledOn -eq $HotFixList[-1].InstalledOn } ).HotFixID -Join ',' ) $( $HotFixList[-1].InstalledOn.tostring( 'dd-MM-yyyy' ) )"
Set-Item -Path 'ENV:\LastHotFix' -Value $LastHotFix
# Get WSUS Server
Try {
    # EnableStart WindowsUpdateService
    Set-Service -Name 'wuauserv' -StartupType 'Manual' ; Start-Service -Name 'wuauserv'
    $WsusEnabled = ( ( new-object -com 'Microsoft.Update.ServiceManager' ).Services | Where-Object { $PSITEM.ServiceID -eq '3da21691-e39d-4da6-8a4b-b43877bcb1b7' } ).IsDefaultAUService
    # StopDisable WindowsUpdateService
    Stop-Service -Name 'wuauserv' ; Set-Service -Name 'wuauserv' -StartupType 'Disabled'
    If ( $WsusEnabled ) { Set-Item -Path 'ENV:\WSUS' -Value ( Get-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate' ).WUServer }
    }
    Catch { Set-Item -Path 'ENV:\WSUS' -Value '0.0.0.0' }
# Launch BgInfo
.\bginfo.exe Server.bgi /timer:0 /nolicprompt
# The End
