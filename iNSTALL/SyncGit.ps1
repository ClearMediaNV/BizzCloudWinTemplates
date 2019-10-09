# Get GitHub Repository Archive
# Change SecurityProtocol for downloading from GitHub
$SavedSecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol
[System.Net.ServicePointManager]::SecurityProtocol = 'Tls,Tls11,Tls12'
Try {
    $Branch = 'master'
    $UrlDownload = "https://github.com/ClearMediaNV/BizzCloudWinTemplates/archive/$Branch.zip"
    $FileDownload = "$ENV:TEMP\$Branch.zip"
    $FolderDownload = "$ENV:TEMP\$Branch"
    # Download Archive
    (New-Object System.Net.WebClient).downloadFile($UrlDownload,$FileDownload)
    # Unzip Archive to Temp Folder
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
