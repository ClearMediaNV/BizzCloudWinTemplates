$TeamsPath = "$Env:LOCALAPPDATA\Microsoft\Teams"
$TeamsUpdateExePath = "$($TeamsPath)\Update.exe"
try {
    if ( Test-Path -Path $TeamsUpdateExePath ) {
        # Uninstall app
        Write-Output ' Uninstalling Teams process'
        $proc = Start-Process -FilePath $TeamsUpdateExePath -ArgumentList '-uninstall -s' -PassThru
        $proc.WaitForExit()
        }
    if ( Test-Path -Path $TeamsPath ) {
        Write-Output ' Deleting Teams directory'
        Remove-Item -Path $TeamsPath -Recurse -Force 
        }
    }
catch   {
        Write-Error -ErrorRecord $_
        exit /b 1
        }
