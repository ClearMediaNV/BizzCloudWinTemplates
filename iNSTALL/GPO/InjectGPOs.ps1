Push-Location -Path 'c:\install\gpo'
$GpoNameList = ('RDS Server Policy','Standard User Policy','Standard O365 User Policy','O365 Channel','Standard Hardware Acceleration Policy')
$GpoNameList | Where-Object {
    $GpoName = $_
    new-gpo -Name "$GpoName" -ErrorAction Ignore
    $c = Import-Csv -Path "$GpoName.csv"
    $c | ForEach-Object { 
                    if ( $_.Type -eq 'Dword' ) { [INT]$Value = $_.Value } else { [STRING]$Value = $_.Value }
                    Set-GPRegistryValue -Name "$GpoName" -Key $_.Key -Type $_.Type -ValueName $_.ValueName -Value $Value }

    }



