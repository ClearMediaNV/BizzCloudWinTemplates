Try {
    # Get GitHub Repository Archive
    # Change SecurityProtocol for downloading from GitHub
    [System.Net.ServicePointManager]::SecurityProtocol = 'Tls12'
    $Branch = 'master'
    $UrlDownload = "https://github.com/ClearMediaNV/BizzCloudWinTemplates/archive/$Branch.zip"
    $FileDownload = "$ENV:LOCALAPPDATA\$Branch.zip"
    $FolderDownload = "$ENV:LOCALAPPDATA\$Branch"
    # Download UrlDownload to FileDownload
    (New-Object System.Net.WebClient).downloadFile($UrlDownload,$FileDownload)
    # Unzip FileDownload to FolderDownload
    Expand-Archive -Path $FileDownload -DestinationPath $FolderDownload -Force
    # Cleanup and Copy iNSTALL Folder
    Remove-Item -Path 'c:\install\*' -Recurse -Force
    Copy-Item -Path "$FolderDownload\BizzCloudWinTemplates-$Branch\iNSTALL\*" -Destination 'c:\iNSTALL' -Recurse -Force
    # Cleanup FileDownload and FolderDownload
    Remove-Item -Path "$FileDownload" -Force
    Remove-Item -Path "$FolderDownload" -Recurse -Force
    }
   Catch { Write-Output 'GitHub Connection Error. Please Check DNS & Gateway Config. Please Check https://github.com/ClearMediaNV' }
# The End
