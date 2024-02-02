Try {
    # Get GitHub Repository Archive
    # Change SecurityProtocol for downloading from GitHub
    [System.Net.ServicePointManager]::SecurityProtocol = 'Tls12'
    $Branch = 'master'
    $UrlDownload = "https://github.com/ClearMediaNV/BizzCloudWinTemplates/archive/$Branch.zip"
    $FileDownload = "$ENV:LOCALAPPDATA\$Branch.zip"
    $FolderDownload = "$ENV:LOCALAPPDATA\$Branch"
    # Download UrlDownload to FileDownload
    Invoke-WebRequest -Uri $UrlDownload -OutFile $FileDownload -UseBasicParsing
    # Unzip FileDownload to FolderDownload
    Expand-Archive -Path $FileDownload -DestinationPath $FolderDownload -Force
    # Cleanup and Copy Install Folder
    Remove-Item -Path 'C:\Install\*' -Recurse -Force
    Copy-Item -Path "$FolderDownload\BizzCloudWinTemplates-$Branch\Install\*" -Destination 'C:\Install' -Recurse -Force
    # Cleanup FileDownload and FolderDownload
    Remove-Item -Path "$FileDownload" -Force
    Remove-Item -Path "$FolderDownload" -Recurse -Force
    }
   Catch { Write-Output 'GitHub Connection Error. Please Check DNS & Gateway Config. Please Check https://github.com/ClearMediaNV' }
# The End
