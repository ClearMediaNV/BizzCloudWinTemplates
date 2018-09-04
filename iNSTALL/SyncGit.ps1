# Get GitHub Repository Archive
[STRING]$UrlDownload =  'https://github.com/ClearMediaNV/BizzCloudWinTemplates/archive/master.zip'
[STRING]$Output = "$ENV:TEMP\$($UrlDownload.Split('/')[$_.count-1])"
# Change SecurityProtocol for downloading from GitHub
$SavedSecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol
[System.Net.ServicePointManager]::SecurityProtocol = 'Tls,Tls11,Tls12'
# Download Archive
(New-Object System.Net.WebClient).downloadFile($UrlDownload,$Output)
[System.Net.ServicePointManager]::SecurityProtocol = $SavedSecurityProtocol
# Unzip Archive to Temp
Expand-Archive -Path $Output -DestinationPath "$ENV:TEMP\Template" -Force
# Cleanup and Copy iNSTALL Folder
<<<<<<< HEAD
get-childitem -path "c:\install" -Recurse  | Remove-Item -Recurse -Force
Copy-Item -Path "$ENV:TEMP\Template\BizzCloudWinTemplates-master\iNSTALL\*" -Destination 'c:\iNSTALL' -Recurse -Force
# Cleanup Temp Folder
remove-Item -Path "$Output" -Force
remove-item -path "$ENV:TEMP\Template" -Recurse -Force
=======
Remove-Item -Path "c:\install\*" -Recurse -Force
Copy-Item -Path "$ENV:TEMP\Template\BizzCloudWinTemplates-master\iNSTALL\*" -Destination 'c:\iNSTALL' -Recurse -Force
# Cleanup Temp Folder
Remove-Item -Path "$Output" -Force
Remove-Item -Path "$ENV:TEMP\Template" -Recurse -Force
>>>>>>> 504e490bda7a224ed714c738b4554159e7da255a
# The End
