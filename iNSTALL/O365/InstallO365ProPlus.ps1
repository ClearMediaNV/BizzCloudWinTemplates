Add-Type -AssemblyName System.Windows.Forms

# Create Form 'Select O365 Pro Plus Version'
$Form1 = New-Object System.Windows.Forms.Form 
$Form1.Text = 'Select O365 Pro Plus Version'
$Form1.Height = 200
$Form1.Width = 400
$Form1.showIcon = $false
$Form1.MinimizeBox = $false
$Form1.MaximizeBox = $false
$Form1.AutoSize = $true
$Form1.StartPosition = 'CenterScreen'
$Form1.FormBorderStyle = 'fixedsingle'
$Form1.Topmost = $True

# Add Button 'OK'
$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Left = 100
$OKButton.Top = 120
$OKButton.Width = 75
$OKButton.Height = 23
$OKButton.Text = 'OK'
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$Form1.AcceptButton = $OKButton
$Form1.Controls.Add($OKButton)

# Add Button 'Cancel'
$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Left = 220
$CancelButton.Top = 120
$CancelButton.Width = 75
$CancelButton.Height = 23
$CancelButton.Text = 'CANCEL'
$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$Form1.CancelButton = $CancelButton
$Form1.Controls.Add($CancelButton)

# Add ListBox 'O365 Pro Plus BIT Selection'
# Default 32 BIT
$listBox = New-Object System.Windows.Forms.ListBox 
$listBox.Left = 95
$listBox.Top = 40
$listBox.Width = 205
$listBox.Height = 40
[void] $listBox.Items.Add('O365 Pro Plus 32 bit')
[void] $listBox.Items.Add('O365 Pro Plus 64 bit')
$listBox.SelectedIndex = 0
$Form1.Controls.Add($listBox)

$result = $Form1.ShowDialog()

# On 'O365 Pro Plus BIT Selection' Proceed else Quit
[STRING]$O365version = ''
if ($result -eq [System.Windows.Forms.DialogResult]::OK) { $O365version = $listBox.SelectedItem } else { exit }

# Add ProgressBar
$Form2 = New-Object System.Windows.Forms.Form
$Form2.Text = "Downloading $O365version Setup Files"
$Form2.Height = 110
$Form2.Width = 500
$Form2.BackColor = 'green'
$Form2.ForeColor = 'white'
$Form2.showIcon = $false
$Form2.MinimizeBox = $false
$Form2.MaximizeBox = $false
$Form2.AutoSize = $true
$Form2.StartPosition = 'CenterScreen'
$Form2.FormBorderStyle = 'fixedsingle'
$Form2.Topmost = $True

$Label = New-Object System.Windows.Forms.Label
$Label.Text = 'Starting. Please wait ... '
$Label.Left = 150
$Label.Top = 10
$Label.Width = 500 -150
$Label.Height = 20
$Form2.Controls.Add($Label)

$PB = New-Object System.Windows.Forms.ProgressBar
$PB.Name = 'PowerShellProgressBar'
$PB.Value = 0
$PB.Style='Continuous'
$PB.Left = 5
$PB.Top = 40
$PB.Width = 500 - 10
$PB.Height = 20
$Form2.Controls.Add($PB)

$Form2.Show() 

# Download and Extract OfficeDeploymentTool
$Url = 'https://www.microsoft.com/en-us/download/confirmation.aspx?id=49117'
$UrlDownload =  (Invoke-WebRequest -Uri $url  -UseBasicParsing | ForEach-Object { $_.links } | Where-Object { $_.href -like '*officedeploymenttool*' }).href[0]
$Output = $UrlDownload.Split('/')[$_.count-1]
(New-Object System.Net.WebClient).DownloadFile($UrlDownload, $Output)
Invoke-Expression -Command "& .\$Output /quiet /extract:."
 
# Download 'O365 Pro Plus BIT Selection'
switch ( $O365version )
    {
    'O365 Pro Plus 32 bit' {$Job = Start-Job -Name "Download $O365version" -ScriptBlock { Invoke-Expression -Command '& c:\install\o365\setup.exe /download  c:\install\o365\configuration32.xml' } }
    'O365 Pro Plus 64 bit' {$Job = Start-Job -Name "Download $O365version" -ScriptBlock { Invoke-Expression -Command '& c:\install\o365\setup.exe /download  c:\install\o365\configuration64.xml' } }
    Default {exit}
    }

# Show ProgressBar Dynamics
[INT]$Counter = 0
do
    {
    $PB.Value = $Counter
    $Label.Text = 'Please wait while downloading Setup Files'
    $Form2.Refresh()
    Start-Sleep -Seconds 7
    If ( $Counter -eq 100) {$Counter = 0} else { $Counter++ }
    }
while ( $Job.State -ne 'Completed' )
$Form2.Close()

# Install 'O365 Pro Plus BIT Selection'
switch ( $O365version )
    {
    'O365 Pro Plus 32 bit' {Invoke-Expression -Command '& c:\install\o365\setup.exe /configure  c:\install\o365\configuration32.xml'}
    'O365 Pro Plus 64 bit' {Invoke-Expression -Command '& c:\install\o365\setup.exe /configure  c:\install\o365\configuration64.xml'}
    Default {exit}
    }
