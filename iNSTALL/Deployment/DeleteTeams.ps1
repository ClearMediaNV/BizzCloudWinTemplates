# Please Run in User Context
$TeamsPath = "$Env:LOCALAPPDATA\Microsoft\Teams"
$TeamsUpdateExePath = "$($TeamsPath)\Update.exe"
try {
    if ( Test-Path -Path $TeamsUpdateExePath ) {
        # Uninstall App
        Write-Output ' Uninstalling Teams process'
        $Process = Start-Process -FilePath $TeamsUpdateExePath -ArgumentList '-uninstall -s' -PassThru
        $Process.WaitForExit()
        }
    if ( Test-Path -Path $TeamsPath ) {
        Write-Output ' Deleting Teams directory'
        Remove-Item -Path $TeamsPath -Recurse -Force 
        }
    }
catch   {
        Write-Error -ErrorRecord $_
        Exit /b 1
        }
