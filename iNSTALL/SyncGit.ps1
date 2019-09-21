# Get GitHub Repository Archive
# Change SecurityProtocol for downloading from GitHub
$SavedSecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol
[System.Net.ServicePointManager]::SecurityProtocol = 'Tls,Tls11,Tls12'
Try {
    [STRING]$Branch = 'master'
    [STRING]$UrlDownload = "https://github.com/ClearMediaNV/BizzCloudWinTemplates/archive/$Branch.zip"
    [STRING]$FileDownload = "$ENV:TEMP\$Branch.zip"
    [STRING]$FolderDownload = "$ENV:TEMP\$Branch"
    # Download Archive
    (New-Object System.Net.WebClient).downloadFile($UrlDownload,$FileDownload)
    # Unzip Archive to Temp
    [VOID][System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem")
    [System.IO.Compression.ZipFile]::ExtractToDirectory($FileDownload, "$FolderDownload") 
    # Cleanup and Copy iNSTALL Folder
    Remove-Item -Path 'c:\install\*'  -Recurse -Force
    Copy-Item -Path "$FolderDownload\BizzCloudWinTemplates-$Branch\iNSTALL\*" -Destination 'c:\iNSTALL' -Recurse -Force
    # Cleanup Temp Folder
    Remove-Item -Path "$FileDownload" -Force
    Remove-Item -Path "$FolderDownload" -Recurse -Force
    }
Catch   {
        Write-Output 'GitHub Connection Error. Please Check DNS & Gateway Config. Please Check https://github.com/ClearMediaNV'
        Start-Sleep -Seconds 5
        }
# Restore Saved SecurityProtocol
[System.Net.ServicePointManager]::SecurityProtocol = $SavedSecurityProtocol
# The End
