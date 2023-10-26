# DownloadInstall FsLogix Latest Version
[System.Net.ServicePointManager]::SecurityProtocol = 'Tls12'
$UrlFsLogixDownloadLatest = 'https://aka.ms/fslogix-latest'
$Href = ( ( Invoke-WebRequest -Uri $UrlFsLogixDownloadLatest -UseBasicParsing ).links | Where-Object -FilterScript { $PsItem.class -match 'download' } ).href
$UrlDownload = $Href
$FileDownload = "$Env:LOCALAPPDATA\FSLogixAppsSetup.zip"
$FolderDownload = "$Env:LOCALAPPDATA\FSLogixAppsSetup"
(New-Object System.Net.WebClient).DownloadFile( $UrlDownload , $FileDownload )
Expand-Archive -Path $FileDownload -DestinationPath $FolderDownload -Force
Push-Location -Path ( Get-Childitem -Path $FolderDownload -File 'FSLogixAppsSetup.exe' -Recurse  | Where-Object -FilterScript { $PSItem.PSPath -like '*64*' } ).DirectoryName
Invoke-Expression -Command "CMD.EXE /C FSLogixAppsSetup.exe /install /quiet /norestart"

# Init FSLogix Disk
$FSLogixFolderRootPath = 'D:\Users'
If ( (get-disk -Number 1).AllocatedSize -eq 0 ) {
	$DriveLetter = $FSLogixFolderRootPath.Split(':')[0]
	Get-CimInstance -Namespace 'root\cimv2' -ClassName 'Win32_Volume' -Filter 'DriveType = 5' | Set-CimInstance -argument  @{DriveLetter='Z:'}
	New-Volume -DiskNumber 1 -FriendlyName 'FSLOGIX' -FileSystem NTFS  -DriveLetter $DriveLetter
	# Initialize-Disk -Number 1 -PartitionStyle MBR
    # New-Partition -DiskNumber 1 -DriveLetter $DriveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel 'FSLOGIX'
    # Remove All but System & Administrators from ACL on Root
	$Folder = "$($DriveLetter):\"
	$ACL = Get-Acl -Path  $Folder
	$ACL.Access | Where-Object { $PSItem.IdentityReference -inotin ( 'NT AUTHORITY\SYSTEM','BUILTIN\Administrators' ) } | ForEach-Object { $ACL.RemoveAccessRule($PSItem) }
	Set-Acl -Path $Folder -AclObject $ACL
    # Create User Folder
	# $FSLogixFolderRootPath = 'D:\Users'
    New-Item -Path $FSLogixFolderRootPath -type directory -Force
	$ACL = Get-Acl  -Path  $FSLogixFolderRootPath
	# Disable Inheritance
	$ACL.SetAccessRuleProtection($true,$false)
	# Add FSLogix Permissions on $FSLogixFolderRootPath
	$AccessRule = New-Object system.security.AccessControl.FileSystemAccessRule( 'NT AUTHORITY\SYSTEM' , 'FullControl' , 'ObjectInherit , ContainerInherit' , 'None' , 'Allow')
	$ACL.AddAccessRule($AccessRule)
	$AccessRule = New-Object system.security.AccessControl.FileSystemAccessRule( 'BUILTIN\Administrators' , 'FullControl' , 'ObjectInherit , ContainerInherit' , 'None' , 'Allow')
	$ACL.AddAccessRule($AccessRule)
	$AccessRule = New-Object system.security.AccessControl.FileSystemAccessRule( 'NT AUTHORITY\Creator Owner' , 'FullControl' , 'ObjectInherit , ContainerInherit' , 'None' , 'Allow')
	$ACL.AddAccessRule($AccessRule)
	$AccessRule = New-Object system.security.AccessControl.FileSystemAccessRule( 'BUILTIN\Users' , 'ReadData , AppendData , ExecuteFile , ReadAttributes' , 'None', 'None' , 'Allow')
	$ACL.AddAccessRule($AccessRule)
	Set-Acl -Path $FSLogixFolderRootPath -AclObject $ACL
	}

# Configure FSLogix aka Registry
$FSLogixFolderRootPath = 'D:\Users'
If ( -Not ( Test-Path -Path 'HKLM:\Software\FSLogix\Profiles' ) ) { New-Item -Path  'HKLM:\Software\FSLogix\Profiles' }
New-ItemProperty -Path 'HKLM:\Software\FSLogix\Profiles' -Name 'Enabled' -PropertyType 'Dword' -Value 1 -Force
New-ItemProperty -Path 'HKLM:\Software\FSLogix\Profiles' -Name 'ProfileType' -PropertyType 'Dword' -Value 0 -Force
New-ItemProperty -Path 'HKLM:\Software\FSLogix\Profiles' -Name 'SizeInMBs' -PropertyType 'Dword' -Value 51200 -Force
New-ItemProperty -Path 'HKLM:\Software\FSLogix\Profiles' -Name 'VHDLocations' -PropertyType 'String' -Value $FSLogixFolderRootPath -Force
New-ItemProperty -Path 'HKLM:\Software\FSLogix\Profiles' -Name 'VolumeType' -PropertyType 'String' -Value 'VHDX' -Force

# Exclude Administrator in FSLogix Groups
Add-LocalGroupMember -Name 'FSLogix ODFC Exclude List' -Member 'Administrator'
Add-LocalGroupMember -Name 'FSLogix Profile Exclude List' -Member 'Administrator'

# Restart
Restart-Computer
