# Get GitHub Repository Archive
# Change SecurityProtocol for downloading from GitHub
$SavedSecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol
[System.Net.ServicePointManager]::SecurityProtocol = 'Tls,Tls11,Tls12'
Try {
    [STRING]$UrlDownload =  'https://github.com/ClearMediaNV/BizzCloudWinTemplates/archive/master.zip'
    [STRING]$Output = "$ENV:TEMP\Template.zip"
    # Download Archive
    (New-Object System.Net.WebClient).downloadFile($UrlDownload,$Output)
    # Unzip Archive to Temp
    [VOID][System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem")
    [System.IO.Compression.ZipFile]::ExtractToDirectory($Output, "$ENV:TEMP\Template") 
    # Cleanup and Copy iNSTALL Folder
    Remove-Item -Path 'c:\install\*'  -Recurse -Force
    Copy-Item -Path "$ENV:TEMP\Template\BizzCloudWinTemplates-master\iNSTALL\*" -Destination 'c:\iNSTALL' -Recurse -Force
    # Cleanup Temp Folder
    Remove-Item -Path "$Output" -Force
    Remove-Item -Path "$ENV:TEMP\Template" -Recurse -Force
    }
Catch   {
        Write-Output 'No Internet Connection. Please Check DNS & Gateway Config'
        Start-Sleep -Seconds 5
        }
# Restore Saved SecurityProtocol
[System.Net.ServicePointManager]::SecurityProtocol = $SavedSecurityProtocol
# The End
