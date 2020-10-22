Install-Windowsfeature FS-Data-Deduplication

Enable-DedupVolume -Volume 'D:'

Set-DedupVolume -Volume 'D:' 

New-DedupSchedule -Name 'D-Drive' -Type Optimization -Days @(1..6) -Start '22:00'

Set-DedupSchedule -Name 'BackgroundOptimization' -Enabled $false

Get-DedupSchedule
