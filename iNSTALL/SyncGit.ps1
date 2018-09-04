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
get-childitem -path "c:\install" -Recurse  | Remove-Item -Recurse -Force
Copy-Item -Path "$ENV:TEMP\Template\BizzCloudWinTemplates-master\iNSTALL\*" -Destination 'c:\iNSTALL' -Recurse -Force
# Cleanup Temp Folder
remove-Item -Path "$Output" -Force
remove-item -path "$ENV:TEMP\Template" -Recurse -Force
# The End
