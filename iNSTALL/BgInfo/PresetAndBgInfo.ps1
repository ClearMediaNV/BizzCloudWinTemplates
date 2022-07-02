# Push Current Directory
Push-Location %0\..\
# Set Full Screen WXGA 1280 x 800
Set-DisplayResolution -Width 1280 -Height 800 -Force
# Copy Shortcut to current Desktop
Copy-Item -Path 'PresetBginfo.lnk' -Destination "$Env:USERPROFILE\Desktop" -Force
# Set Registry after SysPrep Reset - Windows Annoyances
If ( 'Z' -notin ( Get-PSDrive ).Name ) { Get-CimInstance -Namespace 'root\cimv2' -ClassName 'Win32_Volume' -Filter 'DriveType = 5' | Set-CimInstance -Argument  @{ DriveLetter = 'Z:' } }
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Disk' -Name 'TimeOutValue' -Value 600
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\ServerManager' -Name 'DoNotOpenServerManagerAtLogon' -Value 1
# Get Public IP @
[System.Net.ServicePointManager]::SecurityProtocol = 'Tls12'
Try { Set-Item -Path 'ENV:\IpAddressPublic' -Value ( Invoke-WebRequest -Uri 'https://api.ipify.org' -UseBasicParsing ).content }
    Catch { Set-Item -Path 'ENV:\IpAddressPublic' -Value '0.0.0.0' }
# Restart NLA Service for DomainController in order to gain extra Reboot in initial Deployment of ADS
Get-CimInstance -NameSpace 'root\cimv2' -ClassName 'win32_ComputerSystem' -Filter 'DomainRole = 4 or DomainRole = 5' | Restart-Service -Name 'NlaSvc' -Force
# Get NLA state
Set-Item -Path 'ENV:\NetworkCategory' -value ( Get-NetConnectionProfile ).NetworkCategory
Set-Item -Path 'ENV:\IPv4Connectivity' -Value ( Get-NetConnectionProfile ).IPv4Connectivity
# Get Last Installed HotFix
$HotFixList = Get-HotFix | Select-Object -Property HotFixID , InstalledOn | Sort-Object -Property InstalledOn
$LastHotFix = "$( ( $HotFixList | Where-Object { $PSItem.InstalledOn -eq $HotFixList[-1].InstalledOn } ).HotFixID -Join ',' ) $( $HotFixList[-1].InstalledOn.tostring( 'dd-MM-yyyy' ) )"
Set-Item -Path 'ENV:\LastHotFix' -value $LastHotFix
# Get WSUS Server
Try { Set-Item -Path 'ENV:\WSUS' -Value ( Get-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate' ).WUServer }
    Catch { Set-Item -Path 'ENV:\WSUS' -Value '0.0.0.0' }
# Launch BgInfo
Invoke-Expression -Command '& .\bginfo.exe windows.bgi /timer:0 /nolicprompt'
