Add-Type -AssemblyName System.Windows.Forms

## -- Create Select Form
$Form1 = New-Object System.Windows.Forms.Form 
$Form1.Text = "Get O365 TenantID"
$Form1.showIcon = $false
$Form1.MinimizeBox = $false
$Form1.MaximizeBox = $false
$Form1.Height = 245
$Form1.Width = 540
$Form1.StartPosition = "CenterScreen"
$Form1.FormBorderStyle = 'fixedsingle'
$Form1.Topmost = $True

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Left = 100
$OKButton.Top = 160
$OKButton.Width = 75
$OKButton.Height = 23
$OKButton.Text = "OK"
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$Form1.AcceptButton = $OKButton
$Form1.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Left = 350
$CancelButton.Top = 160
$CancelButton.Width = 75
$CancelButton.Height = 23
$CancelButton.Text = "CANCEL"
$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$Form1.CancelButton = $CancelButton
$Form1.Controls.Add($CancelButton)

$labelDomain = New-Object System.Windows.Forms.Label
$labelDomain.AutoSize = $false
$labelDomain.Top = 25
$labelDomain.Left = 160
$labelDomain.Width = 400
$labelDomain.Height = 30
$labelDomain.Font = 'Candara , 11pt, style=Regular'
$labelDomain.Text = "Please enter the Domain Name"
$Form1.Controls.Add($labelDomain)

$textDomain = New-Object System.Windows.Forms.TextBox
$textDomain.AutoSize = $false
$textDomain.Top = 65
$textDomain.Left = 40
$textDomain.Width = 450
$textDomain.Height = 30
$textDomain.BackColor = 'green'
$textDomain.Font = 'Candara , 14pt, style=Bold'
$textDomain.TextAlign = 'Center'
$textDomain.Text = "clearmedia.be"
$Form1.Controls.Add($textDomain)

$labelTenantID = New-Object System.Windows.Forms.TextBox
$labelTenantID.AutoSize = $false
$labelTenantID.BorderStyle = 'None'
$labelTenantID.BackColor = 'LightGray'
$labelTenantID.Top = 95
$labelTenantID.Left = 40
$labelTenantID.Width = 449
$labelTenantID.Height = 30
$labelTenantID.Font = 'Candara , 14pt, style=Bold'
$labelTenantID.TextAlign = 'Center'
$labelTenantID.Text = ""
$Form1.Controls.Add($labelTenantID)

do
    {
    $result = $Form1.ShowDialog()
    if ($result -eq [System.Windows.Forms.DialogResult]::OK) { [STRING]$Domainname = $textDomain.Text }
    try
    {
    $labelTenantID.Text = (Invoke-RestMethod -Uri "https://login.windows.net/$Domainname/.well-known/openid-configuration").token_endpoint.Split(‘/’)[3]
    $labelTenantID.BackColor = 'LightGreen'
    $labelTenantID.Refresh()
    }
    catch
    {
    $labelTenantID.BackColor = 'Red'
    $labelTenantID.Text = "$DomainName not found !"
    $labelTenantID.Refresh()
    }

    }
while ( $result -ne [System.Windows.Forms.DialogResult]::CANCEL )
