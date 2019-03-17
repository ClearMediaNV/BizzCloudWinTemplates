# Get GitHub Repository Archive
# Change SecurityProtocol for downloading from GitHub
$SavedSecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol
[System.Net.ServicePointManager]::SecurityProtocol = 'Tls,Tls11,Tls12'
Try {
    [STRING]$UrlDownload =  'https://github.com/ClearMediaNV/BizzCloudWinTemplates/archive/master.zip'
    [STRING]$Output = "$ENV:TEMP\$($UrlDownload.Split('/')[$_.count-1])"
    # Download Archive
    (New-Object System.Net.WebClient).downloadFile($UrlDownload,$Output)
    [System.Net.ServicePointManager]::SecurityProtocol = $SavedSecurityProtocol
    # Unzip Archive to Temp
    Expand-Archive -Path $Output -DestinationPath "$ENV:TEMP\Template" -Force
    # Cleanup and Copy iNSTALL Folder
    Remove-Item -Path 'c:\install\*'  -Recurse -Force
    Copy-Item -Path "$ENV:TEMP\Template\BizzCloudWinTemplates-master\iNSTALL\*" -Destination 'c:\iNSTALL' -Recurse -Force
    # Cleanup Temp Folder
    Remove-Item -Path "$Output" -Force
    Remove-Item -Path "$ENV:TEMP\Template" -Recurse -Force
    }
Catch {
    [System.Net.ServicePointManager]::SecurityProtocol = $SavedSecurityProtocol
    Write-Output 'No Internet Connection. Please Check DNS Config'
    Start-Sleep -Seconds 5
    Exit
    }
# The End
