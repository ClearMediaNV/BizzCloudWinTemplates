# Kill Running Teams Instances
$TeamsExePath = "$Env:LOCALAPPDATA\Microsoft\Teams\Current\Teams.exe"
Get-Process -Name 'Teams' -ErrorAction SilentlyContinue | Where-Object { $PSItem.Path -eq $TeamsExePath }  | Stop-Process

# Disable GPU Acceleration
$TeamsConfigPath = "$env:APPDATA\Microsoft\Teams\desktop-config.json"
if ( Test-Path -Path $TeamsConfigPath ) {
    $TeamsConfig = Get-Content -Path $TeamsConfigPath | ConvertFrom-Json
    Try { $TeamsConfig.appPreferenceSettings.disableGpu = $True }
        Catch { $TeamsConfig.appPreferenceSettings | Add-Member -Name "disableGpu" -MemberType NoteProperty -Value $True }
    $TeamsConfig | ConvertTo-Json | Set-Content $TeamsConfigPath
    }
