Push-Location -Path 'c:\install\gpo'

# Copy ADM(X) Files to Local ADM(X) Folder
Copy-Item -Path '.\Templates\admx\*' -Destination 'C:\Windows\PolicyDefinitions' -Force
Copy-Item -Path '.\Templates\admx\en-US\*' -Destination 'C:\Windows\PolicyDefinitions\en-US' -Force
Copy-Item -Path '.\Templates\admx\fr-FR\*' -Destination 'C:\Windows\PolicyDefinitions\fr-FR' -Force

If ( (Get-WmiObject -Class win32_computersystem).PartOfDomain ) {
    # Lets Prep some AD Group Policies
    # Create Central ADM(X) Store
    # Copy ADM(X) Files to Central ADM(X) Folder
    $PdcName = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().PdcRoleOwner.Name
    $DomainName = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().Name
    New-Item -Path "\\$PdcName\SYSVOL\$DomainName\Policies\PolicyDefinitions" -ItemType Directory -Force
    Copy-Item -Path 'C:\Windows\PolicyDefinitions\*' -Destination "\\$PdcName\SYSVOL\$DomainName\Policies\PolicyDefinitions" -Force
    Copy-Item -Path 'C:\Windows\PolicyDefinitions\en-US\*' -Destination "\\$PdcName\SYSVOL\$DomainName\Policies\PolicyDefinitions\en-US"  -Force
    Copy-Item -Path 'C:\Windows\PolicyDefinitions\fr-FR\*' -Destination "\\$PdcName\SYSVOL\$DomainName\Policies\PolicyDefinitions\fr-FR" -Force
    # Browse User CSV Files
    # Create User GPOs
    # Link User GPOs to OU Users
    # Inject User GPOs
    Get-ChildItem -Name '*User*.csv' | ForEach-Object {
        $GpoName = $_.Replace('.csv', '')
        New-GPO -Name $GpoName -ErrorAction Ignore
        New-GPLink -Name $GpoName -Target (Get-ADOrganizationalUnit -Filter 'Name -eq "USERS"').DistinguishedName -ErrorAction Ignore
        Import-Csv -Path $_ | ForEach-Object {
            If ( $_.Type -eq 'Dword' ) { [INT]$Value = $_.Value } Else { [STRING]$Value = $_.Value }
            Set-GPRegistryValue -Name "$GpoName" -Key $_.Key -Type $_.Type -ValueName $_.ValueName -Value $Value  -ErrorAction Ignore
            }
        }
    # Browse Computer CSV Files
    # Create Computer GPOs
    # Link Computer GPOs to OU RDS
    # Inject Computer GPOs
    Get-ChildItem -Name '*Server*.csv' | ForEach-Object {
        $GpoName = $_.Replace('.csv', '')
        New-GPO -Name $GpoName -ErrorAction Ignore
        New-GPLink -Name $GpoName -Target (Get-ADOrganizationalUnit -Filter 'Name -eq "RDS"').DistinguishedName -ErrorAction Ignore
        Import-Csv -Path $_ | ForEach-Object { 
            If ( $_.Type -eq 'Dword' ) { [INT]$Value = $_.Value } Else { [STRING]$Value = $_.Value }
            Set-GPRegistryValue -Name "$GpoName" -Key $_.Key -Type $_.Type -ValueName $_.ValueName -Value $Value  -ErrorAction Ignore
            }
        }
    }
    Else {
    # Lets Prep some Local Policies
    # Install Extra Nice Stuff for using Set-PolicyFileEntry
    # Honor to Dave Wyatt
    Install-PackageProvider -Name 'NuGet' -Force
    Install-Module -Name 'PolicyFileEditor' -Force
    Import-Module -Name 'PolicyFileEditor' -Force
    # Browse User CSV Files
    # Create User Registry.Pol
    # Inject User Policies
    Get-ChildItem -Name '*User*.csv' | ForEach-Object {
        Import-Csv -Path $_ | ForEach-Object {
            Set-PolicyFileEntry -Path "C:\Windows\System32\GroupPolicy\User\Registry.pol" -Key $_.Key.Replace('HKCU\','') -ValueName $_.ValueName -Data $_.Value -Type $_.Type -ErrorAction Ignore
            }
        }
    # Browse Server CSV Files
    # Create Machine Registry.Pol
    # Inject Machine Policies
    Get-ChildItem -Name '*Server*.csv' | ForEach-Object {
        Import-Csv -Path $_ | ForEach-Object {
            Set-PolicyFileEntry -Path "C:\Windows\System32\GroupPolicy\Machine\Registry.pol" -Key $_.Key.Replace('HKLM\','') -ValueName $_.ValueName -Data $_.Value -Type $_.Type -ErrorAction Ignore
            }
        }
    }
