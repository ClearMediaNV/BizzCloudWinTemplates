<#
	.SYNOPSIS
		Patch the Path To OST file in existing MAPI Profile
	.DESCRIPTION
		If MAPI Profile already created, GPO does not affect existing OST Path
    	.NOTES
		Applies to Office 2016
		OST Must Be Enabled
    	.EXAMPLE
        	PatchOstPath.ps1 -OstPath "D:\Users\$Env:UserName\$Env:UserName.ost" -MapiProfile 'Outlook'
	#>
param (
	[Parameter(Position=0,Mandatory=$False)][STRING]$OstPath = "D:\Users\$Env:UserName\$Env:UserName.ost",
  	[Parameter(Position=1,Mandatory=$False)][STRING]$MapiProfile = ''
	)
# Cfr MFCMAPI
# Property Name: PR_PROFILE_OFFLINE_STORE_PATH_W
# Tag: 0x6610001F
# Type: PT_UNICODE
# DASL: http://schemas.microsoft.com/mapi/proptag/0x6610001F
If ( $MapiProfile -eq '' ) { $MapiProfile = Get-ItemPropertyValue -Path 'HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook' -Name 'DefaultProfile' -ErrorAction SilentlyContinue }
If ( (Get-ChildItem -Path 'HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\Profiles' | Select-Object -ExpandProperty PSChildName) -ne $MapiProfile )
    {
    Write-Output 'No Mapi Profile'
    Start-Sleep -Seconds 5
    Exit
    }
# Encode OstPath
[BYTE[]]$PathArray = $Null ; $OstPath.ToCharArray() | ForEach-Object { $PathArray += ($_,0) } ; $PathArray += (0,0)
If  ( Get-ChildItem -Path "HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\Profiles\$MapiProfile" | Where-Object { $_.Property -eq '001f6610' } )
    {
    Get-ChildItem -Path "HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\Profiles\$MapiProfile" | Where-Object { $_.Property -eq '001f6610' } | ForEach-Object { Set-ItemProperty -LiteralPath $_.PSPath   -Name '001f6610' -Value $PathArray }
    }
    Else
        {
        Write-Output 'No Mapi Profile Offline Store Path'
        Start-Sleep -Seconds 5
        }
