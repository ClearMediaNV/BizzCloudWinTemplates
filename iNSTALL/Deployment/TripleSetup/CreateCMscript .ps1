$ScriptPath = 'C:\iNSTALL\Deployment\TripleSetup\CMScripts'
$DnsServerForwarders = "'195.238.2.21','195.238.2.22','8.8.8.8'"
$DomainName = 'ClearMedia.cloud'
$DomainName = Read-Host -Prompt "Enter Active Directory Domain Name (Default $DomainName)" | ForEach-Object {if ($_ -ne '') {$_} else {$DomainName}}
$DomainNetbiosName = 'ClearMedia'
$DomainNetbiosName = Read-Host -Prompt "Enter Active Directory NetBios Name (Default $DomainNetbiosName)" | ForEach-Object {if ($_ -ne '') {$_} else {$DomainNetbiosName}}
$ManagedOU = 'SME'
$ManagedOU = Read-Host -Prompt "Enter Active Directory Managed OU (Default $ManagedOU)" | ForEach-Object {if ($_ -ne '') {$_} else {$ManagedOU}}
$SafeModeAdministratorPasswordPlainText = ((([char[]](65..90) | sort {get-random})[0..2] + ([char[]](33,35,36,37,42,43,45) | sort {get-random})[0] + ([char[]](97..122) | sort {get-random})[0..4] + ([char[]](48..57) | sort {get-random})[0]) | get-random -Count 10) -join ''
$SafeModeAdministratorPasswordPlainText = Read-Host -Prompt "Enter Active Directory Recovery Password (Default $SafeModeAdministratorPasswordPlainText) Warning: Use Complex Passwords because of default Windows Security Policy)" | ForEach-Object {if ($_ -ne '') {$_} else {$SafeModeAdministratorPasswordPlainText}}
$SafeModeAdministratorPassword = ConvertTo-SecureString $SafeModeAdministratorPasswordPlainText -AsPlainText -Force
$ClearmediaAdminPasswordPlainText = ((([char[]](65..90) | sort {get-random})[0..2] + ([char[]](33,35,36,37,42,43,45) | sort {get-random})[0] + ([char[]](97..122) | sort {get-random})[0..4] + ([char[]](48..57) | sort {get-random})[0]) | get-random -Count 10) -join ''
$ClearmediaAdminPasswordPlainText = Read-Host -Prompt "Enter ClearmediaAdminPassword (Default $ClearmediaAdminPasswordPlainText) Warning: Use Complex Passwords because of default Windows Security Policy)" | ForEach-Object {if ($_ -ne '') {$_} else {$ClearmediaAdminPasswordPlainText}}
$ClearmediaAdminPassword = ConvertTo-SecureString $ClearmediaAdminPasswordPlainText -AsPlainText -Force

$Info = [ORDERED]@{
    DomainName = "$DomainName"
    DomainNetbiosName = "$DomainNetbiosName"
    ManagedOU = "$ManagedOU"
    SafeModeAdministratorPassword = $SafeModeAdministratorPasswordPlainText
    ClearmediaAdminPassword = $ClearmediaAdminPasswordPlainText
    }
$Info | Out-GridView -Title "Overview of $DomainName - Please copy this Info for later Use" 

#Create ScriptFolder
If(!(test-path $ScriptPath)) {New-Item -type Directory -Force -Path $ScriptPath}

##### Assemble AD, DNS, TS Licensing #####
New-Item "$ScriptPath\1_Install_AD_components.ps1" -type File -Force
#Create HashTable for Provisioning Roles & Features for each Family cfr Get-WindowsFeature
$Roles = [ordered]@{
	'Active Directory Domain Services' = 'AD-Domain-Services'
	'Group Policy Management' = 'GPMC'
	'DNS Server' = 'DNS'
	'Remote Desktop Services' = 'RDS-Licensing'
	'Remote Server Administration Tools' = ('RSAT-AD-Tools','RSAT-DNS-Server','RSAT-RDS-Licensing-Diagnosis-UI','RDS-Licensing-UI')
	}
#Get all Roles & Features to install; use replace to separate roles & features in same Family
$Roles.Values -replace ' ',',' | ForEach-Object {Add-Content -Path "$ScriptPath\1_Install_AD_components.ps1" -Value "Install-WindowsFeature -Name $_"}
#Add DNS Forwarders
Add-Content -Path "$ScriptPath\1_Install_AD_components.ps1" -Value "Add-DnsServerForwarder -IPAddress $DnsServerForwarders "
#Safe encrypted Password for later use
$SafeModeAdministratorPassword | ConvertFrom-SecureString | Export-Clixml -Path "$ScriptPath\p1.xml"
#Create New ADDSForest
Add-Content -Path "$ScriptPath\1_Install_AD_components.ps1" -Value "Install-ADDSForest -DomainName '$DomainName' -SafeModeAdministratorPassword (Import-Clixml -Path $ScriptPath\p1.xml |  ConvertTo-SecureString) -DomainNetbiosName '$DomainNetbiosName' -Force"

##### Assemble AD Objects #####
New-Item "$ScriptPath\2_Build_AD.ps1" -type File -Force
$ADRootDSE = $(($DomainName.Replace('.',',DC=')).insert(0,'DC='))
#Create HashTable for OU Provisioning
$OUs = [ordered]@{
	"$ManagedOU" =  "$ADRootDSE"
    'Users'= "OU=$ManagedOU,$ADRootDSE"
    'Light Users' = "OU=Users,OU=$ManagedOU,$ADRootDSE"
    'Admin Users' = "OU=$ManagedOU,$ADRootDSE"
    'Groups' = "OU=$ManagedOU,$ADRootDSE"
	'RAS' = "OU=Groups,OU=$ManagedOU,$ADRootDSE"
	'NetAccess' = "OU=Groups,OU=$ManagedOU,$ADRootDSE"
    'Servers' = "OU=$ManagedOU,$ADRootDSE"
    'RDS' = "OU=Servers,OU=$ManagedOU,$ADRootDSE"
    'DATA' = "OU=Servers,OU=$ManagedOU,$ADRootDSE"
    'WEB' = "OU=Servers,OU=$ManagedOU,$ADRootDSE"
    }
ForEach ($OU in $OUs.keys) {Add-Content -Path "$ScriptPath\2_Build_AD.ps1" -Value "NEW-ADOrganizationalUnit -Name '$OU' -Path '$($OUs.$OU)'"}

#Create HashTable for Group Provisioning
$Groups = [ordered]@{
    "$DomainNetbiosName-Admins"= "OU=Groups,OU=$ManagedOU,$ADRootDSE"
    "$DomainNetbiosName-Users" = "OU=Groups,OU=$ManagedOU,$ADRootDSE"
    "$DomainNetbiosName-THINPRINT-USERS" = "OU=Groups,OU=$ManagedOU,$ADRootDSE"
    "$DomainNetbiosName-RAS-USERS" = "OU=RAS,OU=Groups,OU=$ManagedOU,$ADRootDSE"
	"$DomainNetbiosName-RAS-Office-USERS" = "OU=RAS,OU=Groups,OU=$ManagedOU,$ADRootDSE"
    "$DomainNetbiosName-RAS-Desktop-USERS" = "OU=RAS,OU=Groups,OU=$ManagedOU,$ADRootDSE"
    "$DomainNetbiosName-RAS-Explorer-USERS" = "OU=RAS,OU=Groups,OU=$ManagedOU,$ADRootDSE"
    "$DomainNetbiosName-RAS-InternetExplorer-USERS" = "OU=RAS,OU=Groups,OU=$ManagedOU,$ADRootDSE"
    "$DomainNetbiosName-RAS-AdobeReader-USERS" = "OU=RAS,OU=Groups,OU=$ManagedOU,$ADRootDSE"
	"$DomainNetbiosName-FTP-USERS" = "OU=NetAccess,OU=Groups,OU=$ManagedOU,$ADRootDSE"
	"$DomainNetbiosName-RDP-USERS" = "OU=NetAccess,OU=Groups,OU=$ManagedOU,$ADRootDSE"
	"$DomainNetbiosName-SSLVPN-USERS" = "OU=NetAccess,OU=Groups,OU=$ManagedOU,$ADRootDSE"
    }
ForEach ($Group in $Groups.keys) {Add-Content -Path "$ScriptPath\2_Build_AD.ps1" -Value "NEW-ADGroup -Name '$Group' -GroupScope 'Global' -Path '$($Groups.$Group)'"}

#Safe encrypted Password for later use
$ClearmediaAdminPassword | ConvertFrom-SecureString | Export-Clixml -Path "$ScriptPath\p2.xml"
#Create HashTable for User Provisioning
$User= @{
		'Name' = 'ClearmediaAdmin'
		'SamAccountName' = 'ClearmediaAdmin'
		'DisplayName' = 'ClearmediaAdmin'
		'Description' = 'ClearmediaAdmin'
		'EmailAddress' = 'support@clearmedia.be'
		'Path' = "OU=Admin Users,OU=$ManagedOU,$ADRootDSE"
		'PasswordNeverExpires' = '$TRUE'
		'AccountPassword' =  "(Import-Clixml -Path $ScriptPath\p2.xml |  ConvertTo-SecureString)"
		}
Add-Content -Path "$ScriptPath\2_Build_AD.ps1" -Value "New-ADUser -Name '$($User.Name)' -SamAccountName '$($User.SamAccountName)' -DisplayName '$($User.DisplayName)' -Description '$($User.Description)' -EmailAddress '$($User.EmailAddress)' -Path '$($User.Path)' -PasswordNeverExpires $($User.PasswordNeverExpires) -AccountPassword $($User.AccountPassword)"
Add-Content -Path "$ScriptPath\2_Build_AD.ps1" -Value "Add-ADGroupMember -Identity 'CN=Domain Admins,CN=Users,$ADRootDSE' -Members 'CN=$($User.Name),$($User.Path)'"
Add-Content -Path "$ScriptPath\2_Build_AD.ps1" -Value "Add-ADGroupMember -Identity 'CN=Enterprise Admins,CN=Users,$ADRootDSE' -Members 'CN=$($User.Name),$($User.Path)'"

##### Assemble RDS #####
New-Item -Path "$ScriptPath\3_Install_RDS_components.ps1" -type File -Force
#Create HashTable for Startup Mode for RDP related Services
$Services = @{
	'Audiosrv' =  'Auto'
	'SCardSvr' = 'Auto'
	'WSearch'  = 'Auto'
	}
ForEach ($Service in $Services.keys) {Add-Content -Path "$ScriptPath\3_Install_RDS_components.ps1" -Value "Set-Service -Name '$Service' -StartupType '$($Services.$Service)'"}
#Create HashTable for Provisioning Roles & Features for each Family cfr Get-WindowsFeature
$Roles = [ordered]@{
	'Windows TIFF IFilter' =  'Windows-TIFF-IFilter'
	'Remote Desktop Services' = 'RDS-RD-Server'
    	'Group Policy Management' = 'GPMC'
	'Remote Server Administration Tools' = ('RSAT-AD-Tools','RSAT-DNS-Server','RSAT-RDS-Licensing-Diagnosis-UI','RDS-Licensing-UI')
	}
#Get all Roles & Features to install; use replace to separate roles & features in same Family
$Roles.Values -replace ' ',',' | ForEach-Object {Add-Content -Path "$ScriptPath\3_Install_RDS_components.ps1" -Value "Install-WindowsFeature -Name $_"}
Add-Content -Path "$ScriptPath\3_Install_RDS_components.ps1" -Value 'Restart-Computer'

#Wait 60 Sec in order to copy Overview of DomainName
Start-Sleep -Seconds '60'
