Push-Location %0\..\
# Set Registry after SysPrep Reset - Windows Annoyances
Get-CimInstance -Namespace 'root\cimv2' -ClassName 'Win32_Volume' -Filter 'DriveType = 5' | Set-CimInstance -argument  @{DriveLetter='Z:'}
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Disk' -Name 'TimeOutValue' -Value 600
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\ServerManager' -Name 'DoNotOpenServerManagerAtLogon' -Value 1
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Internet Explorer\Main\' -Name 'start page' -Value 'about:blank'
# Get Public IP @
Set-Item -Path 'ENV:\IpAddressPublic' -Value '0.0.0.0'
Set-Item -Path 'ENV:\IpAddressPublic' -Value (Invoke-WebRequest -Uri 'https://api.ipify.org' -UseBasicParsing).content
# Get NLA state
Set-Item -Path 'ENV:\NetworkCategory' -value (Get-NetConnectionProfile).NetworkCategory
Set-Item -Path 'ENV:\IPv4Connectivity' -Value (Get-NetConnectionProfile).IPv4Connectivity
# Launch BgInfo
Invoke-Expression -Command ".\bginfo.exe windows.bgi /timer:0 /nolicprompt"
