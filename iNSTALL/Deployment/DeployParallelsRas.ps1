# https://www.parallels.com/eu/products/ras/download/links/
# https://docs.parallels.com/landing/ras-admin-guide
# Get latest Parallels RAS Version @ https://kb.parallels.com/en/130242 AKA v20
# Get latest Parallels RAS Version @ https://kb.parallels.com/en/131037 AKA v21
# Disable Application Layer Gateway service
# Disable RAS Optimization

# Deploy Parallels RAS v21
$RasCoreVersion = '21.2.1-27306'
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

# Configure Parallels RAS v21
$LocalAdminUserName = 'administrator'
$LocalAdminPassword = ''
$RasLicenseEmail = 'support@clearmedia.be'
$RasLicensePassword = ''
$RasKey = ''
If (-Not (Test-Path -Path 'C:\Program Files (x86)\Parallels\ApplicationServer\Modules\RASAdmin\RASAdmin.psd1')) { Start-Sleep -Seconds 5 }
Push-Location -Path 'C:\Program Files (x86)\Parallels\ApplicationServer\Modules\RASAdmin'
Import-Module  -FullyQualifiedName '.\RASAdmin.psd1'
Pop-Location
# Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Parallels\Setup\ApplicationServer -Name ProductDir -Value "C:\Program Files (x86)\Parallels\ApplicationServer\"
New-RASSession -Username $LocalAdminUserName -Password $(ConvertTo-SecureString $LocalAdminPassword -AsPlainText -Force) -Server 'localhost'
Invoke-RASLicenseActivate -Email $RasLicenseEmail -Password $(ConvertTo-SecureString $RasLicensePassword -AsPlainText -Force) -Key $RasKey
# New-RASGW -Server "$env:COMPUTERNAME"
New-RASRDSHost -Server "$env:COMPUTERNAME" -NoRestart -NoTerminalServices 
New-RASPubRDSDesktop -Name "Desktop"
Invoke-RASApply
