# Get latest Parallels RAS Version @ https://kb.parallels.com/en/130242
$RasCoreVersion = '21.0.1-26296'
$Version = $RasCoreVersion.Split( '-' )[0].Split( '.' )[0]
$VersionMajor = $RasCoreVersion.Split( '-' )[0].Split( '.' )[1]
$VersionMinor = If ( $RasCoreVersion.Split( '-' )[0].Split( '.' )[2] ) { $RasCoreVersion.Split( '-' )[0].Split( '.' )[2] } Else { '0'}
$VersionRevision = $RasCoreVersion.Split( '-' )[1].Substring( 0 , 5 )
$UrlDownLoad = "https://download.parallels.com/ras/v$Version/$Version.$VersionMajor.$VersionMinor.$VersionRevision/RASInstaller-$Version.$VersionMajor.$VersionRevision.msi"
$FileDownload = "$ENV:LOCALAPPDATA\$($UrlDownload.Split('/')[-1])"
# Download Parallels RAS
$Null = (New-Object System.Net.WebClient).DownloadFile( $UrlDownload , $FileDownload )
# Install Parallels RAS
Start-Process -FilePath 'msiexec.exe' -ArgumentList ( "-i $FileDownload /qn /norestart " ) -Wait
