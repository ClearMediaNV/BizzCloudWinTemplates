Add-Type -AssemblyName System.Windows.Forms

# Create Form 'Select O365 Pro Plus Version'
$Form = New-Object System.Windows.Forms.Form 
$Form.Text = 'Select O365 Pro Plus Version'
$Form.Height = 200
$Form.Width = 400
$Form.showIcon = $false
$Form.MinimizeBox = $false
$Form.MaximizeBox = $false
$Form.AutoSize = $true
$Form.StartPosition = 'CenterScreen'
$Form.FormBorderStyle = 'fixedsingle'
$Form.Topmost = $False

# Add Button 'OK'
$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Left = 100
$OKButton.Top = 120
$OKButton.Width = 75
$OKButton.Height = 23
$OKButton.Text = 'OK'
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$Form.AcceptButton = $OKButton
$Form.Controls.Add( $OKButton )

# Add Button 'Cancel'
$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Left = 220
$CancelButton.Top = 120
$CancelButton.Width = 75
$CancelButton.Height = 23
$CancelButton.Text = 'CANCEL'
$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$Form.CancelButton = $CancelButton
$Form.Controls.Add( $CancelButton )

# Add ListBox 'O365 Pro Plus BIT Selection'
# Default 32 BIT
$listBox = New-Object System.Windows.Forms.ListBox 
$listBox.Left = 95
$listBox.Top = 40
$listBox.Width = 205
$listBox.Height = 40
[VOID] $listBox.Items.Add( 'O365 Pro Plus 32 bit' )
[VOID] $listBox.Items.Add( 'O365 Pro Plus 64 bit' )
$listBox.SelectedIndex = 0
$Form.Controls.Add( $listBox )

$Result = $Form.ShowDialog()

# On 'O365 Pro Plus BIT Selection' Proceed else Exit
$O365version = ''
If ( $Result -eq [System.Windows.Forms.DialogResult]::OK ) { $O365version = $listBox.SelectedItem } Else { Exit }

# Add ProgressBar
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Downloading $O365version Setup Files"
$Form.Height = 110
$Form.Width = 500
$Form.BackColor = 'green'
$Form.ForeColor = 'white'
$Form.showIcon = $false
$Form.MinimizeBox = $false
$Form.MaximizeBox = $false
$Form.AutoSize = $true
$Form.StartPosition = 'CenterScreen'
$Form.FormBorderStyle = 'fixedsingle'
$Form.Topmost = $False

$Label = New-Object System.Windows.Forms.Label
$Label.Text = 'Starting. Please wait ... '
$Label.Left = 150
$Label.Top = 10
$Label.Width = 500 -150
$Label.Height = 20
$Form.Controls.Add( $Label )

$ProgressBar = New-Object System.Windows.Forms.ProgressBar
$ProgressBar.Name = 'PowerShellProgressBar'
$ProgressBar.Value = 0
$ProgressBar.Style='Continuous'
$ProgressBar.Left = 5
$ProgressBar.Top = 40
$ProgressBar.Width = 500 - 10
$ProgressBar.Height = 20
$Form.Controls.Add( $ProgressBar )

$Form.Show() 

# Download and Extract Office Deployment Tool
[System.Net.ServicePointManager]::SecurityProtocol = 'Tls12'
$UrlOfficeDeploymentTool = 'https://www.microsoft.com/en-us/download/confirmation.aspx?id=49117'
$UrlDownload = ( ( Invoke-WebRequest -Uri "$UrlOfficeDeploymentTool" -UseBasicParsing ).links | Where-Object -FilterScript { $PsItem.href -match '/officedeploymenttool_\d{5}-\d{5}\.exe$' } ).href[0]
$FileDownload = "$Env:LOCALAPPDATA\ODT.exe"
(New-Object System.Net.WebClient).DownloadFile($UrlDownload, $FileDownload)
Do { Start-Sleep -Seconds 2 } Until ( Test-Path -Path $FileDownload ) 
Invoke-Expression -Command "CMD.EXE /C '$FileDownload /quiet /extract:$FileDownload\..'"

# Download 'O365 Pro Plus BIT Selection'
Switch ( $O365version )
    {
    'O365 Pro Plus 32 bit' { Copy-Item -Path 'C:\Install\O365\configuration32.xml' -Destination "$Env:LOCALAPPDATA\configuration.xml" -Force }
    'O365 Pro Plus 64 bit' { Copy-Item -Path 'C:\Install\O365\configuration64.xml' -Destination "$Env:LOCALAPPDATA\configuration.xml" -Force }
    Default { Exit }
    }
$Job = Start-Job -Name "Download $O365version" -ScriptBlock { Invoke-Expression -Command "$Env:LOCALAPPDATA\setup.exe /download $Env:LOCALAPPDATA\configuration.xml" }

# Show ProgressBar Dynamics
$Counter = 0
Do
    {
    $ProgressBar.Value = $Counter
    $Label.Text = 'Please wait while downloading Setup Files'
    $Form.Refresh()
    Start-Sleep -Seconds 7
    If ( $Counter -eq 100 ) { $Counter = 0 } Else { $Counter++ }
    }
While ( $Job.State -ne 'Completed' )
$Form.Close()

# Install 'O365 Pro Plus BIT Selection'
Invoke-Expression -Command "$Env:LOCALAPPDATA\setup.exe /configure  $Env:LOCALAPPDATA\configuration.xml"
