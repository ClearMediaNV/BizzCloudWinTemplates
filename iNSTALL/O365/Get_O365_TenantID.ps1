Add-Type -AssemblyName System.Windows.Forms

# Create Form
$Form = New-Object System.Windows.Forms.Form 
$Form.Text = 'Get O365 TenantID'
$Form.showIcon = $false
$Form.MinimizeBox = $false
$Form.MaximizeBox = $false
$Form.Height = 245
$Form.Width = 540
$Form.StartPosition = 'CenterScreen'
$Form.FormBorderStyle = 'fixedsingle'
$Form.Topmost = $True

# Create ScriptBlock
$scripblock = 
    {
    try
        {
        [STRING]$Domainname = $textDomain.Text
        $labelTenantID.Text = (Invoke-RestMethod -Uri "https://login.windows.net/$Domainname/.well-known/openid-configuration").token_endpoint.Split(‘/’)[3]
        $labelTenantID.BackColor = 'LightGreen'
        $labelTenantID.Refresh()
        }
    catch
        {
        $labelTenantID.Text = "$DomainName not found !"
        $labelTenantID.BackColor = 'Red'
        $labelTenantID.Refresh()
        }
    }
	
# Add OK Button
# On Click or Enter launch ScriptBlock
$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Left = 100
$OKButton.Top = 160
$OKButton.Width = 75
$OKButton.Height = 23
$OKButton.Text = 'OK'
$OKButton.Add_Click($scripblock)
$Form.AcceptButton = $OKButton
$Form.Controls.Add($OKButton)

#Add Cancel Button
$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Left = 350
$CancelButton.Top = 160
$CancelButton.Width = 75
$CancelButton.Height = 23
$CancelButton.Text = 'CANCEL'
$Form.CancelButton = $CancelButton
$Form.Controls.Add($CancelButton)

#Add Label
$labelDomain = New-Object System.Windows.Forms.Label
$labelDomain.AutoSize = $false
$labelDomain.Top = 25
$labelDomain.Left = 160
$labelDomain.Width = 400
$labelDomain.Height = 30
$labelDomain.Font = 'Candara , 11pt, style=Regular'
$labelDomain.Text = 'Please enter the Domain Name'
$Form.Controls.Add($labelDomain)

#Add DomainName TextBox
$textDomain = New-Object System.Windows.Forms.TextBox
$textDomain.AutoSize = $false
$textDomain.Top = 65
$textDomain.Left = 40
$textDomain.Width = 450
$textDomain.Height = 30
$textDomain.BackColor = 'green'
$textDomain.Font = 'Candara , 14pt, style=Bold'
$textDomain.TextAlign = 'Center'
$textDomain.Text = 'ClearMedia.be'
$Form.Controls.Add($textDomain)

#Add TenantID TextBox
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
$labelTenantID.Text = ''
$Form.Controls.Add($labelTenantID)

$Form.ShowDialog()

