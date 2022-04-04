Add-Type -AssemblyName System.Windows.Forms

# Create Form
$Form = New-Object System.Windows.Forms.Form 
$Form.Text = ' Get O365 TenantID'
$Form.showIcon = $false
$Form.MinimizeBox = $false
$Form.MaximizeBox = $false
$Form.Height = 245
$Form.Width = 580
$Form.StartPosition = 'CenterScreen'
$Form.FormBorderStyle = 'fixedsingle'
$Form.Topmost = $False

# Add Action ScriptBlocks
$ScriptBlockOK = {
    try {
        $Domainname = $TextBoxDomainName.Text
        $Url = "https://login.windows.net/$Domainname/.well-known/openid-configuration"
        $TextBoxTenantID.Text = ( Invoke-RestMethod -Uri $Url ).token_endpoint.Split('/')[3]
        $TextBoxTenantID.BackColor = 'LightGreen'
        $TextBoxTenantID.Refresh()
        }
    catch {
        $TextBoxTenantID.Text = "$DomainName not found"
        $TextBoxTenantID.BackColor = 'Red'
        $TextBoxTenantID.Refresh()
        }
    }
$ScriptBlockCspDelegation = {
    $Url = 'https://bit.ly/3pWul40'
    Start-Process $Url
    }
$ScriptBlockCopyToClipboardDomain = { Set-Clipboard -Value $TextBoxDomainName.Text }
$ScriptBlockCopyToClipboardTenantID = { Set-Clipboard -Value $TextBoxTenantID.Text }

# Add OK Button
# On Click or Enter launch ScriptBlock
$ButtonOK = New-Object System.Windows.Forms.Button
$ButtonOK.Left = 40
$ButtonOK.Top = 150
$ButtonOK.Width = 75
$ButtonOK.Height = 40
$ButtonOK.BackColor = 'White'
$ButtonOK.Text = 'OK'
$ButtonOK.Add_Click($ScriptBlockOK)
$Form.AcceptButton = $ButtonOK
$Form.Controls.Add($ButtonOK)

# Add CspDelegation Button
$ButtonCspDelegation = New-Object System.Windows.Forms.Button
$ButtonCspDelegation.Left = 120
$ButtonCspDelegation.Top = 150
$ButtonCspDelegation.Width = 290
$ButtonCspDelegation.Height = 40
$ButtonCspDelegation.BackColor = 'LightYellow'
$ButtonCspDelegation.ForeColor = 'Red'
$ButtonCspDelegation.Font = new-object System.Drawing.Font('',8,[System.Drawing.FontStyle]::Bold)
$ButtonCspDelegation.Text = 'Start CSP Partner Relationship to ClearMedia NV'
$ButtonCspDelegation.Add_Click($ScriptBlockCspDelegation)
$Form.Controls.Add($ButtonCspDelegation)


# Add Cancel Button
$ButtonCancel = New-Object System.Windows.Forms.Button
$ButtonCancel.Left = 415
$ButtonCancel.Top = 150
$ButtonCancel.Width = 75
$ButtonCancel.Height = 40
$ButtonCancel.BackColor = 'White'
$ButtonCancel.Text = 'CANCEL'
$Form.CancelButton = $ButtonCancel
$Form.Controls.Add($ButtonCancel)

# Add CopyToClipboardDomain Button
$ButtonCopyToClipboardDomain = New-Object System.Windows.Forms.Button
$ButtonCopyToClipboardDomain.Left = 500
$ButtonCopyToClipboardDomain.Top = 65
$ButtonCopyToClipboardDomain.Width = 50
$ButtonCopyToClipboardDomain.Height = 30
$ButtonCopyToClipboardDomain.BackColor = 'White'
$ButtonCopyToClipboardDomain.Text = 'Copy'
$ButtonCopyToClipboardDomain.Add_Click($ScriptBlockCopyToClipboardDomain)
$Form.Controls.Add($ButtonCopyToClipboardDomain)

# Add CopyToClipboardTenantID Button
$ButtonCopyToClipboardTenantID = New-Object System.Windows.Forms.Button
$ButtonCopyToClipboardTenantID.Left = 500
$ButtonCopyToClipboardTenantID.Top = 95
$ButtonCopyToClipboardTenantID.Width = 50
$ButtonCopyToClipboardTenantID.Height = 30
$ButtonCopyToClipboardTenantID.BackColor = 'White'
$ButtonCopyToClipboardTenantID.Text = 'Copy'
$ButtonCopyToClipboardTenantID.Add_Click($ScriptBlockCopyToClipboardTenantID)
$Form.Controls.Add($ButtonCopyToClipboardTenantID)

# Add DomaiName Label
$LabelDomainName = New-Object System.Windows.Forms.Label
$LabelDomainName.AutoSize = $false
$LabelDomainName.Top = 25
$LabelDomainName.Left = 160
$LabelDomainName.Width = 400
$LabelDomainName.Height = 30
$LabelDomainName.Font = 'Candara , 11pt, style=Regular'
$LabelDomainName.Text = 'Please enter the Domain Name'
$Form.Controls.Add($LabelDomainName)

# Add DomainName TextBox
$TextBoxDomainName = New-Object System.Windows.Forms.TextBox
$TextBoxDomainName.AutoSize = $false
$TextBoxDomainName.Top = 65
$TextBoxDomainName.Left = 40
$TextBoxDomainName.Width = 450
$TextBoxDomainName.Height = 30
$TextBoxDomainName.BackColor = 'green'
$TextBoxDomainName.Font = 'Candara , 14pt, style=Bold'
$TextBoxDomainName.TextAlign = 'Center'
$TextBoxDomainName.Text = 'ClearMedia.be'
$Form.Controls.Add($TextBoxDomainName)

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
