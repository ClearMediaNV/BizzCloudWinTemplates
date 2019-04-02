# Change WindowsUpdate Service to Manual an Start Service
Set-Service -Name 'wuauserv' -StartupType Manual
Start-Service -Name 'wuauserv'

# Create Objects Microsoft.Update.* to Search-Download-Install Windows Updates
# $WindowsUpdateServiceManager = New-Object -ComObject 'Microsoft.Update.ServiceManager'
# Default Service = 'Windows Server Update Service' (Cfr GPO)
$WindowsUpdateSearch = New-Object -ComObject 'Microsoft.Update.Searcher'
$WindowsUpdateDownloader = New-Object -ComObject 'Microsoft.Update.Downloader'
$WindowsUpdateInstaller = New-Object -ComObject 'Microsoft.Update.Installer'
# Search-Download-Install Windows Updates
$WindowsUpdateList = $WindowsUpdateSearch.Search($Null).Updates
If ( $WindowsUpdateList.Count -eq 0 )
	{
	Write-Output 'No Updates Available.'
	}
	Else
	{
	$WindowsUpdateDownloader.Updates = $WindowsUpdateList
	$WindowsUpdateDownloader.Download()
	$WindowsUpdateInstaller.Updates = $WindowsUpdateList
	$WindowsUpdateInstaller.Install()
	}
# Report Windows Updates to CSV File 'c:\windows\logs\WindowsUpdate.csv'
[PSCustomObject[]]$Table = $Null
Foreach ( $Update in $WindowsUpdateList ) 
    {
    $Table += [PSCustomObject] @{
                        'Title' = $Update.Title
                        'CategoriesName' = [STRING]$Update.Categories._NewEnum.Name
                        'BundledUpdatesTitle' = [STRING]$Update.BundledUpdates._NewEnum.Title
                        'BundledUpdatesLastDeploymentChangeTime' = [STRING]$Update.BundledUpdates._NewEnum.LastDeploymentChangeTime
                        'BundledUpdatesMinDownloadSize' = [STRING]$Update.BundledUpdates._NewEnum.MinDownloadSize
                        'KBArticleIDs' = [STRING]$Update.KBArticleIDs
                        'IsDownloaded' = [STRING]$Update.IsDownloaded
                        'IsInstalled' = [STRING]$Update.IsInstalled
                        'IsUninstallable' = [STRING]$Update.IsUninstallable
                        'RebootRequired' = [STRING]$Update.RebootRequired }
    }

$Table | Select-Object -Property Title,CategoriesName,BundledUpdatesTitle,BundledUpdatesLastDeploymentChangeTime,BundledUpdatesMinDownloadSize,KBArticleIDs,IsDownloaded,IsInstalled,IsUninstallable,RebootRequired | Export-Csv -Path 'c:\windows\logs\WindowsUpdate.csv' -Append -Force -NoTypeInformation
# Change WindowsUpdate Service to Disabled
Set-Service -Name 'wuauserv' -StartupType Disabled

