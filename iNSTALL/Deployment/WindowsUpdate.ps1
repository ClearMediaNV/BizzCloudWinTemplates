# Copy-Item -Path '.\WindowsUpdate.ps1' -Destination "$Env:Windir\WindowsUpdate.ps1" -Force
# schtasks.exe /CREATE /RU SYSTEM /SC Weekly /MO 4 /D MON /ST 04:00 /TN CMscripts\WindowsUpdate /TR "Powershell.exe -File '$Env:Windir\WindowsUpdate.ps1'"
# WindowsUpdate Service Disabled By Default
Set-Service -Name 'wuauserv' -StartupType 'Manual'
Start-Service -Name 'wuauserv'

# Create Objects Microsoft.Update.* to Search-Download-Install Windows Updates
# $WindowsUpdateServiceManager = New-Object -ComObject 'Microsoft.Update.ServiceManager'
# Default Service = 'Windows Server Update Service' (Cfr GPO)
$WindowsUpdateSearch = New-Object -ComObject 'Microsoft.Update.Searcher'
$WindowsUpdateDownload = New-Object -ComObject 'Microsoft.Update.Downloader'
$WindowsUpdateInstall = New-Object -ComObject 'Microsoft.Update.Installer'
# Search-Download-Install Windows Updates
Try	{ $WindowsUpdateList = $WindowsUpdateSearch.Search($Null).Updates }
	Catch 
		{
        	Write-Output 'WSUS not Reachable. No Internet Connection. Please Check DNS & Gateway Config'
        	Start-Sleep -Seconds 5
		Exit
		}
If	( $WindowsUpdateList.Count -eq 0 )
		{
		Write-Output 'No Updates Available.'
		Start-Sleep -Seconds 5
    		Exit
		}
	Else
		{
		$WindowsUpdateDownload.Updates = $WindowsUpdateList
		$WindowsUpdateDownload.Download()
		$WindowsUpdateInstall.Updates = $WindowsUpdateList
		$WindowsUpdateInstall.Install()
		}
# Report Windows Updates to CSV File 'c:\windows\logs\WindowsUpdate.csv'
[PSCustomObject[]]$Table = $Null
Foreach	( $Update in $WindowsUpdateList ) 
		{ $Table += [PSCustomObject] @{
    			'DateTime' = (Get-Date).tostring('dd-MM-yyyy HH:mm:ss')
                        'Title' = [STRING]$Update.Title
                        'CategoriesName' = [STRING]$Update.Categories._NewEnum.Name
                        'BundledUpdatesTitle' = [STRING]$Update.BundledUpdates._NewEnum.Title
                        'BundledUpdatesLastDeploymentChangeTime' = [STRING]$Update.BundledUpdates._NewEnum.LastDeploymentChangeTime
                        'BundledUpdatesMinDownloadSize' = [STRING]$Update.BundledUpdates._NewEnum.MinDownloadSize
                        'KBArticleIDs' = [STRING]$Update.KBArticleIDs
			}
		}

$Table | Select-Object -Property DateTime,Title,CategoriesName,BundledUpdatesTitle,BundledUpdatesLastDeploymentChangeTime,BundledUpdatesMinDownloadSize,KBArticleIDs | Export-Csv -Path 'c:\windows\logs\WindowsUpdate.csv' -Append -Force -NoTypeInformation
# Change WindowsUpdate Service to Disabled
Set-Service -Name 'wuauserv' -StartupType 'Disabled'
# Restart Computer for applying Windows Updates
Restart-Computer -Force
