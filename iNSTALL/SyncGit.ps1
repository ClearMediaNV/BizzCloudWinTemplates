# Get GitHub Repository Archive
# Change SecurityProtocol for downloading from GitHub
[System.Net.ServicePointManager]::SecurityProtocol = 'Tls12'
Try {
    $Branch = 'master'
    $UrlDownload = "https://github.com/ClearMediaNV/BizzCloudWinTemplates/archive/$Branch.zip"
    $FileDownload = "$ENV:LOCALAPPDATA\$Branch.zip"
    $FolderDownload = "$ENV:LOCALAPPDATA\$Branch"
    # Download Archive
    ( New-Object System.Net.WebClient ).DownLoadFile( $UrlDownload , $FileDownload )
    # Unzip Archive to Folder Download
    [VOID][System.Reflection.Assembly]::LoadWithPartialName( "System.IO.Compression.ZipFile" )
    [System.IO.Compression.ZipFile]::ExtractToDirectory( $FileDownload , $FolderDownload ) 
    # Cleanup and Copy iNSTALL Folder
    Remove-Item -Path 'c:\install\*' -Recurse -Force
    Copy-Item -Path "$FolderDownload\BizzCloudWinTemplates-$Branch\iNSTALL\*" -Destination 'c:\iNSTALL' -Recurse -Force
    # Cleanup FileDownload and FolderDownload
    Remove-Item -Path "$FileDownload" -Force
    Remove-Item -Path "$FolderDownload" -Recurse -Force
    }
   Catch { Write-Output 'GitHub Connection Error. Please Check DNS & Gateway Config. Please Check https://github.com/ClearMediaNV' }
# The End
