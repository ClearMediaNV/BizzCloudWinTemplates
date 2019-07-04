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
        Title="PushTheButton v1.0" Height="800" Width="1280">
    <Grid>
        <TabControl HorizontalAlignment="Left" Height="730" Margin="10,0,0,0" VerticalAlignment="Top" Width="1260">
            <TabItem Name="TabItemCreateDC" Header="Create DC" Margin="-2,0,-60,0">
                <Grid Background="#FFE5E5E5">
                    <Label Name="LabelDomainNetbiosName" Content="DomainNetbiosName" HorizontalAlignment="Left" Height="28" Margin="10,28,0,0" VerticalAlignment="Top" Width="125"/>
                    <Label Name="LabelDomainName" Content="DomainName" HorizontalAlignment="Left" Height="28" Margin="10,61,0,0" VerticalAlignment="Top" Width="125" RenderTransformOrigin="0.452,2.089"/>
                    <Label Name="LabelDnsServerForwarders" Content="DnsServerForwarders" HorizontalAlignment="Left" Height="28" Margin="10,94,0,0" VerticalAlignment="Top" Width="125"/>
                    <TextBox Name="TextBoxDomainNetbiosName"  HorizontalAlignment="Left" Height="22" Margin="180,28,0,0" Text="ClearMedia" VerticalAlignment="Top" Width="180" TabIndex="1" IsTabStop="False" RenderTransformOrigin="0.673,0.523"/>
                    <TextBox Name="TextBoxDomainDnsName" HorizontalAlignment="Left" Height="22" Margin="180,61,0,0" Text="ClearMedia.cloud" VerticalAlignment="Top" Width="180" RenderTransformOrigin="0.462,0.455"/>
                    <TextBox Name="TextBoxDnsServerForwarders" HorizontalAlignment="Left" Height="22" Margin="180,94,0,0" Text="195.238.2.21,195.238.2.22,8.8.8.8" VerticalAlignment="Top" Width="180"/>
                    <ScrollViewer VerticalScrollBarVisibility="Auto" Margin="2,250,0,0" Height="380" Width="1256"  HorizontalScrollBarVisibility="Disabled">
                    <TextBlock Name="TextBlockOutBox1" Text="" Foreground="WHITE" Background="#FF22206F" />
                    </ScrollViewer>
                    <Button Name="ButtonStart1" Content="START"  HorizontalAlignment="Left" Margin="950,28,0,0" VerticalAlignment="Top" Width="250" Height="150" Foreground="Blue" FontWeight="Bold" FontSize="50" Background="Red" Visibility="Visible" />
                    <Button Name="ButtonReboot1" Content="REBOOT"  HorizontalAlignment="Left" Margin="950,28,0,0" VerticalAlignment="Top" Width="250" Height="150" Foreground="Blue" FontWeight="Bold" FontSize="50" Background="Red" Visibility="Hidden"  />
                     <StatusBar Name="StatusBarStatus1" HorizontalAlignment="Left" Height="24" Margin="2,670,0,0" VerticalAlignment="Top" Width="1256" Background="#FFD6D2B0" >
                        <Label Name="LabelStatus1" Content="In Progress ...." Height="25" FontSize="12" VerticalAlignment="Center" HorizontalAlignment="Center"  Visibility="Hidden" />
                        <ProgressBar Name="ProgressBarProgress1" Width="1150" Height="15" Value="1" Visibility="Hidden" />
                    </StatusBar>
                </Grid>
            </TabItem>
            <TabItem Name="TabItemCreateOU" Header="Create OU" Margin="64,0,-120,0">
                <Grid Background="#FFE5E5E5">
                    <Label Name="LabelManagedOuName" Content="ManagedOuName" HorizontalAlignment="Left" Height="28" Margin="10,28,0,0" VerticalAlignment="Top" Width="165"/>
                    <Label Name="LabelClearmediaAdminUserName" Content="ClearmediaAdminUserName" HorizontalAlignment="Left" Height="28" Margin="10,61,0,0" VerticalAlignment="Top" Width="165" RenderTransformOrigin="0.452,2.089"/>
                    <Label Name="LabelClearmediaAdminPassword" Content="ClearmediaAdminPassword" HorizontalAlignment="Left" Height="28" Margin="10,94,0,0" VerticalAlignment="Top" Width="165"/>
                    <TextBox Name="TextBoxManagedOuName"  HorizontalAlignment="Left" Height="22" Margin="180,28,0,0" Text="SME" VerticalAlignment="Top" Width="180" TabIndex="1" IsTabStop="False" RenderTransformOrigin="0.673,0.523"/>
                    <TextBox Name="TextBoxClearmediaAdminUserName" HorizontalAlignment="Left" Height="22" Margin="180,61,0,0" Text="ClearmediaAdmin" VerticalAlignment="Top" Width="180" RenderTransformOrigin="0.462,0.455"/>
                    <TextBox Name="TextBoxClearmediaAdminPassword" HorizontalAlignment="Left" Height="22" Margin="180,94,0,0" Text="*********" VerticalAlignment="Top" Width="180"/>
                    <ScrollViewer VerticalScrollBarVisibility="Auto" Margin="2,250,0,0" Height="380" Width="1256"  HorizontalScrollBarVisibility="Disabled">
                    <TextBlock Name="TextBlockOutBox2" Text="" Foreground="WHITE" Background="#FF22206F" />
                    </ScrollViewer>
                    <Button Name="ButtonStart2" Content="START"  HorizontalAlignment="Left" Margin="950,28,0,0" VerticalAlignment="Top" Width="250" Height="150" Foreground="Blue" FontWeight="Bold" FontSize="50" Background="Red" Visibility="Visible" />
                    <Button Name="ButtonReboot2" Content="REBOOT"  HorizontalAlignment="Left" Margin="950,28,0,0" VerticalAlignment="Top" Width="250" Height="150" Foreground="Blue" FontWeight="Bold" FontSize="50" Background="Red" Visibility="Hidden"  />
                     <StatusBar Name="StatusBarStatus2" HorizontalAlignment="Left" Height="24" Margin="2,670,0,0" VerticalAlignment="Top" Width="1256" Background="#FFD6D2B0" >
                        <Label Name="LabelStatus2" Content="In Progress ...." Height="25" FontSize="12" VerticalAlignment="Center" HorizontalAlignment="Center"  Visibility="Hidden" />
                        <ProgressBar Name="ProgressBarProgress2" Width="1150" Height="15" Value="1" Visibility="Hidden" />
                    </StatusBar>
                </Grid>
            </TabItem>
            <TabItem Name="TabItemDeployRDS" Header="Deploy RDS" Margin="124,0,-180,0">
                <Grid Background="#FFE5E5E5">
                    <Label Name="LabelRdsServer" Content="RDS Server" HorizontalAlignment="Left" Height="28" Margin="10,28,0,0" VerticalAlignment="Top" Width="165"/>
                    <TextBox Name="TextBoxRdsServer"  HorizontalAlignment="Left" Height="22" Margin="180,28,0,0" Text="RDS" VerticalAlignment="Top" Width="180" TabIndex="1" IsTabStop="False" RenderTransformOrigin="0.673,0.523"/>
                    <ScrollViewer VerticalScrollBarVisibility="Auto" Margin="2,250,0,0" Height="380" Width="1256"  HorizontalScrollBarVisibility="Disabled">
                    <TextBlock Name="TextBlockOutBox3" Text="" Foreground="WHITE" Background="#FF22206F" />
                    </ScrollViewer>
                    <Button Name="ButtonStart3" Content="START" HorizontalAlignment="Left" Margin="950,28,0,0" VerticalAlignment="Top" Width="250" Height="150" Foreground="Blue" FontWeight="Bold" FontSize="50" Background="Red"  Visibility="Visible" />
                    <Button Name="ButtonReboot3" Content="REBOOT"  HorizontalAlignment="Left" Margin="950,28,0,0" VerticalAlignment="Top" Width="250" Height="150" Foreground="Blue" FontWeight="Bold" FontSize="50" Background="Red" Visibility="Hidden"  />
                     <StatusBar Name="StatusBarStatus3" HorizontalAlignment="Left" Height="24" Margin="2,670,0,0" VerticalAlignment="Top" Width="1256" Background="#FFD6D2B0" >
                        <Label Name="LabelStatus3" Content="In Progress ...." Height="25" FontSize="12" VerticalAlignment="Center" HorizontalAlignment="Center"  Visibility="Hidden" />
                        <ProgressBar Name="ProgressBarProgress3" Width="1150" Height="15" Value="1" Visibility="Hidden" />
                    </StatusBar>
                </Grid>
            </TabItem>
            <TabItem Name="TabItemDelployGPO" Header="Deploy Standard GPO" Margin="184,0,-240,0">
                <Grid Background="#FFE5E5E5">
                    <CheckBox Name="checkBox1" Content="Copy ADM(X) Files to Local ADM(X) Store" HorizontalAlignment="Left" Margin="12,12,0,0" VerticalAlignment="Top" IsChecked="True"/>
                    <Label Name="LabelTemplateSourcePath" Content="Template Source Path" Margin="50,32,0,0" Height="28" HorizontalAlignment="Left" VerticalAlignment="Top" Width="150" />
                    <TextBox Name="TextBoxTemplateSourcePath" Margin="180,36,0,0" Text="C:\Install\GPO\Templates" Height="20" HorizontalAlignment="Left" VerticalAlignment="Top" Width="200"/>
                    <Label Name="LabelRdsOuPath" Content="RDS OU Path" Margin="7,80,0,0" Height="28" HorizontalAlignment="Left" VerticalAlignment="Top" Width="150" />
                    <TextBox Name="TextBoxRdsOuPath" Margin="90,84,0,0" Text="OU=RDS,OU=Servers,OU=SME,DC=ClearMedia,DC=cloud" Height="20" HorizontalAlignment="Left" VerticalAlignment="Top" Width="320"/>
                    <Label Name="LabelUsersOuPath" Content="Users OU Path" Margin="435,80,0,0" Height="28" HorizontalAlignment="Left" VerticalAlignment="Top" Width="150" />
                    <TextBox Name="TextBoxUsersOuPath" Margin="560,84,0,0" Text="OU=Users,OU=SME,DC=ClearMedia,DC=cloud" Height="20" HorizontalAlignment="Left" VerticalAlignment="Top" Width="265"/>

                    <CheckBox Name="checkBox2" Content="StandardRdsServerPolicy" HorizontalAlignment="Left" Margin="12,115,0,0" VerticalAlignment="Top" IsChecked="True"/>
                    <CheckBox Name="checkBox3" Content="StandardServerWindowsUpdate" HorizontalAlignment="Left" Margin="12,135,0,0" VerticalAlignment="Top" IsChecked="True"/>
                    <CheckBox Name="checkBox4" Content="StandardUserPolicy" HorizontalAlignment="Left" Margin="440,115,0,0" VerticalAlignment="Top" IsChecked="True"/>
                    <CheckBox Name="checkBox5" Content="StandardHardwareAccelerationUserPolicy" HorizontalAlignment="Left" Margin="440,135,0,0" VerticalAlignment="Top" IsChecked="True"/>
                    <CheckBox Name="checkBox6" Content="StandardO365UserPolicy" HorizontalAlignment="Left" Margin="440,155,0,0" VerticalAlignment="Top" IsChecked="True"/>
                    <CheckBox Name="checkBox7" Content="StandardOutlookUserPolicy" HorizontalAlignment="Left" Margin="440,175,0,0" VerticalAlignment="Top" IsChecked="True"/>
                    <Label Name="LabelOstPath" Content="Outlook OST Path" Margin="435,195,0,0" Height="28" HorizontalAlignment="Left" VerticalAlignment="Top" Width="150" />
                    <TextBox Name="TextBoxOstPath" Margin="560,199,0,0" Text='D:\Users\%USERNAME%' Height="20" HorizontalAlignment="Left" VerticalAlignment="Top" Width="265"/>

                    <ScrollViewer VerticalScrollBarVisibility="Auto" Margin="2,250,0,0" Height="380" Width="1256"  HorizontalScrollBarVisibility="Disabled">
                        <TextBlock Name="TextBlockOutBox4" Text="" Foreground="WHITE" Background="#FF22206F" />
                    </ScrollViewer>
                    <Button Name="ButtonStart4" Content="START" HorizontalAlignment="Left" Margin="950,28,0,0" VerticalAlignment="Top" Width="250" Height="150" Foreground="Blue" FontWeight="Bold" FontSize="50" Background="Red" Visibility="Visible" />
                    <Button Name="ButtonReboot4" Content="REBOOT" HorizontalAlignment="Left" Margin="950,28,0,0" VerticalAlignment="Top" Width="250" Height="150" Foreground="Blue" FontWeight="Bold" FontSize="50" Background="Red" Visibility="Hidden"  />
                    <StatusBar Name="StatusBarStatus4" HorizontalAlignment="Left" Height="24" Margin="2,670,0,0" VerticalAlignment="Top" Width="1256" Background="#FFD6D2B0" >
                        <Label Name="LabelStatus4" Content="In Progress ...." Height="25" FontSize="12" VerticalAlignment="Center" HorizontalAlignment="Center"  Visibility="Hidden" />
                        <ProgressBar Name="ProgressBarProgress4" Width="1150" Height="15" Value="1" Visibility="Hidden" />
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
			$DnsForwarder.Split(',') | ForEach-Object {
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
            $Error.Clear()
            $ErrorList = @()
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
                    New-ADOrganizationalUnit -Name $_ -Path $($OUs.$_) -ErrorAction Stop
                    If ( $error ) {
                        $ErrorList += "New-ADOrganizationalUnit -Name $_ -Path $($OUs.$_) -ErrorAction Stop"
                        $ErrorList += $error[0].Exception.Message.ToString()
                        $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                        $Error.Clear()
                        }
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
                    New-ADGroup -Name $Group -GroupScope 'Global' -Path $($Groups.$Group) -ErrorAction Stop
                    If ( $error ) {
                        $ErrorList += "New-ADGroup -Name $Group -GroupScope 'Global' -Path $($Groups.$Group) -ErrorAction Stop"
                        $ErrorList += $error[0].Exception.Message.ToString()
                        $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                        $Error.Clear()
                        }
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
            New-ADUser @NewUserParams -ErrorAction Stop
            If ( $error ) {
                $ErrorList += "New-ADUser @NewUserParams -ErrorAction Stop"
                $ErrorList += $error[0].Exception.Message.ToString()
                $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                $Error.Clear()
                }
            # Add ClearMedia User to Admin Groups
            ('Domain Admins','Enterprise Admins') | ForEach-Object { 
                    $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox2.AddText("Adding ClearMedia User to $_ `n") } ) 
                    $I += 4
                    $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress2.Value = $I } )
                    Add-ADGroupMember -Identity "CN=$_,CN=Users,$ADRootDSE" -Members "CN=$($NewUserParams.Name),$($NewUserParams.Path)"  -ErrorAction Stop
                    If ( $error ) {
                        $ErrorList += "Add-ADGroupMember -Identity CN=$_,CN=Users,$ADRootDSE -Members CN=$($NewUserParams.Name),$($NewUserParams.Path)  -ErrorAction Stop"
                        $ErrorList += $error[0].Exception.Message.ToString()
                        $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                        $Error.Clear()
                        }
                    }
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress2.Visibility = "Hidden" } )
            If ( $ErrorList ) 
                { 
                $ErrorList | Out-File -FilePath 'c:\install\PushTheButtonError.log' -Append -Force
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.LabelStatus2.Content = "Installation Finished with ERRORS$(' .'*25)$(' '*20)Please consult ErrorLog" } )
                }
                Else
                { $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.LabelStatus2.Content = "Installation Finished$(' .'*45)$(' '*20)" } ) }
            }
        $PSinstance = [powershell]::Create().AddScript($Code3)
        $PSinstance.Runspace = $Runspace
        $job = $PSinstance.BeginInvoke()
        
    }
	
		Function Update-OutBox3 {
		Param($syncHash,$RdsServer)
        $Runspace = [runspacefactory]::CreateRunspace()
        $Runspace.ApartmentState = "STA"
        $Runspace.ThreadOptions = "ReuseThread"
        $Runspace.Open()
        $Runspace.SessionStateProxy.SetVariable("syncHash",$syncHash)
		$Runspace.SessionStateProxy.SetVariable("RdsServer",$RdsServer)
        $code4 = {
            [INT]$I = 0
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress3.Value = $I } )
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox3.AddText("Setting Related RDS Services `n") } )
			$Job = Invoke-Command -ComputerName $RdsServer -AsJob -JobName 'RdsServices' -ScriptBlock {
				$Services = @{
					'Audiosrv' =  'Auto'
					'SCardSvr' = 'Auto'
					'WSearch'  = 'Auto'
					}
				$Services.keys | ForEach-Object { Set-Service -Name $_ -StartupType $($Services.$_) }
				}
            While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress3.Value = $I } ) }
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox3.AddText("Installing RDS Related Roles & Features `n") } )
			$Job = Invoke-Command -ComputerName $RdsServer -AsJob -JobName 'RdsRoles' -ScriptBlock {
				$Roles = [ordered]@{
					'Windows TIFF IFilter' =  'Windows-TIFF-IFilter'
					'Remote Desktop Services' = 'RDS-RD-Server'
					'Group Policy Management' = 'GPMC'
					'Remote Server Administration Tools' = ('RSAT-AD-Tools','RSAT-DNS-Server','RSAT-RDS-Licensing-Diagnosis-UI','RDS-Licensing-UI')
					}
				$Roles.Values | ForEach-Object { Install-WindowsFeature -Name $_ }
				}
            While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress3.Value = $I } ) }
            Get-Job | Select-Object -Property Name, State, Command, @{Name='Error';Expression={ $_.ChildJobs[0].JobStateInfo.Reason }} | Export-Csv -Path 'c:\install\Jobs.csv' -NoTypeInformation -Force
            [Boolean]$JobError = Get-Job | Where-Object { $_.State -eq 'Failed' } | ForEach-Object { $_.count -gt 0 }
            If ( $JobError ) 
                {
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress3.Visibility = "Hidden" } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.LabelStatus3.Content = "Installation Finished with ERRORS$(' .'*25)$(' '*20)Please consult Jobs.csv" } )
                }
                Else 
                {
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress3.Visibility = "Hidden" } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.LabelStatus3.Content = "Installation Finished$(' .'*45)$(' '*20)PLEASE REBOOT" } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ButtonStart3.Visibility = "Hidden" } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ButtonReboot3.Visibility = "Visible"  } )
                }
        }
        $PSinstance = [powershell]::Create().AddScript($Code4)
        $PSinstance.Runspace = $Runspace
        $job = $PSinstance.BeginInvoke()
        
    }
		Function ButtonReboot3 {
		Param($syncHash,$RdsServer)
        $Runspace = [runspacefactory]::CreateRunspace()
        $Runspace.ApartmentState = "STA"
        $Runspace.ThreadOptions = "ReuseThread"
        $Runspace.Open()
        $Runspace.SessionStateProxy.SetVariable("syncHash",$syncHash)
		$Runspace.SessionStateProxy.SetVariable("RdsServer",$RdsServer)
        $code5 = {
            [INT]$I = 0
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress1.Value = $I } )
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox3.AddText("Rebooting $RdsServer `n") } )
			$Job = Invoke-Command -ComputerName $RdsServer -AsJob -JobName 'Reboot RDS' -ScriptBlock {
				Restart-Computer -Force
				}
            While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress3.Value = $I } ) }
            [Boolean]$JobError = Get-Job | Where-Object { $_.State -eq 'Failed' } | ForEach-Object { $_.count -gt 0 }
            If ( $JobError ) 
                {
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress3.Visibility = "Hidden" } )
				$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ButtonReboot3.Visibility = "Hidden"  } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.LabelStatus3.Content = "Installation Finished with ERRORS$(' .'*25)$(' '*20)Please consult Jobs.csv" } )
                }
                Else 
                {
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress3.Visibility = "Hidden" } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.LabelStatus3.Content = "Reboot Initiated$(' .'*45)" } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ButtonStart3.Visibility = "Hidden" } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ButtonReboot3.Visibility = "Hidden"  } )
                }
			
        }
        $PSinstance = [powershell]::Create().AddScript($Code5)
        $PSinstance.Runspace = $Runspace
        $job = $PSinstance.BeginInvoke()
        
    }
	Function Update-OutBox4 {
		Param($syncHash,$TemplateSourcePath,$RdsOuPath,$UsersOuPath,$OstPath,$CheckBox1,$CheckBox2,$CheckBox3,$CheckBox4,$CheckBox5,$CheckBox6,$CheckBox7)
        $Runspace = [runspacefactory]::CreateRunspace()
        $Runspace.ApartmentState = "STA"
        $Runspace.ThreadOptions = "ReuseThread"
        $Runspace.Open()
        $Runspace.SessionStateProxy.SetVariable("syncHash",$syncHash)
		$Runspace.SessionStateProxy.SetVariable("TemplateSourcePath",$TemplateSourcePath)
		$Runspace.SessionStateProxy.SetVariable("RdsOuPath",$RdsOuPath)
		$Runspace.SessionStateProxy.SetVariable("UsersOuPath",$UsersOuPath)
		$Runspace.SessionStateProxy.SetVariable("OstPath",$OstPath)
		$Runspace.SessionStateProxy.SetVariable("CheckBox1",$CheckBox1)
		$Runspace.SessionStateProxy.SetVariable("CheckBox2",$CheckBox2)
		$Runspace.SessionStateProxy.SetVariable("CheckBox3",$CheckBox3)
		$Runspace.SessionStateProxy.SetVariable("CheckBox4",$CheckBox4)
		$Runspace.SessionStateProxy.SetVariable("CheckBox5",$CheckBox5)
		$Runspace.SessionStateProxy.SetVariable("CheckBox6",$CheckBox6)
		$Runspace.SessionStateProxy.SetVariable("CheckBox7",$CheckBox7)
        $code4 = {
            $Error.Clear()
            $ErrorList = @()
            [INT]$I = 0
			# Get ADRootDSE
			$ADRootDSE = $(($env:USERDNSDOMAIN.Replace('.',',DC=')).Insert(0,'DC='))
            # Copy ADM(X) Files to Local ADM(X) Store
    if ( $CheckBox1 ) {			
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox4.AddText("Copying ADM(X) Files to Local ADM(X) Store `n") } ) 
            $I += 4 ; If ( $I -ge 100 ) { $I = 1 }
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress4.Value = $I } )
            Copy-Item -Path "$TemplateSourcePath\admx\*" -Destination 'C:\Windows\PolicyDefinitions' -ErrorAction Continue -Force
			If ( $error ) {
                        $ErrorList += "Copy-Item -Path $TemplateSourcePath\admx\* -Destination 'C:\Windows\PolicyDefinitions' -ErrorAction Stop -Force"
                        $ErrorList += $error[0].Exception.Message.ToString()
                        $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                        $Error.Clear()
                        }
            $I += 4 ; If ( $I -ge 100 ) { $I = 1 }
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress4.Value = $I } )
            Copy-Item -Path "$TemplateSourcePath\admx\en-US\*" -Destination 'C:\Windows\PolicyDefinitions\en-US' -ErrorAction Continue -Force
			If ( $error ) {
                        $ErrorList += "Copy-Item -Path $TemplateSourcePath\admx\en-US\* -Destination 'C:\Windows\PolicyDefinitions' -ErrorAction Stop -Force"
                        $ErrorList += $error[0].Exception.Message.ToString()
                        $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                        $Error.Clear()
                        }
            $I += 4 ; If ( $I -ge 100 ) { $I = 1 }
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress4.Value = $I } )
            Copy-Item -Path "$TemplateSourcePath\admx\fr-FR\*" -Destination 'C:\Windows\PolicyDefinitions\fr-FR' -ErrorAction Continue -Force
			If ( $error ) {
                        $ErrorList += "Copy-Item -Path $TemplateSourcePath\admx\fr-FR\* -Destination 'C:\Windows\PolicyDefinitions' -ErrorAction Stop -Force"
                        $ErrorList += $error[0].Exception.Message.ToString()
                        $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                        $Error.Clear()
                        }
			# Create Central ADM(X) Store
			# Copy ADM(X) files to Central ADM(X) Store
			[STRING]$PdcName = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().PdcRoleOwner.Name
			[STRING]$DomainName = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().Name
			$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox4.AddText("Creating Central ADM(X) Store `n") } ) 
            $I += 4 ; If ( $I -ge 100 ) { $I = 1 }
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress4.Value = $I } )
			New-Item -Path "\\$PdcName\SYSVOL\$DomainName\Policies\PolicyDefinitions" -ItemType Directory -ErrorAction Continue -Force
			If ( $error ) {
                        $ErrorList += "New-Item -Path \\$PdcName\SYSVOL\$DomainName\Policies\PolicyDefinitions -ItemType Directory -ErrorAction Stop -Force"
                        $ErrorList += $error[0].Exception.Message.ToString()
                        $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                        $Error.Clear()
                        }
			$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox4.AddText("Copying ADM(X) files to Central ADM(X) Store `n") } ) 
            $I += 4 ; If ( $I -ge 100 ) { $I = 1 }
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress4.Value = $I } )
			Copy-Item -Path 'C:\Windows\PolicyDefinitions\*' -Destination "\\$PdcName\SYSVOL\$DomainName\Policies\PolicyDefinitions" -ErrorAction Continue -Force
			If ( $error ) {
                        $ErrorList += "Copy-Item -Path 'C:\Windows\PolicyDefinitions\*' -Destination \\$PdcName\SYSVOL\$DomainName\Policies\PolicyDefinitions -ErrorAction Stop -Force"
                        $ErrorList += $error[0].Exception.Message.ToString()
                        $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                        $Error.Clear()
                        }
            $I += 4 ; If ( $I -ge 100 ) { $I = 1 }
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress4.Value = $I } )
			Copy-Item -Path 'C:\Windows\PolicyDefinitions\en-US\*' -Destination "\\$PdcName\SYSVOL\$DomainName\Policies\PolicyDefinitions\en-US" -ErrorAction Continue  -Force
			If ( $error ) {
                        $ErrorList += "Copy-Item -Path 'C:\Windows\PolicyDefinitions\en-US\*' -Destination \\$PdcName\SYSVOL\$DomainName\Policies\PolicyDefinitions\en-US -ErrorAction Stop  -Force"
                        $ErrorList += $error[0].Exception.Message.ToString()
                        $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                        $Error.Clear()
                        }
            }
	# Create and Assemble Computer GPOs
	# Link Computer GPOs to OU RDS
	$StandardRdsServerPolicy = (
				'HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer,NoDriveTypeAutoRun,Dword,255',
				'HKLM\Software\Policies\Microsoft\Windows\Personalization,NoChangingLockScreen,Dword,1',
				'HKLM\Software\Policies\Microsoft\Windows\Session Manager\Quota System,EnableCpuQuota,Dword,0',
				'HKLM\Software\Policies\Microsoft\Windows NT\Terminal Services,Shadow,Dword,2',
				'HKLM\Software\Policies\Microsoft\Windows NT\Terminal Services,LicensingMode,Dword,4',
				'HKLM\Software\Policies\Microsoft\Windows NT\Terminal Services,fResetBroken,Dword,1',
				'HKLM\Software\Policies\Microsoft\Windows NT\Terminal Services,LicenseServers,String,192.168.13.100',
				'HKLM\Software\Policies\Microsoft\Windows NT\Terminal Services,MaxDisconnectionTime,Dword,28800000'
				)
	$StandardServerWindowsUpdate = (
				'HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate,WUServer,String,http://update.clearmedia.be',
				'HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate,WUStatusServer,String,http://update.clearmedia.be',
				'HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate,SetActiveHours,Dword,1',
				'HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate,ActiveHoursStart,Dword,22',
				'HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate,ActiveHoursEnd,Dword,6',
				'HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU,AUOptions,Dword,3',
				'HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU,UseWUServer,Dword,1',
				'HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU,NoAutoRebootWithLoggedOnUsers,Dword,1'
				)
	# Create and Assemble User GPOs
	# Link User GPOs to OU Users
	$StandardUserPolicy = (
				'HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer,NoDrives,Dword,4',
				'HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer,NoHardwareTab,Dword,1',
				'HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer,NoInplaceSharing,Dword,1',
				'HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\WindowsUpdate,DisableWindowsUpdateAccess,Dword,1',
				'HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\WindowsUpdate,DisableWindowsUpdateAccessMode,Dword,0',
				'HKCU\Software\Policies\Microsoft\Internet Explorer\SQM,DisableCustomerImprovementProgram,Dword,0',
				'HKCU\Software\Policies\Microsoft\Messenger\Client,PreventAutoRun,Dword,1',
				'HKCU\Software\Policies\Microsoft\Messenger\Client,PreventRun,Dword,1',
				'HKCU\Software\Policies\Microsoft\Windows\Control Panel\Desktop,ScreenSaveActive,String,0',
				'HKCU\Software\Policies\Microsoft\Windows Mail,ManualLaunchAllowed,Dword,0',
				'HKCU\Software\Policies\Microsoft\Windows Mail,DisableCommunities,Dword,1'
				)
	$StandardHardwareAccelerationUserPolicy = (
				'HKCU\Software\Policies\Google\Chrome,BackgroundModeEnabled,Dword,0',
				'HKCU\Software\Policies\Google\Chrome,HardwareAccelerationModeEnabled,Dword,0',
				'HKCU\SOFTWARE\Microsoft\Internet Explorer\Main,UseSWRender,Dword,1',
				'HKCU\Software\Adobe\Acrobat Reader\DC\3D,b3DAllowSelect,Dword,0',
				'HKCU\Software\Microsoft\Office\16.0\Common\Graphics,DisableHardwareAcceleration,Dword,1'
				)
	$StandardO365UserPolicy = (
				'HKCU\Software\policies\microsoft\office\16.0\common,qmenable,Dword,0',
				'HKCU\Software\policies\microsoft\office\16.0\common,sendcustomerdata,Dword,0',
				'HKCU\Software\policies\microsoft\office\16.0\common,updatereliabilitydata,Dword,0',
				'HKCU\Software\policies\microsoft\office\16.0\common\feedback,enabled,Dword,0',
				'HKCU\Software\policies\microsoft\office\16.0\common\general,disablebackgrounds,Dword,1',
				'HKCU\Software\policies\microsoft\office\16.0\common\general,shownfirstrunoptin,Dword,1',
				'HKCU\Software\policies\microsoft\office\16.0\common\graphics,disableanimations,Dword,1',
				'HKCU\Software\policies\microsoft\office\16.0\common\graphics,disablehardwareacceleration,Dword,1',
				'HKCU\Software\policies\microsoft\office\16.0\excel\options,autorecovertime,Dword,15',
				'HKCU\Software\policies\microsoft\office\16.0\excel\options,autorecoverenabled,Dword,1',
				'HKCU\Software\policies\microsoft\office\16.0\firstrun,disablemovie,Dword,1',
				'HKCU\Software\policies\microsoft\office\16.0\firstrun,bootedrtm,Dword,1',
				'HKCU\Software\policies\microsoft\office\16.0\powerpoint\options,saveautorecoveryinfo,Dword,1',
				'HKCU\Software\policies\microsoft\office\16.0\powerpoint\options,frequencytosaveautorecoveryinfo,Dword,15',
				'HKCU\Software\policies\microsoft\office\16.0\powerpoint\options,pathtoautorecoveryinfo,ExpandString,%USERPROFILE%\Application Data\Microsoft\PowerPoint',
				'HKCU\Software\policies\microsoft\office\16.0\publisher\preferences,autorecoversaveinterval,String,15',
				'HKCU\Software\policies\microsoft\office\16.0\publisher\preferences,backgroundsave,String,1',
				'HKCU\Software\policies\microsoft\office\16.0\word\options,autosaveinterval,Dword,15'
				)
	$StandardOutlookUserPolicy = (
				'HKCU\Software\policies\microsoft\office\16.0\outlook\cached mode,cachedexchangemode,Dword,2',
				'HKCU\Software\policies\microsoft\office\16.0\outlook\cached mode,syncwindowsetting,Dword,0',
				'HKCU\Software\policies\microsoft\office\16.0\outlook\cached mode,syncwindowsettingdays,Dword,14',
				'HKCU\Software\policies\microsoft\office\16.0\outlook\cached mode,enable,Dword,1',
				"HKCU\Software\policies\microsoft\office\16.0\outlook,forceostpath,ExpandString,$OstPath",
				"HKCU\Software\policies\microsoft\office\16.0\outlook,forcepstpath,ExpandString,$OstPath"
				)
    if ( $CheckBox2 ) {
			$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox4.AddText("Creating StandardRdsServerPolicy Policy `n") } ) 
            $I += 4 ; If ( $I -ge 100 ) { $I = 1 }
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress4.Value = $I } )
			$GpoName = 'StandardRdsServerPolicy'
			New-GPO -Name $GpoName -ErrorAction Continue
			If ( $error ) {
                        $ErrorList += "New-GPO -Name $GpoName -ErrorAction Stop"
                        $ErrorList += $error[0].Exception.Message.ToString()
                        $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                        $Error.Clear()
                        }
			$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox4.AddText("Linking StandardRdsServerPolicy Policy to $RdsOuPath `n") } ) 
            $I += 4 ; If ( $I -ge 100 ) { $I = 1 }
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress4.Value = $I } )
			New-GPLink -Name $GpoName -Target $RdsOuPath -ErrorAction Continue
			If ( $error ) {
                        $ErrorList += "New-GPLink -Name $GpoName -Target $RdsOuPath -ErrorAction Stop"
                        $ErrorList += $error[0].Exception.Message.ToString()
                        $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                        $Error.Clear()
                        }
			$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox4.AddText("Injecting StandardRdsServerPolicy Policy Keys `n") } ) 
            $I += 4 ; If ( $I -ge 100 ) { $I = 1 }
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress4.Value = $I } )
			$StandardRdsServerPolicy | ForEach-Object {
                $I += 4 ; If ( $I -ge 100 ) { $I = 1 }
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress4.Value = $I } )
                $Table = $_.Split(',')
				If ( $Table[2] -eq 'Dword' ) { [INT]$Value = $Table[3] } Else { [STRING]$Value = $Table[3] }
				Set-GPRegistryValue -Name "$GpoName" -Key $Table[0] -ValueName $Table[1] -Type $Table[2] -Value $Value  -ErrorAction Continue
			    If ( $error ) {
                        $ErrorList += "Set-GPRegistryValue -Name $GpoName -Key $Table[0] -ValueName $Table[1] -Type $Table[2] -Value $Value  -ErrorAction Stop"
                        $ErrorList += $error[0].Exception.Message.ToString()
                        $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                        $Error.Clear()
                        }
				}
            }
    if ( $CheckBox3 ) {
			$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox4.AddText("Creating StandardServerWindowsUpdate Policy `n") } ) 
            $I += 4 ; If ( $I -ge 100 ) { $I = 1 }
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress4.Value = $I } )
			$GpoName = 'StandardServerWindowsUpdate'
			New-GPO -Name $GpoName -ErrorAction Ignore
			If ( $error ) {
                        $ErrorList += "New-GPO -Name $GpoName -ErrorAction Stop"
                        $ErrorList += $error[0].Exception.Message.ToString()
                        $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                        $Error.Clear()
                        }
			$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox4.AddText("Linking StandardServerWindowsUpdate Policy to $RdsOuPath `n") } ) 
            $I += 4 ; If ( $I -ge 100 ) { $I = 1 }
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress4.Value = $I } )
			New-GPLink -Name $GpoName -Target $RdsOuPath -ErrorAction Continue
			If ( $error ) {
                        $ErrorList += "New-GPLink -Name $GpoName -Target $RdsOuPath -ErrorAction Stop"
                        $ErrorList += $error[0].Exception.Message.ToString()
                        $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                        $Error.Clear()
                        }
			$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox4.AddText("Injecting StandardServerWindowsUpdate Policy Keys `n") } ) 
            $I += 4 ; If ( $I -ge 100 ) { $I = 1 }
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress4.Value = $I } )
			$StandardServerWindowsUpdate | ForEach-Object {
                $I += 4 ; If ( $I -ge 100 ) { $I = 1 }
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress4.Value = $I } )
				$Table = $_.Split(',')
				If ( $Table[2] -eq 'Dword' ) { [INT]$Value = $Table[3] } Else { [STRING]$Value = $Table[3] }
				Set-GPRegistryValue -Name "$GpoName" -Key $Table[0] -ValueName $Table[1] -Type $Table[2] -Value $Value  -ErrorAction Continue
			    If ( $error ) {
                        $ErrorList += "Set-GPRegistryValue -Name $GpoName -Key $Table[0] -ValueName $Table[1] -Type $Table[2] -Value $Value  -ErrorAction Stop"
                        $ErrorList += $error[0].Exception.Message.ToString()
                        $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                        $Error.Clear()
                        }
				}
            }
    if ( $CheckBox4 ) {
			$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox4.AddText("Creating StandardUserPolicy Policy `n") } ) 
            $I += 4 ; If ( $I -ge 100 ) { $I = 1 }
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress4.Value = $I } )
			$GpoName = 'StandardUserPolicy'
			New-GPO -Name $GpoName -ErrorAction Ignore
			If ( $error ) {
                        $ErrorList += "New-GPO -Name $GpoName -ErrorAction Stop"
                        $ErrorList += $error[0].Exception.Message.ToString()
                        $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                        $Error.Clear()
                        }
			$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox4.AddText("Linking $GpoName  Policy to $UsersOuPath `n") } ) 
            $I += 4 ; If ( $I -ge 100 ) { $I = 1 }
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress4.Value = $I } )
			New-GPLink -Name $GpoName -Target $UsersOuPath -ErrorAction Continue
			If ( $error ) {
                        $ErrorList += "New-GPLink -Name $GpoName -Target $UsersOuPath -ErrorAction Stop"
                        $ErrorList += $error[0].Exception.Message.ToString()
                        $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                        $Error.Clear()
                        }
			$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox4.AddText("Injecting $GpoName  Policy Keys `n") } ) 
            $I += 4 ; If ( $I -ge 100 ) { $I = 1 }
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress4.Value = $I } )
			$StandardUserPolicy | ForEach-Object {
                $I += 4 ; If ( $I -ge 100 ) { $I = 1 }
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress4.Value = $I } )
				$Table = $_.Split(',')
				If ( $Table[2] -eq 'Dword' ) { [INT]$Value = $Table[3] } Else { [STRING]$Value = $Table[3] }
				Set-GPRegistryValue -Name "$GpoName" -Key $Table[0] -ValueName $Table[1] -Type $Table[2] -Value $Value  -ErrorAction Continue
			    If ( $error ) {
                        $ErrorList += "Set-GPRegistryValue -Name $GpoName -Key $Table[0] -ValueName $Table[1] -Type $Table[2] -Value $Value  -ErrorAction Stop"
                        $ErrorList += $error[0].Exception.Message.ToString()
                        $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                        $Error.Clear()
                        }
				}
            }
    if ( $CheckBox5 ) {
			$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox4.AddText("Creating StandardHardwareAccelerationUserPolicy Policy `n") } ) 
            $I += 4 ; If ( $I -ge 100 ) { $I = 1 }
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress4.Value = $I } )
			$GpoName = 'StandardHardwareAccelerationUserPolicy'
			New-GPO -Name $GpoName -ErrorAction Ignore
			If ( $error ) {
                        $ErrorList += "New-GPO -Name $GpoName -ErrorAction Stop"
                        $ErrorList += $error[0].Exception.Message.ToString()
                        $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                        $Error.Clear()
                        }
			$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox4.AddText("Linking $GpoName  Policy to $UsersOuPath `n") } ) 
            $I += 4 ; If ( $I -ge 100 ) { $I = 1 }
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress4.Value = $I } )
			New-GPLink -Name $GpoName -Target $UsersOuPath -ErrorAction Continue
			If ( $error ) {
                        $ErrorList += "New-GPLink -Name $GpoName -Target $UsersOuPath -ErrorAction Stop"
                        $ErrorList += $error[0].Exception.Message.ToString()
                        $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                        $Error.Clear()
                        }
			$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox4.AddText("Injecting $GpoName  Policy Keys `n") } ) 
            $I += 4 ; If ( $I -ge 100 ) { $I = 1 }
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress4.Value = $I } )
			$StandardHardwareAccelerationUserPolicy | ForEach-Object {
                $I += 4 ; If ( $I -ge 100 ) { $I = 1 }
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress4.Value = $I } )
				$Table = $_.Split(',')
				If ( $Table[2] -eq 'Dword' ) { [INT]$Value = $Table[3] } Else { [STRING]$Value = $Table[3] }
				Set-GPRegistryValue -Name "$GpoName" -Key $Table[0] -ValueName $Table[1] -Type $Table[2] -Value $Value  -ErrorAction Continue
			    If ( $error ) {
                        $ErrorList += "Set-GPRegistryValue -Name $GpoName -Key $Table[0] -ValueName $Table[1] -Type $Table[2] -Value $Value  -ErrorAction Stop"
                        $ErrorList += $error[0].Exception.Message.ToString()
                        $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                        $Error.Clear()
                        }
				}
            }
    if ( $CheckBox6 ) {
			$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox4.AddText("Creating StandardO365UserPolicy Policy `n") } ) 
            $I += 4 ; If ( $I -ge 100 ) { $I = 1 }
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress4.Value = $I } )
			$GpoName = 'StandardO365UserPolicy'
			New-GPO -Name $GpoName -ErrorAction Ignore
			If ( $error ) {
                        $ErrorList += "New-GPO -Name $GpoName -ErrorAction Stop"
                        $ErrorList += $error[0].Exception.Message.ToString()
                        $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                        $Error.Clear()
                        }
			$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox4.AddText("Linking $GpoName  Policy to $UsersOuPath `n") } ) 
            $I += 4 ; If ( $I -ge 100 ) { $I = 1 }
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress4.Value = $I } )
			New-GPLink -Name $GpoName -Target $UsersOuPath -ErrorAction Continue
			If ( $error ) {
                        $ErrorList += "New-GPLink -Name $GpoName -Target $UsersOuPath -ErrorAction Stop"
                        $ErrorList += $error[0].Exception.Message.ToString()
                        $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                        $Error.Clear()
                        }
			$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox4.AddText("Injecting $GpoName  Policy Keys `n") } ) 
            $I += 4 ; If ( $I -ge 100 ) { $I = 1 }
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress4.Value = $I } )
			$StandardO365UserPolicy | ForEach-Object {
                $I += 4 ; If ( $I -ge 100 ) { $I = 1 }
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress4.Value = $I } )
				$Table = $_.Split(',')
				If ( $Table[2] -eq 'Dword' ) { [INT]$Value = $Table[3] } Else { [STRING]$Value = $Table[3] }
				Set-GPRegistryValue -Name "$GpoName" -Key $Table[0] -ValueName $Table[1] -Type $Table[2] -Value $Value  -ErrorAction Continue
			    If ( $error ) {
                        $ErrorList += "Set-GPRegistryValue -Name $GpoName -Key $Table[0] -ValueName $Table[1] -Type $Table[2] -Value $Value  -ErrorAction Stop"
                        $ErrorList += $error[0].Exception.Message.ToString()
                        $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                        $Error.Clear()
                        }
				}
            }
    if ( $CheckBox7 ) {
			$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox4.AddText("Creating StandardOutlookUserPolicy Policy `n") } ) 
            $I += 4 ; If ( $I -ge 100 ) { $I = 1 }
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress4.Value = $I } )
			$GpoName = 'StandardOutlookUserPolicy'
			New-GPO -Name $GpoName -ErrorAction Ignore
			If ( $error ) {
                        $ErrorList += "New-GPO -Name $GpoName -ErrorAction Stop"
                        $ErrorList += $error[0].Exception.Message.ToString()
                        $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                        $Error.Clear()
                        }
			$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox4.AddText("Linking $GpoName  Policy to $UsersOuPath `n") } ) 
            $I += 4 ; If ( $I -ge 100 ) { $I = 1 }
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress4.Value = $I } )
			New-GPLink -Name $GpoName -Target $UsersOuPath -ErrorAction Continue
			If ( $error ) {
                        $ErrorList += "New-GPLink -Name $GpoName -Target $UsersOuPath -ErrorAction Stop"
                        $ErrorList += $error[0].Exception.Message.ToString()
                        $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                        $Error.Clear()
                        }
			$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox4.AddText("Injecting $GpoName  Policy Keys `n") } ) 
            $I += 4 ; If ( $I -ge 100 ) { $I = 1 }
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress4.Value = $I } )
			$StandardOutlookUserPolicy | ForEach-Object {
                $I += 4 ; If ( $I -ge 100 ) { $I = 1 }
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress4.Value = $I } )
				$Table = $_.Split(',')
				If ( $Table[2] -eq 'Dword' ) { [INT]$Value = $Table[3] } Else { [STRING]$Value = $Table[3] }
				Set-GPRegistryValue -Name "$GpoName" -Key $Table[0] -ValueName $Table[1] -Type $Table[2] -Value $Value  -ErrorAction Continue
			    If ( $error ) {
                        $ErrorList += "Set-GPRegistryValue -Name $GpoName -Key $Table[0] -ValueName $Table[1] -Type $Table[2] -Value $Value  -ErrorAction Stop"
                        $ErrorList += $error[0].Exception.Message.ToString()
                        $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                        $Error.Clear()
                        }
				}
            }

            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgress4.Visibility = "Hidden" } )
            If ( $ErrorList ) 
                {
                (Get-Date).tostring('dd-MM-yyyy HH:mm:ss') | Out-File -FilePath 'c:\install\PushTheButtonError.log' -Append -Force
                $ErrorList | Out-File -FilePath 'c:\install\PushTheButtonError.log' -Append -Force
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.LabelStatus4.Content = "Installation Finished with ERRORS$(' .'*25)$(' '*20)Please consult ErrorLog" } )
                }
                Else
                { $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.LabelStatus4.Content = "Installation Finished$(' .'*45)$(' '*20)" } ) }
            }
        $PSinstance = [powershell]::Create().AddScript($Code4)
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
    $syncHash.ButtonStart3.Add_Click({
        $syncHash.ButtonStart3.IsEnabled = $False
        $syncHash.LabelStatus3.Visibility = "Visible"
        $syncHash.ProgressBarProgress3.Visibility = "Visible"
		Update-OutBox3 -syncHash $syncHash -RdsServer $syncHash.TextBoxRdsServer.Text
        })
    $syncHash.ButtonReboot3.Add_Click({
		ButtonReboot3 -syncHash $syncHash -RdsServer $syncHash.TextBoxRdsServer.Text
        })

    $syncHash.ButtonStart4.Add_Click({
		$syncHash.ButtonStart1.IsEnabled = $False
        $syncHash.ButtonStart2.IsEnabled = $False
		$syncHash.ButtonStart3.IsEnabled = $False
        $syncHash.LabelStatus4.Visibility = "Visible"
        $syncHash.ProgressBarProgress4.Visibility = "Visible"
		Update-OutBox4 -syncHash $syncHash -TemplateSourcePath $syncHash.TextBoxTemplateSourcePath.Text -RdsOuPath $SyncHash.TextBoxRdsOuPath.Text -UsersOuPath $SyncHash.TextBoxUsersOuPath.Text -OstPath $SyncHash.TextBoxOstPath.Text -CheckBox1 $SyncHash.CheckBox1.IsChecked -CheckBox2 $SyncHash.CheckBox2.IsChecked -CheckBox3 $SyncHash.CheckBox3.IsChecked -CheckBox4 $SyncHash.CheckBox4.IsChecked -CheckBox5 $SyncHash.CheckBox5.IsChecked -CheckBox6 $SyncHash.CheckBox6.IsChecked -CheckBox7 $SyncHash.CheckBox7.IsChecked
        #$SyncHash.host.ui.WriteVerboseLine($SyncHash.checkBox2.IsChecked)
        })

   $syncHash.Window.ShowDialog()
   $Runspace.Close()
   $Runspace.Dispose()
}


$PSinstance1 = [powershell]::Create().AddScript($Code1)
$PSinstance1.Runspace = $Runspace
$job = $PSinstance1.BeginInvoke()
