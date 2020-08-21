Add-Type -AssemblyName System.Windows.Forms

# Create Form
$Form = New-Object System.Windows.Forms.Form 
$Form.Text = 'Get O365 TenantID'
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
        [STRING]$Domainname = $TextBoxDomain.Text
        $TextBoxTenantID.Text = (Invoke-RestMethod -Uri "https://login.windows.net/$Domainname/.well-known/openid-configuration").token_endpoint.Split('/')[3]
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
    $Url = 'https://portal.office.com/partner/partnersignup.aspx?type=ResellerRelationship&id=f59f16d4-ed58-42e1-92c1-af863f919035&csp=1&msppid=0'
    Start-Process $Url
    }
$CopyToClipboardDomain = { Set-Clipboard -Value $TextBoxDomain.Text }
$CopyToClipboardTenantID = { Set-Clipboard -Value $TextBoxTenantID.Text }

# Add OK Button
# On Click or Enter launch ScriptBlock
$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Left = 40
$OKButton.Top = 150
$OKButton.Width = 75
$OKButton.Height = 40
$OKButton.BackColor = 'White'
$OKButton.Text = 'OK'
$OKButton.Add_Click($ScriptBlockOK)
$Form.AcceptButton = $OKButton
$Form.Controls.Add($OKButton)

# Add CspDelegation Button
$CspDelegationButton = New-Object System.Windows.Forms.Button
$CspDelegationButton.Left = 120
$CspDelegationButton.Top = 150
$CspDelegationButton.Width = 290
$CspDelegationButton.Height = 40
$CspDelegationButton.BackColor = 'LightYellow'
$CspDelegationButton.ForeColor = 'Red'
$CspDelegationButton.Font = new-object System.Drawing.Font('',8,[System.Drawing.FontStyle]::Bold)
$CspDelegationButton.Text = 'Start CSP Delegation to ClearMedia NV'
$CspDelegationButton.Add_Click($ScriptBlockCspDelegation)
$Form.Controls.Add($CspDelegationButton)


# Add Cancel Button
$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Left = 415
$CancelButton.Top = 150
$CancelButton.Width = 75
$CancelButton.Height = 40
$CancelButton.BackColor = 'White'
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

#copy to clipboard domain
$CopyDomainButton = New-Object System.Windows.Forms.Button
$CopyDomainButton.Left = 500
$CopyDomainButton.Top = 65
$CopyDomainButton.Width = 50
$CopyDomainButton.Height = 30
$CopyDomainButton.BackColor = 'White'
$CopyDomainButton.Text = 'Copy'
$CopyDomainButton.Add_Click($CopyToClipboardDomain)
$Form.Controls.Add($CopyDomainButton)


#copy to clipboard tenantid
$CopyTenantIDButton = New-Object System.Windows.Forms.Button
$CopyTenantIDButton.Left = 500
$CopyTenantIDButton.Top = 95
$CopyTenantIDButton.Width = 50
$CopyTenantIDButton.Height = 30
$CopyTenantIDButton.BackColor = 'White'
$CopyTenantIDButton.Text = 'Copy'
$CopyTenantIDButton.Add_Click($CopyToClipboardTenantID)
$Form.Controls.Add($CopyTenantIDButton)

$Form.ShowDialog()
