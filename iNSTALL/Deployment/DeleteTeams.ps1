$TeamsPath = "$Env:LOCALAPPDATA\Microsoft\Teams"
$TeamsUpdateExePath = "$($TeamsPath)\Update.exe"
try
{
    if (Test-Path -Path $TeamsUpdateExePath) {
        Write-Host 'Uninstalling Teams process'
        # Uninstall app
        $proc = Start-Process -FilePath $TeamsUpdateExePath -ArgumentList "-uninstall -s" -PassThru
        $proc.WaitForExit()
    }
    if (Test-Path -Path $TeamsPath) {
        Write-Host 'Deleting Teams directory'
        Remove-Item -Path $TeamsPath -Recurse                   
    }
}
catch
{
    Write-Error -ErrorRecord $_
    exit /b 1
}
