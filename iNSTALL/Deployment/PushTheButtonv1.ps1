Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Windows.Forms, System.Drawing

$SyncHash = [hashtable]::Synchronized(@{})
$SyncHash.Host = $Host
$Runspace = [runspacefactory]::CreateRunspace()
$Runspace.ApartmentState = "STA"
$Runspace.ThreadOptions = "ReuseThread" 
$Runspace.Open()
$Runspace.SessionStateProxy.SetVariable('syncHash',$syncHash)

$Code1 = {
[XML]$XAML = @"
	<Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="PushTheButton v1.0" Height="450" Width="800">
    <Grid>
        <TabControl HorizontalAlignment="Left" Height="359" Margin="29,28,0,0" VerticalAlignment="Top" Width="709">
            <TabItem Name="TabItemCreateDC" Header="Create DC" Margin="-2,-2,-49,0">
                <Grid Background="#FFE5E5E5">
                    <Label Name="LabelDomainNetbiosName" Content="DomainNetbiosName" HorizontalAlignment="Left" Height="28" Margin="10,28,0,0" VerticalAlignment="Top" Width="125"/>
                    <Label Name="LabelDomainName" Content="DomainName" HorizontalAlignment="Left" Height="28" Margin="10,61,0,0" VerticalAlignment="Top" Width="125" RenderTransformOrigin="0.452,2.089"/>
                    <Label Name="LabelDnsServerForwarders" Content="DnsServerForwarders" HorizontalAlignment="Left" Height="28" Margin="10,94,0,0" VerticalAlignment="Top" Width="125"/>
                    <TextBox Name="TextBoxDomainNetbiosName"  HorizontalAlignment="Left" Height="22" Margin="180,28,0,0" Text="ClearMedia" VerticalAlignment="Top" Width="180" TabIndex="1" IsTabStop="False" RenderTransformOrigin="0.673,0.523"/>
                    <TextBox Name="TextBoxDomainDnsName" HorizontalAlignment="Left" Height="22" Margin="180,61,0,0" Text="ClearMedia.cloud" VerticalAlignment="Top" Width="180" RenderTransformOrigin="0.462,0.455"/>
                    <TextBox Name="TextBoxDnsServerForwarders" HorizontalAlignment="Left" Height="22" Margin="180,94,0,0" Text="195.238.2.21,195.238.2.22,8.8.8.8" VerticalAlignment="Top" Width="180"/>
                    <ScrollViewer VerticalScrollBarVisibility="Auto" Margin="0,90,0,0" Height="160" Width="680"  HorizontalScrollBarVisibility="Disabled">
                    <TextBlock Name="TextBlockOutBox1" Text="" Foreground="WHITE" Background="#FF22206F" />
                    </ScrollViewer>
                    <Button Name="ButtonStart1" Content="START" HorizontalAlignment="Left" Margin="388,28,0,0" VerticalAlignment="Top" Width="234" Height="88" Foreground="Blue" FontWeight="Bold" FontSize="24" Background="Red" Visibility="Visible" />
                    <Button Name="ButtonReboot1" Content="REBOOT" HorizontalAlignment="Left" Margin="388,28,0,0" VerticalAlignment="Top" Width="234" Height="88" Foreground="Blue" FontWeight="Bold" FontSize="24" Background="Red" Visibility="Hidden"  />
                     <StatusBar Name="StatusBarStatus1" HorizontalAlignment="Left" Height="24" Margin="10,296,0,0" VerticalAlignment="Top" Width="683" Background="#FFD6D2B0" >
                        <Label Name="LabelStatus1" Content="In Progress ...." Height="25" FontSize="12" VerticalAlignment="Center" HorizontalAlignment="Center"  Visibility="Hidden" />
                        <ProgressBar Name="ProgressBarProgress1" Width="550" Height="15" Value="1" Visibility="Hidden" />
                    </StatusBar>
                </Grid>
            </TabItem>
            <TabItem Name="TabItemCreateOU" Header="Create OU" Margin="55,0,-134,0">
                <Grid Background="#FFE5E5E5">
                    <Label Name="LabelManagedOuName" Content="ManagedOuName" HorizontalAlignment="Left" Height="28" Margin="10,28,0,0" VerticalAlignment="Top" Width="165"/>
                    <Label Name="LabelClearmediaAdminUserName" Content="ClearmediaAdminUserName" HorizontalAlignment="Left" Height="28" Margin="10,61,0,0" VerticalAlignment="Top" Width="165" RenderTransformOrigin="0.452,2.089"/>
                    <Label Name="LabelClearmediaAdminPassword" Content="ClearmediaAdminPassword" HorizontalAlignment="Left" Height="28" Margin="10,94,0,0" VerticalAlignment="Top" Width="165"/>
                    <TextBox Name="TextBoxManagedOuName"  HorizontalAlignment="Left" Height="22" Margin="180,28,0,0" Text="SME" VerticalAlignment="Top" Width="180" TabIndex="1" IsTabStop="False" RenderTransformOrigin="0.673,0.523"/>
                    <TextBox Name="TextBoxClearmediaAdminUserName" HorizontalAlignment="Left" Height="22" Margin="180,61,0,0" Text="ClearmediaAdmin" VerticalAlignment="Top" Width="180" RenderTransformOrigin="0.462,0.455"/>
                    <TextBox Name="TextBoxClearmediaAdminPassword" HorizontalAlignment="Left" Height="22" Margin="180,94,0,0" Text="*********" VerticalAlignment="Top" Width="180"/>
                    <ScrollViewer VerticalScrollBarVisibility="Auto" Margin="0,90,0,0" Height="160" Width="680"  HorizontalScrollBarVisibility="Disabled">
                    <TextBlock Name="TextBlockOutBox2" Text="" Foreground="WHITE" Background="#FF22206F" />
                    </ScrollViewer>
                    <Button Name="ButtonStart2" Content="START" HorizontalAlignment="Left" Margin="388,28,0,0" VerticalAlignment="Top" Width="234" Height="88" Foreground="Blue" FontWeight="Bold" FontSize="24" Background="Red" Visibility="Visible" />
                    <Button Name="ButtonReboot2" Content="REBOOT" HorizontalAlignment="Left" Margin="388,28,0,0" VerticalAlignment="Top" Width="234" Height="88" Foreground="Blue" FontWeight="Bold" FontSize="24" Background="Red" Visibility="Hidden"  />
                     <StatusBar Name="StatusBarStatus2" HorizontalAlignment="Left" Height="24" Margin="10,296,0,0" VerticalAlignment="Top" Width="683" Background="#FFD6D2B0" >
                        <Label Name="LabelStatus2" Content="In Progress ...." Height="25" FontSize="12" VerticalAlignment="Center" HorizontalAlignment="Center"  Visibility="Hidden" />
                        <ProgressBar Name="ProgressBarProgress2" Width="550" Height="15" Value="1" Visibility="Hidden" />
                    </StatusBar>
                </Grid>
            </TabItem>
        </TabControl>

    </Grid>
	</Window>
"@

    $reader=(New-Object System.Xml.XmlNodeReader $xaml)
    $syncHash.Window=[Windows.Markup.XamlReader]::Load( $reader )
	
	# Functions
	Function Update-OutBox1 {
		Param($syncHash,$DnsForwarder,$DomainNetbiosName,$DomainDnsName)
        $Runspace = [runspacefactory]::CreateRunspace()
        $Runspace.ApartmentState = "STA"
        $Runspace.ThreadOptions = "ReuseThread"
        $Runspace.Open()
        $Runspace.SessionStateProxy.SetVariable("syncHash",$syncHash)
		$Runspace.SessionStateProxy.SetVariable("DnsForwarder",$DnsForwarder)
		$Runspace.SessionStateProxy.SetVariable("DomainNetbiosName",$DomainNetbiosName)
		$Runspace.SessionStateProxy.SetVariable("DomainDnsName",$DomainDnsName)
        $code2 = {
            [INT]$I = 0
            [STRING]$RandomPasswordPlainText = ((([char[]](65..90) | sort {get-random})[0..2] + ([char[]](33,35,36,37,42,43,45) | sort {get-random})[0] + ([char[]](97..122) | sort {get-random})[0..4] + ([char[]](48..57) | sort {get-random})[0]) | get-random -Count 10) -join ''
            $SafeModeAdministratorPassword = ConvertTo-SecureString $RandomPasswordPlainText -AsPlainText -Force
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress1.Value = $I } )
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox1.AddText("Installing Active Directory Domain Services `n") } )
            $Job = Start-Job -Name 'Active Directory Domain Services' -ScriptBlock { Install-WindowsFeature -Name 'AD-Domain-Services' -ErrorAction Stop }
            While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress1.Value = $I } ) }
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox1.AddText("Installing Group Policy Management `n") } )
            $Job = Start-Job -Name 'Group Policy Management' -ScriptBlock { Install-WindowsFeature -Name 'GPMC' -ErrorAction Stop }
            While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500  ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress1.Value = $I } ) }
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox1.AddText("Installing DNS Server `n") } )
            $Job = Start-Job -Name 'DNS Server' -ScriptBlock { Install-WindowsFeature -Name 'DNS' }
            While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500  ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress1.Value = $I } ) }
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox1.AddText("Installing Remote Desktop Licensing Services `n") } )
            $Job = Start-Job -Name 'Remote Desktop Licensing Services' -ScriptBlock { Install-WindowsFeature -Name 'RDS-Licensing' -ErrorAction Stop }
            While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress1.Value = $I } )  }
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox1.AddText("Installing Remote Server Administration Tools `n") } )
            $Job = Start-Job -Name 'Remote Server Administration Tools' -ScriptBlock { Install-WindowsFeature -Name  'RSAT-AD-Tools','RSAT-DNS-Server','RSAT-RDS-Licensing-Diagnosis-UI','RDS-Licensing-UI' -ErrorAction Stop }
            While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500  ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress1.Value = $I } ) }
			$DnsForwarder.Split(',') |Sort-Object -Descending | ForEach-Object {
                    $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox1.AddText("Adding DNS Forwarder $_ `n") } )
                    $Job = Start-Job -Name "Adding DNS Forwarder $_" -ScriptBlock { Param( $DnsForwarder ) ; Add-DnsServerForwarder -IPAddress $DnsForwarder  -ErrorAction Stop } -ArgumentList ( $_ )
                    While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress1.Value = $I } )  }
                    }
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox1.AddText("Creating AD Forest for $DomainDnsName `n") } )
            $Job = Start-Job -Name 'Install-ADDSForest' -ScriptBlock { Param($DomainDnsName,$DomainNetbiosName,$SafeModeAdministratorPassword) ; Install-ADDSForest -DomainName $DomainDnsName -DomainNetbiosName $DomainNetbiosName -SafeModeAdministratorPassword $SafeModeAdministratorPassword -NoRebootOnCompletion -ErrorAction Stop -Force} -ArgumentList ($DomainDnsName,$DomainNetbiosName,$SafeModeAdministratorPassword) 
            While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress1.Value = $I } )  }
            Get-Job | Select-Object -Property Name, State, Command, @{Name='Error';Expression={ $_.ChildJobs[0].JobStateInfo.Reason }} | Export-Csv -Path 'c:\install\Jobs.csv' -NoTypeInformation -Force
            [Boolean]$JobError = Get-Job | Where-Object { $_.State -eq 'Failed' } | ForEach-Object { $_.count -gt 0 }
            If ( $JobError ) 
                {
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress1.Visibility = "Hidden" } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.LabelStatus1.Content = "Installation Finished with ERRORS$(' .'*25)$(' '*20)Please consult Jobs.csv" } )
                }
                Else 
                {
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress1.Visibility = "Hidden" } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.LabelStatus1.Content = "Installation Finished$(' .'*45)$(' '*20)PLEASE REBOOT" } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ButtonStart1.Visibility = "Hidden" } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ButtonReboot1.Visibility = "Visible"  } )
                }
        }
        $PSinstance = [powershell]::Create().AddScript($Code2)
        $PSinstance.Runspace = $Runspace
        $job = $PSinstance.BeginInvoke()
        
    }
	Function Update-OutBox2 {
		Param($syncHash,$ManagedOuName,$ClearmediaAdminUserName,$ClearmediaAdminPassword)
        $Runspace = [runspacefactory]::CreateRunspace()
        $Runspace.ApartmentState = "STA"
        $Runspace.ThreadOptions = "ReuseThread"
        $Runspace.Open()
        $Runspace.SessionStateProxy.SetVariable("syncHash",$syncHash)
		$Runspace.SessionStateProxy.SetVariable("ManagedOuName",$ManagedOuName)
		$Runspace.SessionStateProxy.SetVariable("ClearmediaAdminUserName",$ClearmediaAdminUserName)
		$Runspace.SessionStateProxy.SetVariable("ClearmediaAdminPassword",$ClearmediaAdminPassword)
        $code3 = {
            [INT]$I = 0
			[STRING]$ManagedOU = $ManagedOuName
            [STRING]$DomainNetbiosName = [System.Environment]::UserDomainName
			If ( $ClearmediaAdminPassword -eq "*********" ) { [STRING]$ClearmediaAdminPassword = ((([char[]](65..90) | sort {get-random})[0..2] + ([char[]](33,35,36,37,42,43,45) | sort {get-random})[0] + ([char[]](97..122) | sort {get-random})[0..4] + ([char[]](48..57) | sort {get-random})[0]) | get-random -Count 10) -join '' }
			$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBoxClearmediaAdminPassword.Text = $ClearmediaAdminPassword } )
			# Get ADRootDSE
			$ADRootDSE = $(($env:USERDNSDOMAIN.Replace('.',',DC=')).Insert(0,'DC='))
			#Create HashTable for OU Provisioning
			$OUs = [ordered]@{
				"$ManagedOU" =  "$ADRootDSE"
				'Users'= "OU=$ManagedOU,$ADRootDSE"
				'Light Users' = "OU=Users,OU=$ManagedOU,$ADRootDSE"
				'Admin Users' = "OU=$ManagedOU,$ADRootDSE"
				'Groups' = "OU=$ManagedOU,$ADRootDSE"
				'RAS' = "OU=Groups,OU=$ManagedOU,$ADRootDSE"
				'NetAccess' = "OU=Groups,OU=$ManagedOU,$ADRootDSE"
				'Servers' = "OU=$ManagedOU,$ADRootDSE"
				'RDS' = "OU=Servers,OU=$ManagedOU,$ADRootDSE"
				'DATA' = "OU=Servers,OU=$ManagedOU,$ADRootDSE"
				'WEB' = "OU=Servers,OU=$ManagedOU,$ADRootDSE"
				}
			# Create OU Structure
			$OUs.keys | ForEach-Object { 
                    $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox2.AddText("Creating OU $_ `n") } ) 
                    $I += 4
                    $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress2.Value = $I } )
                    New-ADOrganizationalUnit -Name $_ -Path $($OUs.$_)
                    }
            #Create HashTable for Group Provisioning
            $Groups = [ordered]@{
                    "$DomainNetbiosName-Admins"= "OU=Groups,OU=$ManagedOU,$ADRootDSE"
                    "$DomainNetbiosName-Users" = "OU=Groups,OU=$ManagedOU,$ADRootDSE"
                    "$DomainNetbiosName-THINPRINT-USERS" = "OU=Groups,OU=$ManagedOU,$ADRootDSE"
                    "$DomainNetbiosName-RAS-USERS" = "OU=RAS,OU=Groups,OU=$ManagedOU,$ADRootDSE"
	                "$DomainNetbiosName-RAS-Office-USERS" = "OU=RAS,OU=Groups,OU=$ManagedOU,$ADRootDSE"
                    "$DomainNetbiosName-RAS-Desktop-USERS" = "OU=RAS,OU=Groups,OU=$ManagedOU,$ADRootDSE"
                    "$DomainNetbiosName-RAS-Explorer-USERS" = "OU=RAS,OU=Groups,OU=$ManagedOU,$ADRootDSE"
                    "$DomainNetbiosName-RAS-InternetExplorer-USERS" = "OU=RAS,OU=Groups,OU=$ManagedOU,$ADRootDSE"
                    "$DomainNetbiosName-RAS-AdobeReader-USERS" = "OU=RAS,OU=Groups,OU=$ManagedOU,$ADRootDSE"
	                "$DomainNetbiosName-FTP-USERS" = "OU=NetAccess,OU=Groups,OU=$ManagedOU,$ADRootDSE"
	                "$DomainNetbiosName-RDP-USERS" = "OU=NetAccess,OU=Groups,OU=$ManagedOU,$ADRootDSE"
	                "$DomainNetbiosName-SSLVPN-USERS" = "OU=NetAccess,OU=Groups,OU=$ManagedOU,$ADRootDSE"
                    }
            ForEach ($Group in $Groups.keys) {
                    $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox2.AddText("Adding Group  User to $Group in $($Groups.$Group) `n") } ) 
                    $I += 4
                    $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress2.Value = $I } )
                    New-ADGroup -Name $Group -GroupScope 'Global' -Path $($Groups.$Group)
                    }
            #Create HashTable for User Provisioning
            $NewUserParams= @{
		        'Name' = $ClearmediaAdminUserName
		        'SamAccountName' = $ClearmediaAdminUserName
		        'DisplayName' = $ClearmediaAdminUserName
		        'Description' = $ClearmediaAdminUserName
		        'EmailAddress' = 'support@clearmedia.be'
		        'Path' = "OU=Admin Users,OU=$ManagedOU,$ADRootDSE"
		        'PasswordNeverExpires' = $TRUE
		        'AccountPassword' =  ConvertTo-SecureString $ClearmediaAdminPassword -AsPlainText -Force
		        }
            # Create ClearMedia User
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox2.AddText("Creating $ClearmediaAdminUserName User `n") } ) 
            $I += 2
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress2.Value = $I } )
            New-ADUser @NewUserParams
            # Add ClearMedia User to Admin Groups
            ('Domain Admins','Enterprise Admins') | ForEach-Object { 
                    $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox2.AddText("Adding ClearMedia User to $_ `n") } ) 
                    $I += 4
                    $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress2.Value = $I } )
                    Add-ADGroupMember -Identity "CN=$_,CN=Users,$ADRootDSE" -Members "CN=$($NewUserParams.Name),$($NewUserParams.Path)" 
                    }
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress2.Visibility = "Hidden" } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.LabelStatus2.Content = "Installation Finished$(' .'*45)$(' '*20)" } )
        }
        $PSinstance = [powershell]::Create().AddScript($Code3)
        $PSinstance.Runspace = $Runspace
        $job = $PSinstance.BeginInvoke()
        
    }
	
	# AutoFind all controls
	$XAML.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]")  | ForEach-Object { $syncHash.Add($_.Name, $syncHash.Window.Findname($_.Name)) }
    #$syncHash.DomainNetbiosName = $SyncHash.TextBoxDomainNetbiosName.Text
    #$syncHash.DomainDnsName = $SyncHash.TextBoxDomainDnsName.Text
    #$syncHash.DNS = $SyncHash.TextBoxDnsServerForwarders.Text

	# Click Actions
    $syncHash.ButtonStart1.Add_Click({
        $syncHash.ButtonStart1.IsEnabled = $False
        $syncHash.LabelStatus1.Visibility = "Visible"
        $syncHash.ProgressBarProgress1.Visibility = "Visible"
		Update-OutBox1 -syncHash $syncHash -DnsForwarder $syncHash.TextBoxDnsServerForwarders.Text -DomainNetbiosName $SyncHash.TextBoxDomainNetbiosName.Text -DomainDnsName $SyncHash.TextBoxDomainDnsName.Text
        # $SyncHash.host.ui.WriteVerboseLine($SyncHash.TextBoxDomainNetbiosName.Text)
        })
    $syncHash.ButtonReboot1.Add_Click({
        Restart-Computer
        })
    $syncHash.ButtonStart2.Add_Click({
		$syncHash.ButtonStart1.IsEnabled = $False
        $syncHash.ButtonStart2.IsEnabled = $False
        $syncHash.LabelStatus2.Visibility = "Visible"
        $syncHash.ProgressBarProgress2.Visibility = "Visible"
		Update-OutBox2 -syncHash $syncHash -ManagedOuName $syncHash.TextBoxManagedOuName.Text -ClearmediaAdminUserName $SyncHash.TextBoxClearmediaAdminUserName.Text -ClearmediaAdminPassword $SyncHash.TextBoxClearmediaAdminPassword.Text
        # $SyncHash.host.ui.WriteVerboseLine($SyncHash.TextBoxDomainNetbiosName.Text)
        })

   $syncHash.Window.ShowDialog()
   $Runspace.Close()
   $Runspace.Dispose()
}


$PSinstance1 = [powershell]::Create().AddScript($Code1)
$PSinstance1.Runspace = $Runspace
$job = $PSinstance1.BeginInvoke()
