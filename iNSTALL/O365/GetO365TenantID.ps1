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
$Form.Topmost = $False

# Create ScriptBlock
$ScriptBlock = 
    {
    try
        {
        [STRING]$Domainname = $TextBoxDomain.Text
        $TextBoxTenantID.Text = (Invoke-RestMethod -Uri "https://login.windows.net/$Domainname/.well-known/openid-configuration").token_endpoint.Split(‘/’)[3]
        $TextBoxTenantID.BackColor = 'LightGreen'
        $TextBoxTenantID.Refresh()
        }
    catch
        {
        $TextBoxTenantID.Text = "$DomainName not found"
        $TextBoxTenantID.BackColor = 'Red'
        $TextBoxTenantID.Refresh()
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
$OKButton.Add_Click($ScriptBlock)
$Form.AcceptButton = $OKButton
$Form.Controls.Add($OKButton)

# Add Cancel Button
$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Left = 350
$CancelButton.Top = 160
$CancelButton.Width = 75
$CancelButton.Height = 23
$CancelButton.Text = 'CANCEL'
$Form.CancelButton = $CancelButton
$Form.Controls.Add($CancelButton)

# Add Label
$LabelDomain = New-Object System.Windows.Forms.Label
$LabelDomain.AutoSize = $false
$LabelDomain.Top = 25
$LabelDomain.Left = 160
$LabelDomain.Width = 400
$LabelDomain.Height = 30
$LabelDomain.Font = 'Candara , 11pt, style=Regular'
$LabelDomain.Text = 'Please enter the Domain Name'
$Form.Controls.Add($LabelDomain)

# Add DomainName TextBox
$TextBoxDomain = New-Object System.Windows.Forms.TextBox
$TextBoxDomain.AutoSize = $false
$TextBoxDomain.Top = 65
$TextBoxDomain.Left = 40
$TextBoxDomain.Width = 450
$TextBoxDomain.Height = 30
$TextBoxDomain.BackColor = 'green'
$TextBoxDomain.Font = 'Candara , 14pt, style=Bold'
$TextBoxDomain.TextAlign = 'Center'
$TextBoxDomain.Text = 'ClearMedia.be'
$Form.Controls.Add($TextBoxDomain)

# Add TenantID TextBox
$TextBoxTenantID = New-Object System.Windows.Forms.TextBox
$TextBoxTenantID.AutoSize = $false
$TextBoxTenantID.BackColor = 'LightGray'
$TextBoxTenantID.Top = 95
$TextBoxTenantID.Left = 40
$TextBoxTenantID.Width = 450
$TextBoxTenantID.Height = 30
$TextBoxTenantID.Font = 'Candara , 14pt, style=Bold'
$TextBoxTenantID.TextAlign = 'Center'
$TextBoxTenantID.Text = ''
$Form.Controls.Add($TextBoxTenantID)

$Form.ShowDialog()

