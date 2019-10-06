# Kill IEXPLORE.exe
Get-Process -Name 'iexplore' -ErrorAction SilentlyContinue | ForEach-Object { $_.CloseMainWindow() } | Out-Null
start-sleep -Seconds 2
Get-Process -Name 'iexplore' -ErrorAction SilentlyContinue | ForEach-Object { $_.Kill() } | Out-Null
# Install Adobe Flash Player
# dism.exe /online /add-package /packagepath:"$((Get-Item -Path 'C:\Windows\servicing\Packages\Adobe-Flash-For-Windows-Package*.mum').FullName)"[STRING]$UrlDownload =  'http://vsphereclient.vmware.com/vsphereclient/1/2/3/0/3/8/6/6/VMware-ClientIntegrationPlugin-6.2.0.exe'
# Download and Install VMware-ClientIntegrationPlugin-6.2.0
[STRING]$UrlDownload =  'http://vsphereclient.vmware.com/vsphereclient/1/2/3/0/3/8/6/6/VMware-ClientIntegrationPlugin-6.2.0.exe'
[STRING]$FileDownload = "$ENV:TEMP\$($UrlDownload.Split('/')[-1])"
Invoke-WebRequest -Uri $UrlDownload -UseBasicParsing  -OutFile $FileDownload
Invoke-Expression -Command "$FileDownload /s /v/qn"
# Add my.bizzcloud.be to Internet Explorer Trusted Sites
If ( -Not (Test-Path -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap') ) { New-Item -Path  'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap' }
If ( -Not (Test-Path -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains') ) { New-Item -Path  'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains' }
If ( -Not (Test-Path -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\bizzcloud.be') ) { New-Item -Path  'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\bizzcloud.be' }
If ( -Not (Test-Path -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\bizzcloud.be\my') ) { New-Item -Path  'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\bizzcloud.be\my' }
New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\bizzcloud.be\my' -Name 'https' -Value 2 -PropertyType Dword -Force
# Add *.bizzcloud.be to PopUp Exclusions
If ( -Not (Test-Path -Path 'HKCU:\Software\Microsoft\Internet Explorer\New Windows') ) { New-Item -Path  'HKCU:\Software\Microsoft\Internet Explorer\New Windows' }
If ( -Not (Test-Path -Path 'HKCU:\Software\Microsoft\Internet Explorer\New Windows\Allow') ) { New-Item -Path  'HKCU:\Software\Microsoft\Internet Explorer\New Windows\Allow' }
[BYTE[]]$PathArray = (0,0)
New-ItemProperty -Path 'HKCU:\Software\Microsoft\Internet Explorer\New Windows\Allow' -Name '*.bizzcloud.be' -Value $PathArray -PropertyType Binary -Force
# Add bizzcloud.be to Internet Explorer Compatibility View List
If ( -Not (Test-Path -Path 'HKCU:\Software\Microsoft\Internet Explorer\BrowserEmulation\ClearableListData') ) { New-Item -Path  'HKCU:\Software\Microsoft\Internet Explorer\BrowserEmulation\ClearableListData' }
[BYTE[]]$Value = (65,31,0,0,83,8,173,186,1,0,0,0,54,0,0,0,1,0,0,0,1,0,0,0,12,0,0,0,99,156,160,30,220,119,213,1,1,0,0,0,12,0,98,0,105,0,122,0,122,0,99,0,108,0,111,0,117,0,100,0,46,0,98,0,101,0)
New-ItemProperty -Path 'HKCU:\Software\Microsoft\Internet Explorer\BrowserEmulation\ClearableListData' -Name 'UserFilter' -Value $Value -PropertyType Binary -Force
