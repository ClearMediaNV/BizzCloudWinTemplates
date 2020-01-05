# Init History
If ( -Not (Test-Path -Path 'HKLM:\Software\ClearMedia') ) { New-Item -Path  'HKLM:\Software\ClearMedia' }
If ( -Not (Test-Path -Path 'HKLM:\Software\ClearMedia\PushTheButton') ) { New-Item -Path  'HKLM:\Software\ClearMedia\PushTheButton' }

# Check History
Try { $DeployDcStart = Get-ItemPropertyValue -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'DeployDcStart' }
    Catch { $DeployDcStart = 'Visible' }
Try { $DeployOuStart = Get-ItemPropertyValue -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'DeployOuStart' }
    Catch { $DeployOuStart = 'Visible' }
Try { $DeployStandardGpoStart = Get-ItemPropertyValue -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'DeployStandardGpoStart' }
    Catch { $DeployStandardGpoStart = 'Visible' }
Try { $DeployFolderRedirectionStart = Get-ItemPropertyValue -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'DeployFolderRedirectionStart' }
    Catch { $DeployFolderRedirectionStart = 'Visible' }
Try { $DomainNetbiosName = Get-ItemPropertyValue -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'DomainNetbiosName' }
    Catch { $DomainNetbiosName = 'ClearMedia'}
Try { $DomainDNSName = Get-ItemPropertyValue -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'DomainDNSName' }
    Catch { $DomainDNSName = 'ClearMedia.cloud' }
Try { $ManagedOuName = Get-ItemPropertyValue -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'ManagedOuName' }
    Catch { $ManagedOuName = 'SME' }
$ADRootDSE = $(($DomainDNSName.Replace('.',',DC=')).Insert(0,'DC='))
Try { $RdsOuPath = Get-ItemPropertyValue -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'RdsOuPath' }
    Catch { $RdsOuPath = "OU=RDS,OU=Servers,OU=$ManagedOuName,$ADRootDSE" }
Try { $UsersOuPath = Get-ItemPropertyValue -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'UsersOuPath' }
    Catch { $UsersOuPath = "OU=Users,OU=$ManagedOuName,$ADRootDSE" }

# Set Full Screen HD 800 x 1280
Set-DisplayResolution -Height 800 -Width 1280 -Force

# Load Assemblies ( WPF - Windows Presentation Framework )
Add-Type -AssemblyName PresentationFramework

# Init Synchronised HashTable for RunSpaces Aka MultiThreading
$SyncHash = [hashtable]::Synchronized(@{})
$SyncHash.Host = $Host

# Init ( WPF - Windows Presentation Framework ) Config
[XML]$XAML = @"
	<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Title="PushTheButton v1.0" Height="800" Width="1280" WindowState="Maximized"  ShowInTaskbar = "True" Topmost="True">
    <Grid>
        <TabControl HorizontalAlignment="Left" Height="730" Margin="10,0,0,0" VerticalAlignment="Top" Width="1260">
            <TabItem Name="TabItemDeployDC" Header="Deploy DC" Margin="-2,0,-60,0">
                <Grid Background="#FFE5E5E5">
                    <Label Name="LabelDomainNetbiosName" Content="Domain NetbiosName" HorizontalAlignment="Left" Height="28" Margin="30,28,0,0" VerticalAlignment="Top" Width="165"/>
                    <Label Name="LabelDomainName" Content="Domain Name" HorizontalAlignment="Left" Height="28" Margin="30,61,0,0" VerticalAlignment="Top" Width="165" RenderTransformOrigin="0.452,2.089"/>
                    <Label Name="LabelDnsServerForwarders" Content="Dns Server Forwarders" HorizontalAlignment="Left" Height="28" Margin="30,94,0,0" VerticalAlignment="Top" Width="165"/>
                    <TextBox Name="TextBoxDomainNetbiosName"  HorizontalAlignment="Left" Height="22" Margin="200,28,0,0" Text="$DomainNetbiosName" VerticalAlignment="Top" Width="180" TabIndex="1" IsTabStop="False" RenderTransformOrigin="0.673,0.523"/>
                    <TextBox Name="TextBoxDomainDnsName" HorizontalAlignment="Left" Height="22" Margin="200,61,0,0" Text="$DomainDNSName" VerticalAlignment="Top" Width="180" RenderTransformOrigin="0.462,0.455"/>
                    <TextBox Name="TextBoxDnsServerForwarders" HorizontalAlignment="Left" Height="22" Margin="200,94,0,0" Text="195.238.2.21,195.238.2.22,8.8.8.8" VerticalAlignment="Top" Width="180"/>
                    <ScrollViewer VerticalScrollBarVisibility="Auto" Margin="2,250,0,0" Height="380" Width="1256"  HorizontalScrollBarVisibility="Disabled">
                    <TextBlock Name="TextBlockOutBox1" Text="" Foreground="WHITE" Background="#FF22206F" />
                    </ScrollViewer>
                    <Button Name="DeployDcStart" Content="START"  HorizontalAlignment="Left" Margin="950,28,0,0" VerticalAlignment="Top" Width="250" Height="150" Foreground="Blue" FontWeight="Bold" FontSize="50" Background="Red" Visibility="$DeployDcStart" IsEnabled="True" ToolTip="Push It real Good" ToolTipService.ShowDuration="1000"/>
                    <Button Name="DeployDcReboot" Content="REBOOT"  HorizontalAlignment="Left" Margin="950,28,0,0" VerticalAlignment="Top" Width="250" Height="150" Foreground="Blue" FontWeight="Bold" FontSize="50" Background="Red" Visibility="Hidden"  />
                     <StatusBar Name="StatusBarStatus1" HorizontalAlignment="Left" Height="24" Margin="2,670,0,0" VerticalAlignment="Top" Width="1256" Background="#FFD6D2B0" >
                        <Label Name="LabelStatusDeployDcStart" Content="In Progress ...." Height="25" FontSize="12" VerticalAlignment="Center" HorizontalAlignment="Center"  Visibility="Hidden" />
                        <ProgressBar Name="ProgressBarProgressDeployDcStart" Width="1150" Height="15" Value="1" Visibility="Hidden" />
                    </StatusBar>
                </Grid>
            </TabItem>
            <TabItem Name="TabItemDeployOU" Header="Deploy OU" Margin="64,0,-120,0">
                <Grid Background="#FFE5E5E5">
                    <Label Name="LabelManagedOuName" Content="Managed OU Name" HorizontalAlignment="Left" Height="28" Margin="30,28,0,0" VerticalAlignment="Top" Width="165"/>
                    <Label Name="LabelClearmediaAdminUserName" Content="ClearmediaAdmin UserName" HorizontalAlignment="Left" Height="28" Margin="30,61,0,0" VerticalAlignment="Top" Width="165" RenderTransformOrigin="0.452,2.089"/>
                    <Label Name="LabelClearmediaAdminPassword" Content="ClearmediaAdmin Password" HorizontalAlignment="Left" Height="28" Margin="30,94,0,0" VerticalAlignment="Top" Width="165"/>
                    <TextBox Name="TextBoxManagedOuName"  HorizontalAlignment="Left" Height="22" Margin="200,28,0,0" Text="$ManagedOuName" VerticalAlignment="Top" Width="180" TabIndex="1" IsTabStop="False" RenderTransformOrigin="0.673,0.523"/>
                    <TextBox Name="TextBoxClearmediaAdminUserName" HorizontalAlignment="Left" Height="22" Margin="200,61,0,0" Text="ClearmediaAdmin" VerticalAlignment="Top" Width="180" RenderTransformOrigin="0.462,0.455"/>
                    <TextBox Name="TextBoxClearmediaAdminPassword" HorizontalAlignment="Left" Height="22" Margin="200,94,0,0" Text="$('*'*18)" VerticalAlignment="Top" Width="180"/>
                    <ScrollViewer VerticalScrollBarVisibility="Auto" Margin="2,250,0,0" Height="380" Width="1256"  HorizontalScrollBarVisibility="Disabled">
                    <TextBlock Name="TextBlockOutBox2" Text="" Foreground="WHITE" Background="#FF22206F" />
                    </ScrollViewer>
                    <Button Name="DeployOUStart" Content="START"  HorizontalAlignment="Left" Margin="950,28,0,0" VerticalAlignment="Top" Width="250" Height="150" Foreground="Blue" FontWeight="Bold" FontSize="50" Background="Red" Visibility="$DeployOuStart" IsEnabled="True" ToolTip="Push It real Good" ToolTipService.ShowDuration="1000"/>
                     <StatusBar Name="StatusBarStatus2" HorizontalAlignment="Left" Height="24" Margin="2,670,0,0" VerticalAlignment="Top" Width="1256" Background="#FFD6D2B0" >
                        <Label Name="LabelStatusDeployOUStart" Content="In Progress ...." Height="25" FontSize="12" VerticalAlignment="Center" HorizontalAlignment="Center"  Visibility="Hidden" />
                        <ProgressBar Name="ProgressBarProgressDeployOUStart" Width="1150" Height="15" Value="1" Visibility="Hidden" />
                    </StatusBar>
                </Grid>
            </TabItem>
            <TabItem Name="TabItemDelployGPO" Header="Deploy Standard GPO" Margin="124,0,-180,0">
                <Grid Background="#FFE5E5E5">
                    <CheckBox Name="CheckBoxCopyAdmFiles" Content="Copy ADM(X) Files to Local and Central ADM(X) Store" HorizontalAlignment="Left" Margin="32,12,0,0" VerticalAlignment="Top" IsChecked="True"/>
                    <Label Name="LabelTemplateSourcePath" Content="ADM(X) Source Path" Margin="27,32,0,0" Height="28" HorizontalAlignment="Left" VerticalAlignment="Top" Width="150" />
                    <TextBox Name="TextBoxTemplateSourcePath" Margin="155,36,0,0" Text="C:\Install\GPO\Templates" Height="22" HorizontalAlignment="Left" VerticalAlignment="Top" Width="275"/>
                    <Label Name="LabelRdsOuPath" Content="RDS OU Path" Margin="27,80,0,0" Height="28" HorizontalAlignment="Left" VerticalAlignment="Top" Width="150" />
                    <TextBox Name="TextBoxRdsOuPath" Margin="110,84,0,0" Text="$RdsOuPath" Height="22" HorizontalAlignment="Left" VerticalAlignment="Top" Width="320"/>
                    <Label Name="LabelUsersOuPath" Content="Users OU Path" Margin="545,80,0,0" Height="28" HorizontalAlignment="Left" VerticalAlignment="Top" Width="150" />
                    <TextBox Name="TextBoxUsersOuPath" Margin="640,84,0,0" Text="$UsersOuPath" Height="22" HorizontalAlignment="Left" VerticalAlignment="Top" Width="250"/>
                    <CheckBox Name="CheckBoxStandardRdsServerPolicy" Content="StandardRdsServerPolicy" HorizontalAlignment="Left" Margin="110,120,0,0" VerticalAlignment="Top" IsChecked="True"/>
                    <CheckBox Name="CheckBoxStandardServerWindowsUpdate" Content="StandardServerWindowsUpdate" HorizontalAlignment="Left" Margin="110,145,0,0" VerticalAlignment="Top" IsChecked="True"/>
                    <CheckBox Name="CheckBoxStandardUserPolicy" Content="StandardUserPolicy" HorizontalAlignment="Left" Margin="640,120,0,0" VerticalAlignment="Top" IsChecked="True"/>
                    <CheckBox Name="CheckBoxStandardHardwareAccelerationUserPolicy" Content="StandardHardwareAccelerationUserPolicy" HorizontalAlignment="Left" Margin="640,145,0,0" VerticalAlignment="Top" IsChecked="True"/>
                    <CheckBox Name="CheckBoxStandardO365UserPolicy" Content="StandardO365UserPolicy" HorizontalAlignment="Left" Margin="640,170,0,0" VerticalAlignment="Top" IsChecked="True"/>
                    <CheckBox Name="CheckBoxStandardOutlookUserPolicy" Content="StandardOutlookUserPolicy" HorizontalAlignment="Left" Margin="640,195,0,0" VerticalAlignment="Top" IsChecked="True"/>
                    <Label Name="LabelOstPath" Content="Outlook OST Path" Margin="640,220,0,0" Height="28" HorizontalAlignment="Left" VerticalAlignment="Top" Width="150" />
                    <TextBox Name="TextBoxOstPath" Margin="750,224,0,0" Text='D:\Users\%USERNAME%' Height="22" HorizontalAlignment="Left" VerticalAlignment="Top" Width="140"/>
                    <ScrollViewer VerticalScrollBarVisibility="Auto" Margin="2,250,0,0" Height="380" Width="1256"  HorizontalScrollBarVisibility="Disabled">
                        <TextBlock Name="TextBlockOutBox4" Text="" Foreground="WHITE" Background="#FF22206F" />
                    </ScrollViewer>
                    <Button Name="DeployStandardGpoStart" Content="START" HorizontalAlignment="Left" Margin="950,28,0,0" VerticalAlignment="Top" Width="250" Height="150" Foreground="Blue" FontWeight="Bold" FontSize="50" Background="Red" IsEnabled="True" Visibility="$DeployStandardGpoStart" ToolTip="Push It real Good" ToolTipService.ShowDuration="1000"/>
                    <StatusBar Name="StatusBarStatus4" HorizontalAlignment="Left" Height="24" Margin="2,670,0,0" VerticalAlignment="Top" Width="1256" Background="#FFD6D2B0" >
                        <Label Name="LabelStatusDeployStandardGpoStart" Content="In Progress ...." Height="25" FontSize="12" VerticalAlignment="Center" HorizontalAlignment="Center"  Visibility="Hidden" />
                        <ProgressBar Name="ProgressBarProgressDeployStandardGpoStart" Width="1150" Height="15" Value="1" Visibility="Hidden" />
                    </StatusBar>
                </Grid>
            </TabItem>
            <TabItem Name="TabItemFolderRedirection" Header="Deploy Folder Redirection" Margin="184,0,-240,0">
                <Grid Background="#FFE5E5E5">
                    <CheckBox Name="CheckBoxDocuments" Content="Documents" HorizontalAlignment="Left" Margin="30,12,0,0" VerticalAlignment="Top" IsChecked="True"/>
                    <Label Name="LabelDocumentsPath" Content="Documents Path" Margin="50,32,0,0" Height="28" HorizontalAlignment="Left" VerticalAlignment="Top" Width="300" />
                    <TextBox Name="TextBoxDocumentsPath" Margin="200,36,0,0" Text="E:\USERS\%USERNAME%\Documents" Height="22" HorizontalAlignment="Left" VerticalAlignment="Top" Width="220"/>
                    <CheckBox Name="CheckBoxMusic" Content="Music" HorizontalAlignment="Left" Margin="30,65,0,0" VerticalAlignment="Top" IsChecked="True"/>
                    <Label Name="LabelMusicPath" Content="Music Path" Margin="50,85,0,0" Height="28" HorizontalAlignment="Left" VerticalAlignment="Top" Width="150" />
                    <TextBox Name="TextBoxMusicPath" Margin="200,89,0,0" Text="E:\USERS\%USERNAME%\Music" Height="22" HorizontalAlignment="Left" VerticalAlignment="Top" Width="220"/>
                    <CheckBox Name="CheckBoxPictures" Content="Pictures" HorizontalAlignment="Left" Margin="30,118,0,0" VerticalAlignment="Top" IsChecked="True"/>
                    <Label Name="LabelPicturesPath" Content="Pictures Path" Margin="50,138,0,0" Height="28" HorizontalAlignment="Left" VerticalAlignment="Top" Width="150" />
                    <TextBox Name="TextBoxPicturesPath" Margin="200,142,0,0" Text="E:\USERS\%USERNAME%\Pictures" Height="22" HorizontalAlignment="Left" VerticalAlignment="Top" Width="220"/>
                    <CheckBox Name="CheckBoxVideos" Content="Videos" HorizontalAlignment="Left" Margin="30,171,0,0" VerticalAlignment="Top" IsChecked="True"/>
                    <Label Name="LabelVideosPath" Content="Videos Path" Margin="50,191,0,0" Height="28" HorizontalAlignment="Left" VerticalAlignment="Top" Width="150" />
                    <TextBox Name="TextBoxVideosPath" Margin="200,195,0,0" Text="E:\USERS\%USERNAME%\Videos" Height="22" HorizontalAlignment="Left" VerticalAlignment="Top" Width="220"/>
                    <ScrollViewer VerticalScrollBarVisibility="Auto" Margin="2,250,0,0" Height="380" Width="1256"  HorizontalScrollBarVisibility="Disabled">
                        <TextBlock Name="TextBlockOutBox5" Text="" Foreground="WHITE" Background="#FF22206F" />
                    </ScrollViewer>
                    <Button Name="DeployFolderRedirectionStart" Content="START" HorizontalAlignment="Left" Margin="950,28,0,0" VerticalAlignment="Top" Width="250" Height="150" Foreground="Blue" FontWeight="Bold" FontSize="50" Background="Red" IsEnabled="True" Visibility="$DeployFolderRedirectionStart" ToolTip="Push It real Good" ToolTipService.ShowDuration="1000"/>
                    <StatusBar Name="StatusBarStatus5" HorizontalAlignment="Left" Height="24" Margin="2,670,0,0" VerticalAlignment="Top" Width="1256" Background="#FFD6D2B0" >
                        <Label Name="LabelStatusDeployFolderRedirectionStart" Content="In Progress ...." Height="25" FontSize="12" VerticalAlignment="Center" HorizontalAlignment="Center"  Visibility="Hidden" />
                        <ProgressBar Name="ProgressBarProgressDeployFolderRedirectionStart" Width="1150" Height="15" Value="1" Visibility="Hidden" />
                    </StatusBar>
                </Grid>
            </TabItem>
            <TabItem Name="TabItemDeployRDS" Header="Deploy RDS" Margin="244,0,-300,0">
                <Grid Background="#FFE5E5E5">
                    <Label Name="LabelRdsServerIpAddress" Content="RDS Server IpAddress" HorizontalAlignment="Left" Height="28" Margin="30,28,0,0" VerticalAlignment="Top" Width="165"/>
                    <Label Name="LabelAdminUserName" Content="Administrator Name" HorizontalAlignment="Left" Height="28" Margin="30,61,0,0" VerticalAlignment="Top" Width="165"/>
                    <Label Name="LabelAdminPassword" Content="Administrator Password" HorizontalAlignment="Left" Height="28" Margin="30,94,0,0" VerticalAlignment="Top" Width="165"/>
                    <Label Name="LabelRdsServerName" Content="RDS Server Name" HorizontalAlignment="Left" Height="28" Margin="550,28,0,0" VerticalAlignment="Top" Width="165" RenderTransformOrigin="0.452,2.089"/>
					<Label Name="LabelOstFolderRootPath" Content="User OST Root Path" HorizontalAlignment="Left" Margin="550,61,0,0" VerticalAlignment="Top"/>
					<Label Name="LabelDataFolderRootPath" Content="User Data Root Path" HorizontalAlignment="Left" Margin="550,94,0,0" VerticalAlignment="Top"/>
                    <TextBox Name="TextBoxRdsServerIpAddress"  HorizontalAlignment="Left" Height="22" Margin="180,32,0,0" Text="192.168.13.101" VerticalAlignment="Top" Width="180" TabIndex="1" IsTabStop="False" RenderTransformOrigin="0.673,0.523"/>
                    <TextBox Name="TextBoxAdminUserName" HorizontalAlignment="Left" Height="22" Margin="180,65,0,0" Text="Administrator" VerticalAlignment="Top" Width="180"/>
                    <TextBox Name="TextBoxAdminPassword" HorizontalAlignment="Left" Height="22" Margin="180,98,0,0" Text="$('*'*15)" VerticalAlignment="Top" Width="180"/>
                    <TextBox Name="TextBoxRdsServerName" HorizontalAlignment="Left" Height="22" Margin="713,28,0,0" Text="RDS" VerticalAlignment="Top" Width="180" RenderTransformOrigin="0.462,0.455"/>
                    <TextBox Name="TextBoxOstFolderRootPath" Margin="713,61,0,0" Text='D:\Users' Height="22" HorizontalAlignment="Left" VerticalAlignment="Top" Width="180"/>
                    <TextBox Name="TextBoxDataFolderRootPath" Margin="713,94,0,0" Text='E:\Users' Height="22" HorizontalAlignment="Left" VerticalAlignment="Top" Width="180"/>
                    <CheckBox Name="CheckBoxRasx" Content="Deploy Parallels RAS" HorizontalAlignment="Left" Margin="554,140,0,0" VerticalAlignment="Top" IsChecked="False"/>
                    <Label Name="LabelRasLicenseEmailx" Content="Parallels RAS Email" HorizontalAlignment="Left" Height="28" Margin="570,160,0,0" VerticalAlignment="Top" Width="165"/>
                    <Label Name="LabelRasLicensePasswordx" Content="Parallels RAS Password" HorizontalAlignment="Left" Height="28" Margin="570,190,0,0" VerticalAlignment="Top" Width="165" RenderTransformOrigin="0.452,2.089"/>
                    <TextBox Name="TextBoxRasLicenseEmailx"  HorizontalAlignment="Left" Height="22" Margin="713,164,0,0" Text="Support@ClearMedia.be" VerticalAlignment="Top" Width="180" TabIndex="1" IsTabStop="False" RenderTransformOrigin="0.673,0.523"/>
                    <TextBox Name="TextBoxRasLicensePasswordx" HorizontalAlignment="Left" Height="22" Margin="713,194,0,0" Text="$('*'*15)" VerticalAlignment="Top" Width="180" RenderTransformOrigin="0.462,0.455"/>
                    <Label Name="LabelRasKeyx" Content="Parallels RAS Key" HorizontalAlignment="Left" Height="28" Margin="570,220,0,0" VerticalAlignment="Top" Width="165" RenderTransformOrigin="0.452,2.089"/>
                    <TextBox Name="TextBoxRasKeyx" Margin="713,224,0,0" Text="TRIAL" Height="22" HorizontalAlignment="Left" VerticalAlignment="Top" Width="180"/>
                    <ScrollViewer VerticalScrollBarVisibility="Auto" Margin="2,250,0,0" Height="380" Width="1256"  HorizontalScrollBarVisibility="Disabled">
                    <TextBlock Name="TextBlockOutBox3" Text="" Foreground="WHITE" Background="#FF22206F" />
                    </ScrollViewer>
                    <Button Name="DeployRdsStart" Content="START" HorizontalAlignment="Left" Margin="950,28,0,0" VerticalAlignment="Top" Width="250" Height="150" Foreground="Blue" FontWeight="Bold" FontSize="50" Background="Red" IsEnabled="True" Visibility="Visible" ToolTip="Push It real Good" ToolTipService.ShowDuration="1000"/>
                    <Button Name="DeployRdsReboot" Content="REBOOT"  HorizontalAlignment="Left" Margin="950,28,0,0" VerticalAlignment="Top" Width="250" Height="150" Foreground="Blue" FontWeight="Bold" FontSize="50" Background="Red" Visibility="Hidden"  />
                     <StatusBar Name="StatusBarStatus3" HorizontalAlignment="Left" Height="24" Margin="2,670,0,0" VerticalAlignment="Top" Width="1256" Background="#FFD6D2B0" >
                        <Label Name="LabelStatusDeployRdsStart" Content="In Progress ...." Height="25" FontSize="12" VerticalAlignment="Center" HorizontalAlignment="Center"  Visibility="Hidden" />
                        <ProgressBar Name="ProgressBarProgressDeployRdsStart" Width="1150" Height="15" Value="1" Visibility="Hidden" />
                    </StatusBar>
                </Grid>
            </TabItem>
            <TabItem Name="TabItemDeployO365" Header="Deploy O365" Margin="304,0,-360,0">
                <Grid Background="#FFE5E5E5">
                    <Label Name="LabelO365ServerIpAddress" Content="Server IpAddress(es)" HorizontalAlignment="Left" Height="28" Margin="30,28,0,0" VerticalAlignment="Top" Width="165"/>
                    <Label Name="LabelO365AdminUserName" Content="Administrator Name" HorizontalAlignment="Left" Height="28" Margin="30,61,0,0" VerticalAlignment="Top" Width="165" RenderTransformOrigin="0.452,2.089"/>
                    <Label Name="LabelO365AdminPassword" Content="Administrator Password" HorizontalAlignment="Left" Height="28" Margin="30,94,0,0" VerticalAlignment="Top" Width="165"/>
                    <TextBox Name="TextBoxO365ServerIpAddress"  HorizontalAlignment="Left" Height="22" Margin="180,32,0,0" Text="192.168.13.101" VerticalAlignment="Top" Width="180" ToolTip="Fill in Target - Server IpAddress - Server Name"/>
                    <TextBox Name="TextBoxO365AdminUserName" HorizontalAlignment="Left" Height="22" Margin="180,65,0,0" Text="Administrator" VerticalAlignment="Top" Width="180" RenderTransformOrigin="0.462,0.455"/>
                    <TextBox Name="TextBoxO365AdminPassword" HorizontalAlignment="Left" Height="22" Margin="180,98,0,0" Text="$('*'*15)" VerticalAlignment="Top" Width="180" ToolTip="Fill in the Password"/>
                    <RadioButton Name="RadioButton1" Content="O365ProPlusRetail 32 Bit" HorizontalAlignment="Left" Height="22" Margin="550,28,0,0" VerticalAlignment="Top" ClickMode="Press" IsChecked="True"/>
                    <RadioButton Name="RadioButton2" Content="O365ProPlusRetail 64 Bit" HorizontalAlignment="Left" Height="22" Margin="550,61,0,0" VerticalAlignment="Top" ClickMode="Press" IsChecked="False"/>
                    <RadioButton Name="RadioButton3" Content="O365BusinessRetail 32 Bit" HorizontalAlignment="Left" Height="22" Margin="550,94,0,0" VerticalAlignment="Top" ClickMode="Press" IsChecked="False"/>
                    <RadioButton Name="RadioButton4" Content="O365BusinessRetail 64 Bit" HorizontalAlignment="Left" Height="22" Margin="550,127,0,0" VerticalAlignment="Top" ClickMode="Press" IsChecked="False"/>
					<CheckBox Name="CheckBoxExcludeApp" Content="Exclude Teams App" HorizontalAlignment="Left" Height="22" Margin="750,28,0,0" VerticalAlignment="Top" IsChecked="False"/>
                    <ScrollViewer VerticalScrollBarVisibility="Auto" Margin="2,250,0,0" Height="380" Width="1256"  HorizontalScrollBarVisibility="Disabled">
                    <TextBlock Name="TextBlockOutBox7" Text="" Foreground="WHITE" Background="#FF22206F" />
                    </ScrollViewer>
                    <Button Name="DeployO365Start" Content="START" HorizontalAlignment="Left" Margin="950,28,0,0" VerticalAlignment="Top" Width="250" Height="150" Foreground="Blue" FontWeight="Bold" FontSize="50" Background="Red" IsEnabled="True" Visibility="Visible" ToolTip="Push It real Good" ToolTipService.ShowDuration="1000"/>
                     <StatusBar Name="StatusBarStatus7" HorizontalAlignment="Left" Height="24" Margin="2,670,0,0" VerticalAlignment="Top" Width="1256" Background="#FFD6D2B0" >
                        <Label Name="LabelStatusDeployO365Start" Content="In Progress ...." Height="25" FontSize="12" VerticalAlignment="Center" HorizontalAlignment="Center"  Visibility="Hidden" />
                        <ProgressBar Name="ProgressBarProgressDeployO365Start" Width="1150" Height="15" Value="1" Visibility="Hidden" />
                    </StatusBar>
                </Grid>
            </TabItem>
            <TabItem Name="TabItemDeployWU" Header="Deploy Windows Updates" Margin="364,0,-398,0">
                <Grid Background="#FFE5E5E5">
                    <Label Name="LabelWuServerIpAddress" Content="Server IpAddress(es)" HorizontalAlignment="Left" Height="28" Margin="30,28,0,0" VerticalAlignment="Top" Width="165"/>
                    <Label Name="LabelWuAdminUserName" Content="Administrator Name" HorizontalAlignment="Left" Height="28" Margin="30,61,0,0" VerticalAlignment="Top" Width="165"/>
                    <Label Name="LabelWuAdminPassword" Content="Administrator Password" HorizontalAlignment="Left" Height="28" Margin="30,94,0,0" VerticalAlignment="Top" Width="165"/>
                    <Label Name="LabelWuDayOfWeek" Content="Scheduled Day of Week" HorizontalAlignment="Left" Height="28" Margin="550,28,0,0" VerticalAlignment="Top" Width="165"/>
                    <Label Name="LabelWuTime" Content="Scheduled Time (Hr : Min)" HorizontalAlignment="Left" Height="28" Margin="550,61,0,0" VerticalAlignment="Top" Width="165"/>
                    <Label Name="LabelWuTimex" Content=":" HorizontalAlignment="Left" Height="28" Margin="797,58,0,0" VerticalAlignment="Top" Width="20"/>
                    <ComboBox Name="ComboBoxWuDayOfWeek" HorizontalAlignment="Left" Height="26" Margin="713,28,0,0" VerticalAlignment="Top" Width="180" ToolTip="Select Day from List">
                        <ComboBoxItem Content="Monday"/>
                        <ComboBoxItem Content="Tuesday" IsSelected="True"/>
                        <ComboBoxItem Content="Wednesday"/>
                        <ComboBoxItem Content="Thursday"/>
                        <ComboBoxItem Content="Friday"/>
                        <ComboBoxItem Content="Saterday"/>
                        <ComboBoxItem Content="Sunday"/>
                    </ComboBox>
                    <ComboBox Name="ComboBoxWuTimeHour" HorizontalAlignment="Left" Height="26" Margin="713,61,0,0" VerticalAlignment="Top" Width="80" ToolTip="Select Hour from List">
                        <ComboBoxItem Content="00"/>
                        <ComboBoxItem Content="01"/>
                        <ComboBoxItem Content="02"/>
                        <ComboBoxItem Content="03"/>
                        <ComboBoxItem Content="04" IsSelected="True"/>
                        <ComboBoxItem Content="05"/>
                        <ComboBoxItem Content="06"/>
                        <ComboBoxItem Content="07"/>
                        <ComboBoxItem Content="08"/>
                        <ComboBoxItem Content="09"/>
                        <ComboBoxItem Content="10"/>
                        <ComboBoxItem Content="11"/>
                        <ComboBoxItem Content="12"/>
                        <ComboBoxItem Content="13"/>
                        <ComboBoxItem Content="14"/>
                        <ComboBoxItem Content="15"/>
                        <ComboBoxItem Content="16"/>
                        <ComboBoxItem Content="17"/>
                        <ComboBoxItem Content="18"/>
                        <ComboBoxItem Content="19"/>
                        <ComboBoxItem Content="20"/>
                        <ComboBoxItem Content="24"/>
                        <ComboBoxItem Content="22"/>
                        <ComboBoxItem Content="23"/>
                    </ComboBox>
                    <ComboBox Name="ComboBoxWuTimeMinutes" HorizontalAlignment="Left" Height="26" Margin="813,61,0,0" VerticalAlignment="Top" Width="80" SelectedIndex="0" ToolTip="Select Minutes from List">
                        <ComboBoxItem Content="00" IsSelected="True"/>
                        <ComboBoxItem Content="10"/>
                        <ComboBoxItem Content="20"/>
                        <ComboBoxItem Content="30"/>
                        <ComboBoxItem Content="40"/>
                        <ComboBoxItem Content="50"/>
                    </ComboBox>
                    <TextBox Name="TextBoxWuServerIpAddress"  HorizontalAlignment="Left" Height="22" Margin="180,32,0,0" Text="192.168.13.101" VerticalAlignment="Top" Width="180" ToolTip="Fill in Target - Server IpAddress - Server Name"/>
                    <TextBox Name="TextBoxWuAdminUserName" HorizontalAlignment="Left" Height="22" Margin="180,65,0,0" Text="Administrator" VerticalAlignment="Top" Width="180" RenderTransformOrigin="0.462,0.455"/>
                    <TextBox Name="TextBoxWuAdminPassword" HorizontalAlignment="Left" Height="22" Margin="180,98,0,0" Text="$('*'*15)" VerticalAlignment="Top" Width="180" ToolTip="Fill in the Password"/>
                    <ScrollViewer VerticalScrollBarVisibility="Auto" Margin="2,250,0,0" Height="380" Width="1256"  HorizontalScrollBarVisibility="Disabled">
                    <TextBlock Name="TextBlockOutBox8" Text="" Foreground="WHITE" Background="#FF22206F" />
                    </ScrollViewer>
                    <Button Name="DeployWUStart" Content="START" HorizontalAlignment="Left" Margin="950,28,0,0" VerticalAlignment="Top" Width="250" Height="150" Foreground="Blue" FontWeight="Bold" FontSize="50" Background="Red" IsEnabled="True"  Visibility="Visible" ToolTip="Push It real Good" ToolTipService.ShowDuration="1000"/>
                     <StatusBar Name="StatusBarStatus8" HorizontalAlignment="Left" Height="24" Margin="2,670,0,0" VerticalAlignment="Top" Width="1256" Background="#FFD6D2B0" >
                        <Label Name="LabelStatusDeployWUStart" Content="In Progress ...." Height="25" FontSize="12" VerticalAlignment="Center" HorizontalAlignment="Center"  Visibility="Hidden" />
                        <ProgressBar Name="ProgressBarProgressDeployWUStart" Width="1150" Height="15" Value="1" Visibility="Hidden" />
                    </StatusBar>
                </Grid>
            </TabItem>
            <TabItem Name="TabItemDeployUSER" Header="Deploy USER" Margin="402,0,-450,0">
                <Grid Background="#FFE5E5E5">
                    <Label Name="LabelDeployUSERServerIpAddress" Content="Server IpAddress(es)" HorizontalAlignment="Left" Height="28" Margin="30,28,0,0" VerticalAlignment="Top" Width="165"/>
                    <Label Name="LabelDeployUSERAdminUserName" Content="Administrator Name" HorizontalAlignment="Left" Height="28" Margin="30,61,0,0" VerticalAlignment="Top" Width="165"/>
                    <Label Name="LabelDeployUSERAdminPassword" Content="Administrator Password" HorizontalAlignment="Left" Height="28" Margin="30,94,0,0" VerticalAlignment="Top" Width="165"/>
                    <Label Name="LabelDeployUSEROstFolderRootPath" Content="User OST Root Path" HorizontalAlignment="Left" Height="28" Margin="550,28,0,0" VerticalAlignment="Top" Width="165"/>
                    <Label Name="LabelDeployUSERDatatFolderRootPath" Content="User Data Root Path" HorizontalAlignment="Left" Height="28" Margin="550,61,0,0" VerticalAlignment="Top" Width="165"/>
                    <Label Name="LabelUserName" Content="User Name" HorizontalAlignment="Left" Height="28" Margin="550,94,0,0" VerticalAlignment="Top" Width="165"/>
                    <Label Name="LabelUserGivenName" Content="User Given Name" HorizontalAlignment="Left" Height="28" Margin="550,127,0,0" VerticalAlignment="Top" Width="165" RenderTransformOrigin="0.452,2.089"/>
                    <Label Name="LabelUserSurname" Content="User Sur Name" HorizontalAlignment="Left" Height="28" Margin="550,160,0,0" VerticalAlignment="Top" Width="165"/>
                    <Label Name="LabelDepartment" Content="Department" HorizontalAlignment="Left" Height="28" Margin="550,193,0,0" VerticalAlignment="Top" Width="165"/>
                    <Label Name="LabelUserPassword" Content="User Password" HorizontalAlignment="Left" Height="28" Margin="550,226,0,0" VerticalAlignment="Top" Width="165"/>
                    <TextBox Name="TextBoxDeployUSERServerIpAddress"  HorizontalAlignment="Left" Height="22" Margin="180,32,0,0" Text="192.168.13.101" VerticalAlignment="Top" Width="180" ToolTip="Fill in Target - Server IpAddress - Server Name"/>
                    <TextBox Name="TextBoxDeployUSERAdminUserName" HorizontalAlignment="Left" Height="22" Margin="180,65,0,0" Text="Administrator" VerticalAlignment="Top" Width="180" RenderTransformOrigin="0.462,0.455"/>
                    <TextBox Name="TextBoxDeployUSERAdminPassword" HorizontalAlignment="Left" Height="22" Margin="180,98,0,0" Text="$('*'*15)" VerticalAlignment="Top" Width="180" ToolTip="Fill in the Password"/>
                    <TextBox Name="TextBoxDeployUSEROstFolderRootPath" Margin="713,32,0,0" Text='D:\Users' Height="20" HorizontalAlignment="Left" VerticalAlignment="Top" Width="180"/>
                    <TextBox Name="TextBoxDeployUSERUserDataFolderRootPath" Margin="713,65,0,0" Text='E:\Users' Height="22" HorizontalAlignment="Left" VerticalAlignment="Top" Width="180"/>
                    <TextBox Name="TextBoxUserPrincipalName"  HorizontalAlignment="Left" Height="22" Margin="713,98,0,0" Text="" VerticalAlignment="Top" Width="180" TabIndex="1" IsTabStop="False" RenderTransformOrigin="0.673,0.523"/>
                    <TextBox Name="TextBoxUserGivenName" HorizontalAlignment="Left" Height="22" Margin="713,131,0,0" Text="" VerticalAlignment="Top" Width="180" RenderTransformOrigin="0.462,0.455"/>
                    <TextBox Name="TextBoxUserSurname" HorizontalAlignment="Left" Height="22" Margin="713,164,0,0" Text="" VerticalAlignment="Top" Width="180"/>
                    <TextBox Name="TextBoxDepartment" HorizontalAlignment="Left" Height="22" Margin="713,197,0,0" Text="" VerticalAlignment="Top" Width="180"/>
                    <TextBox Name="TextBoxUserPassword" HorizontalAlignment="Left" Height="22" Margin="713,230,0,0" Text="$('*'*15)" VerticalAlignment="Top" Width="180"/>
                    <ScrollViewer VerticalScrollBarVisibility="Auto" Margin="2,250,0,0" Height="380" Width="1256"  HorizontalScrollBarVisibility="Disabled">
                    <TextBlock Name="TextBlockOutBox6" Text="" Foreground="WHITE" Background="#FF22206F" />
                    </ScrollViewer>
                    <Button Name="DeployUserStart" Content="START" HorizontalAlignment="Left" Margin="950,28,0,0" VerticalAlignment="Top" Width="250" Height="150" Foreground="Blue" FontWeight="Bold" FontSize="50" Background="Red" IsEnabled="True"  Visibility="Visible" ToolTip="Push It real Good" ToolTipService.ShowDuration="1000"/>
                     <StatusBar Name="StatusBarStatus6" HorizontalAlignment="Left" Height="24" Margin="2,670,0,0" VerticalAlignment="Top" Width="1256" Background="#FFD6D2B0" >
                        <Label Name="LabelStatusDeployUserStart" Content="In Progress ...." Height="25" FontSize="12" VerticalAlignment="Center" HorizontalAlignment="Center"  Visibility="Hidden" />
                        <ProgressBar Name="ProgressBarProgressDeployUserStart" Width="1150" Height="15" Value="1" Visibility="Hidden" />
                    </StatusBar>
                </Grid>
            </TabItem>
        </TabControl>
    </Grid>
	</Window>
"@

# Init ( WPF - Windows Presentation Framework )
    $reader=(New-Object System.Xml.XmlNodeReader $xaml)
    $syncHash.Window=[Windows.Markup.XamlReader]::Load( $reader )

# Init ( WPF - Windows Presentation Framework ) Functions
	Function DeployDcStart {
		Param($syncHash,$DnsForwarder,$DomainNetbiosName,$DomainDnsName)
        $Runspace = [runspacefactory]::CreateRunspace()
        $Runspace.ApartmentState = "STA"
        $Runspace.ThreadOptions = "ReuseThread"
        $Runspace.Open()
        $Runspace.SessionStateProxy.SetVariable("syncHash",$syncHash)
		$Runspace.SessionStateProxy.SetVariable("DnsForwarder",$DnsForwarder)
		$Runspace.SessionStateProxy.SetVariable("DomainNetbiosName",$DomainNetbiosName)
		$Runspace.SessionStateProxy.SetVariable("DomainDnsName",$DomainDnsName)
        $code = {
			[INT]$I = 0
            [STRING]$RandomPasswordPlainText = ((([char[]](65..90) | sort {get-random})[0..2] + ([char[]](33,35,36,37,42,43,45) | sort {get-random})[0] + ([char[]](97..122) | sort {get-random})[0..4] + ([char[]](48..57) | sort {get-random})[0]) | get-random -Count 10) -join ''
            $SafeModeAdministratorPassword = ConvertTo-SecureString $RandomPasswordPlainText -AsPlainText -Force
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployDcStart.Value = $I } )
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox1.AddText(" Installing Active Directory Domain Services `n") } )
            $Job = Start-Job -Name 'Active Directory Domain Services' -ScriptBlock { Install-WindowsFeature -Name 'AD-Domain-Services' -ErrorAction Stop }
            While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployDcStart.Value = $I } ) }
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox1.AddText(" Installing Group Policy Management `n") } )
            $Job = Start-Job -Name 'Group Policy Management' -ScriptBlock { Install-WindowsFeature -Name 'GPMC' -ErrorAction Stop }
            While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500  ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployDcStart.Value = $I } ) }
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox1.AddText(" Installing DNS Server `n") } )
            $Job = Start-Job -Name 'DNS Server' -ScriptBlock { Install-WindowsFeature -Name 'DNS' }
            While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500  ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployDcStart.Value = $I } ) }
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox1.AddText(" Installing Remote Desktop Licensing Services `n") } )
            $Job = Start-Job -Name 'Remote Desktop Licensing Services' -ScriptBlock { Install-WindowsFeature -Name 'RDS-Licensing' -ErrorAction Stop }
            While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployDcStart.Value = $I } )  }
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox1.AddText(" Installing Remote Server Administration Tools `n") } )
            $Job = Start-Job -Name 'Remote Server Administration Tools' -ScriptBlock { Install-WindowsFeature -Name  'RSAT-AD-Tools','RSAT-DNS-Server','RSAT-RDS-Licensing-Diagnosis-UI','RDS-Licensing-UI' -ErrorAction Stop }
            While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500  ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployDcStart.Value = $I } ) }
			$DnsForwarder.Split(',') | Sort-Object -Descending | ForEach-Object {
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox1.AddText(" Adding DNS Forwarder $_ `n") } )
                $Job = Start-Job -Name "Adding DNS Forwarder $_" -ScriptBlock { Param( $DnsForwarder ) ; Add-DnsServerForwarder -IPAddress ($DnsForwarder.Split(',') | Sort-Object) -ErrorAction Stop } -ArgumentList ( $_ )
                While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployDcStart.Value = $I } )  }
                }
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox1.AddText(" Creating AD Forest for $DomainDnsName `n") } )
            $Job = Start-Job -Name 'Install-ADDSForest' -ScriptBlock { Param($DomainDnsName,$DomainNetbiosName,$SafeModeAdministratorPassword) ; Install-ADDSForest -DomainName $DomainDnsName -DomainNetbiosName $DomainNetbiosName -SafeModeAdministratorPassword $SafeModeAdministratorPassword -NoRebootOnCompletion -ErrorAction Stop -Force} -ArgumentList ($DomainDnsName,$DomainNetbiosName,$SafeModeAdministratorPassword) 
            While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployDcStart.Value = $I } )  }
			$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox1.AddText(" Tweaking Network Location Awareness Service `n") } )
            $Job = Start-Job -Name 'Tweaking NlaSvc' -ScriptBlock { Set-ItemProperty  -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\NlaSvc' -Name 'DependOnService' -Value ('NSI','RpcSs','TcpIp','Dhcp','Eventlog','DNS','NTDS') -Force }
            While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployDcStart.Value = $I } )  }
            Get-Job | Select-Object -Property Name, State, Command, @{Name='Error';Expression={ $_.ChildJobs[0].JobStateInfo.Reason }} | Export-Csv -Path "$env:windir\Logs\PushTheButtonJobs.csv" -NoTypeInformation -Force
            [Boolean]$JobError = Get-Job | Where-Object { $_.State -eq 'Failed' } | ForEach-Object { $_.count -gt 0 }
            If ( $JobError ) 
                {
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployDcStart.Visibility = "Hidden" } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.LabelStatusDeployDcStart.Content = "Deployment Finished with ERRORS $(' .'*115)$(' '*30)Please consult PushTheButtonJobs.csv" } )
                }
                Else 
                {
				New-ItemProperty -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'DeployDcStart' -PropertyType 'String' -Value 'Hidden' -Force
				New-ItemProperty -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'DomainNetbiosName' -PropertyType 'String' -Value $DomainNetbiosName -Force
				New-ItemProperty -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'DomainDNSName' -PropertyType 'String' -Value $DomainDNSName -Force
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployDcStart.Visibility = "Hidden" } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.LabelStatusDeployDcStart.Content = "Deployment Finished $(' .'*135)$(' '*30) Please  REBOOT" } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployDcStart.Visibility = "Hidden" } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployDcReboot.IsEnabled = $True } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployDcReboot.Visibility = "Visible" } )				
                }
			}
        $PSinstance = [powershell]::Create().AddScript($Code)
        $PSinstance.Runspace = $Runspace
        $job = $PSinstance.BeginInvoke()
		}
	Function DeployOuStart {
		Param($syncHash,$ManagedOuName,$ClearmediaAdminUserName,$ClearmediaAdminPassword)
        $Runspace = [runspacefactory]::CreateRunspace()
        $Runspace.ApartmentState = "STA"
        $Runspace.ThreadOptions = "ReuseThread"
        $Runspace.Open()
        $Runspace.SessionStateProxy.SetVariable("syncHash",$syncHash)
		$Runspace.SessionStateProxy.SetVariable("ManagedOuName",$ManagedOuName)
		$Runspace.SessionStateProxy.SetVariable("ClearmediaAdminUserName",$ClearmediaAdminUserName)
		$Runspace.SessionStateProxy.SetVariable("ClearmediaAdminPassword",$ClearmediaAdminPassword)
        $code = {
            $Error.Clear()
            $ErrorList = @()
            [INT]$I = 0
	        [STRING]$ManagedOU = $ManagedOuName
			If ( $ClearmediaAdminPassword -eq "$('*'*18)" ) { [STRING]$ClearmediaAdminPassword = ((([char[]](65..90) | sort {get-random})[0..2] + ([char[]](33,35,36,37,42,43,45) | sort {get-random})[0] + ([char[]](97..122) | sort {get-random})[0..4] + ([char[]](48..57) | sort {get-random})[0]) | get-random -Count 10) -join '' }
			$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBoxClearmediaAdminPassword.Text = $ClearmediaAdminPassword } )
			# Get ADRootDSE
			$ADRootDSE = $(($Env:USERDNSDOMAIN.Replace('.',',DC=')).Insert(0,'DC='))
			# Create HashTable for OU Provisioning
			$OUs = [ordered]@{
				"$ManagedOU" = "$ADRootDSE"
				'Users'= "OU=$ManagedOU,$ADRootDSE"
				'Full Users' = "OU=Users,OU=$ManagedOU,$ADRootDSE"
				'Light Users' = "OU=Users,OU=$ManagedOU,$ADRootDSE"
				'Admin Users' = "OU=Users,OU=$ManagedOU,$ADRootDSE"
				'Groups' = "OU=$ManagedOU,$ADRootDSE"
				'Servers' = "OU=$ManagedOU,$ADRootDSE"
				'RDS' = "OU=Servers,OU=$ManagedOU,$ADRootDSE"
				'DATA' = "OU=Servers,OU=$ManagedOU,$ADRootDSE"
				'WEB' = "OU=Servers,OU=$ManagedOU,$ADRootDSE"
				}
			# Create OU Structure
			$OUs.keys | ForEach-Object { 
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox2.AddText(" Creating OU $_ `n") } ) 
                $I += 4
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployOUStart.Value = $I } )
                New-ADOrganizationalUnit -Name $_ -Path $($OUs.$_) -ErrorAction Stop
                If ( $error ) {
                    $ErrorList += "New-ADOrganizationalUnit -Name $_ -Path $($OUs.$_) -ErrorAction Stop"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }
                }
            # Create HashTable for Group Provisioning
            $Groups = [ordered]@{
				'THINPRINT-Users' = "OU=Groups,OU=$ManagedOU,$ADRootDSE"
				'RAS-Users' = "OU=Groups,OU=$ManagedOU,$ADRootDSE"
	            'RAS-Office-Users' = "OU=Groups,OU=$ManagedOU,$ADRootDSE"
                'RAS-Desktop-Users' = "OU=Groups,OU=$ManagedOU,$ADRootDSE"
                'RAS-Explorer-Users' = "OU=Groups,OU=$ManagedOU,$ADRootDSE"
                'RAS-InternetExplorer-Users' = "OU=Groups,OU=$ManagedOU,$ADRootDSE"
                'RAS-AdobeReader-Users' = "OU=Groups,OU=$ManagedOU,$ADRootDSE"
	            'FTP-Users' = "OU=Groups,OU=$ManagedOU,$ADRootDSE"
	            'RDP-Users' = "OU=Groups,OU=$ManagedOU,$ADRootDSE"
	            'SSLVPN-Users' = "OU=Groups,OU=$ManagedOU,$ADRootDSE"
			    }
            ForEach ($Group in $Groups.keys) {
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox2.AddText(" Adding Group $Group in $($Groups.$Group) `n") } ) 
                $I += 4
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployOUStart.Value = $I } )
                New-ADGroup -Name $Group -GroupScope 'Global' -Path $($Groups.$Group) -ErrorAction Stop
                If ( $error ) {
                    $ErrorList += "New-ADGroup -Name $Group -GroupScope 'Global' -Path $($Groups.$Group) -ErrorAction Stop"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }
                }
            # Create HashTable for User Provisioning
            $NewUserParams= @{
		        'Name' = $ClearmediaAdminUserName
		        'SamAccountName' = $ClearmediaAdminUserName
		        'DisplayName' = $ClearmediaAdminUserName
		        'Description' = $ClearmediaAdminUserName
		        'EmailAddress' = 'support@clearmedia.be'
		        'Path' = "OU=Admin Users,OU=Users,OU=$ManagedOU,$ADRootDSE"
		        'PasswordNeverExpires' = $TRUE
		        'AccountPassword' =  ConvertTo-SecureString $ClearmediaAdminPassword -AsPlainText -Force
		        }
            # Create ClearMedia User
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox2.AddText(" Creating $ClearmediaAdminUserName User `n") } ) 
            $I += 2
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployOUStart.Value = $I } )
            New-ADUser @NewUserParams -ErrorAction Stop
            If ( $error ) {
                $ErrorList += "New-ADUser @NewUserParams -ErrorAction Stop"
                $ErrorList += $error[0].Exception.Message.ToString()
                $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                $Error.Clear()
                }
            # Add ClearMedia User to Admin & Enterprise Groups
            ('Domain Admins','Enterprise Admins') | ForEach-Object { 
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox2.AddText(" Adding ClearMedia User to $_ `n") } ) 
                $I += 4
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployOUStart.Value = $I } )
                Add-ADGroupMember -Identity "CN=$_,CN=Users,$ADRootDSE" -Members "CN=$($NewUserParams.Name),$($NewUserParams.Path)"  -ErrorAction Stop
                If ( $error ) {
                    $ErrorList += "Add-ADGroupMember -Identity CN=$_,CN=Users,$ADRootDSE -Members CN=$($NewUserParams.Name),$($NewUserParams.Path)  -ErrorAction Stop"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }
                }
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployOUStart.Visibility = "Hidden" } )
            If ( $ErrorList ) 
				{ 
                $ErrorList | Out-File -FilePath "$env:windir\Logs\PushTheButtonError.log" -Append -Force
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.LabelStatusDeployOUStart.Content = "Deployment Finished with ERRORS $(' .'*115)$(' '*30)Please consult PushTheButtonError.log" } )
                }
                Else 
				{
        		New-ItemProperty -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'ManagedOuName' -PropertyType 'String' -Value $ManagedOuName -Force
        		New-ItemProperty -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'RdsOuPath' -PropertyType 'String' -Value "OU=RDS,OU=Servers,OU=$ManagedOuName,$ADRootDSE" -Force
        		New-ItemProperty -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'UsersOuPath' -PropertyType 'String' -Value "OU=Users,OU=$ManagedOuName,$ADRootDSE" -Force
        		New-ItemProperty -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'DeployOuStart' -PropertyType 'String' -Value 'Hidden' -Force
        		$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBoxRdsOuPath.Text = "OU=RDS,OU=Servers,OU=$ManagedOuName,$ADRootDSE" } )
        		$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBoxUsersOuPath.Text = "OU=Users,OU=$ManagedOuName,$ADRootDSE" } )
        		$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.LabelStatusDeployOUStart.Content = "Deployment Finished $(' .'*135)$(' '*30)" } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployStandardGpoStart.IsEnabled = $True } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployFolderRedirectionStart.IsEnabled = $True } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployRdsStart.IsEnabled = $True } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployO365Start.IsEnabled = $True } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployWUStart.IsEnabled = $True } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployUserStart.IsEnabled = $True } )
        		}
            }
        $PSinstance = [powershell]::Create().AddScript($Code)
        $PSinstance.Runspace = $Runspace
        $job = $PSinstance.BeginInvoke()
		}
	Function DeployStandardGpoStart {
		Param($syncHash,$TemplateSourcePath,$RdsOuPath,$UsersOuPath,$OstPath,$CheckBoxCopyAdmFiles,$CheckBoxStandardRdsServerPolicy,$CheckBoxStandardServerWindowsUpdate,$CheckBoxStandardUserPolicy,$CheckBoxStandardHardwareAccelerationUserPolicy,$CheckBoxStandardO365UserPolicy,$CheckBoxStandardOutlookUserPolicy)
        $Runspace = [runspacefactory]::CreateRunspace()
        $Runspace.ApartmentState = "STA"
        $Runspace.ThreadOptions = "ReuseThread"
        $Runspace.Open()
        $Runspace.SessionStateProxy.SetVariable("syncHash",$syncHash)
		$Runspace.SessionStateProxy.SetVariable("TemplateSourcePath",$TemplateSourcePath)
		$Runspace.SessionStateProxy.SetVariable("RdsOuPath",$RdsOuPath)
		$Runspace.SessionStateProxy.SetVariable("UsersOuPath",$UsersOuPath)
		$Runspace.SessionStateProxy.SetVariable("OstPath",$OstPath)
		$Runspace.SessionStateProxy.SetVariable("CheckBoxCopyAdmFiles",$CheckBoxCopyAdmFiles)
		$Runspace.SessionStateProxy.SetVariable("CheckBoxStandardRdsServerPolicy",$CheckBoxStandardRdsServerPolicy)
		$Runspace.SessionStateProxy.SetVariable("CheckBoxStandardServerWindowsUpdate",$CheckBoxStandardServerWindowsUpdate)
		$Runspace.SessionStateProxy.SetVariable("CheckBoxStandardUserPolicy",$CheckBoxStandardUserPolicy)
		$Runspace.SessionStateProxy.SetVariable("CheckBoxStandardHardwareAccelerationUserPolicy",$CheckBoxStandardHardwareAccelerationUserPolicy)
		$Runspace.SessionStateProxy.SetVariable("CheckBoxStandardO365UserPolicy",$CheckBoxStandardO365UserPolicy)
		$Runspace.SessionStateProxy.SetVariable("CheckBoxStandardOutlookUserPolicy",$CheckBoxStandardOutlookUserPolicy)
        $code = {
            $Error.Clear()
            $ErrorList = @()
            [INT]$I = 0
			# Get ADRootDSE
			$ADRootDSE = $(($env:USERDNSDOMAIN.Replace('.',',DC=')).Insert(0,'DC='))
            # Copy ADM(X) Files to Local ADM(X) Store
			If ( $CheckBoxCopyAdmFiles ) {			
				$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox4.AddText(" Copying ADM(X) Files to Local ADM(X) Store `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployStandardGpoStart.Value = $I } )
				Copy-Item -Path "$TemplateSourcePath\admx\*" -Destination 'C:\Windows\PolicyDefinitions' -ErrorAction Continue -Force
				If ( $error ) {
                    $ErrorList += "Copy-Item -Path $TemplateSourcePath\admx\* -Destination 'C:\Windows\PolicyDefinitions' -ErrorAction Stop -Force"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployStandardGpoStart.Value = $I } )
				Copy-Item -Path "$TemplateSourcePath\admx\en-US\*" -Destination 'C:\Windows\PolicyDefinitions\en-US' -ErrorAction Continue -Force
				If ( $error ) {
                    $ErrorList += "Copy-Item -Path $TemplateSourcePath\admx\en-US\* -Destination 'C:\Windows\PolicyDefinitions' -ErrorAction Stop -Force"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployStandardGpoStart.Value = $I } )
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
				$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox4.AddText(" Creating Central ADM(X) Store `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployStandardGpoStart.Value = $I } )
				New-Item -Path "\\$PdcName\SYSVOL\$DomainName\Policies\PolicyDefinitions" -ItemType Directory -ErrorAction Continue -Force
				If ( $error ) {
                    $ErrorList += "New-Item -Path \\$PdcName\SYSVOL\$DomainName\Policies\PolicyDefinitions -ItemType Directory -ErrorAction Stop -Force"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }
				$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox4.AddText(" Copying ADM(X) files to Central ADM(X) Store `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployStandardGpoStart.Value = $I } )
				Copy-Item -Path 'C:\Windows\PolicyDefinitions\*' -Destination "\\$PdcName\SYSVOL\$DomainName\Policies\PolicyDefinitions" -ErrorAction Continue -Force
				If ( $error ) {
                    $ErrorList += "Copy-Item -Path 'C:\Windows\PolicyDefinitions\*' -Destination \\$PdcName\SYSVOL\$DomainName\Policies\PolicyDefinitions -ErrorAction Stop -Force"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployStandardGpoStart.Value = $I } )
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
				'HKCU\Software\policies\microsoft\office\16.0\outlook\cached mode,syncwindowsettingdays,Dword,180',
				'HKCU\Software\policies\microsoft\office\16.0\outlook\cached mode,enable,Dword,1',
				"HKCU\Software\policies\microsoft\office\16.0\outlook,forceostpath,ExpandString,$OstPath",
				"HKCU\Software\policies\microsoft\office\16.0\outlook,forcepstpath,ExpandString,$OstPath"
				)
			If ( $CheckBoxStandardRdsServerPolicy ) {
				$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox4.AddText(" Creating StandardRdsServerPolicy Policy `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployStandardGpoStart.Value = $I } )
				$GpoName = 'StandardRdsServerPolicy'
				New-GPO -Name $GpoName -ErrorAction Continue
				If ( $error ) {
                    $ErrorList += "New-GPO -Name $GpoName -ErrorAction Stop"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }
				$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox4.AddText(" Linking StandardRdsServerPolicy Policy to $RdsOuPath `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployStandardGpoStart.Value = $I } )
				New-GPLink -Name "$GpoName" -Target "$RdsOuPath" -ErrorAction Continue
				If ( $error ) {
                    $ErrorList += "New-GPLink -Name $GpoName -Target $RdsOuPath -ErrorAction Stop"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }
				$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox4.AddText(" Injecting StandardRdsServerPolicy Policy Keys `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployStandardGpoStart.Value = $I } )
				$StandardRdsServerPolicy | ForEach-Object {
					$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployStandardGpoStart.Value = $I } )
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
			If ( $CheckBoxStandardServerWindowsUpdate ) {
				$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox4.AddText(" Creating StandardServerWindowsUpdate Policy `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployStandardGpoStart.Value = $I } )
				$GpoName = 'StandardServerWindowsUpdate'
				New-GPO -Name $GpoName -ErrorAction Ignore
				If ( $error ) {
                    $ErrorList += "New-GPO -Name $GpoName -ErrorAction Stop"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }
				$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox4.AddText(" Linking StandardServerWindowsUpdate Policy to $RdsOuPath `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployStandardGpoStart.Value = $I } )
				New-GPLink -Name "$GpoName" -Target "$RdsOuPath" -ErrorAction Continue
				If ( $error ) {
                    $ErrorList += "New-GPLink -Name $GpoName -Target $RdsOuPath -ErrorAction Stop"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }
				$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox4.AddText(" Injecting StandardServerWindowsUpdate Policy Keys `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployStandardGpoStart.Value = $I } )
				$StandardServerWindowsUpdate | ForEach-Object {
					$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployStandardGpoStart.Value = $I } )
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
			If ( $CheckBoxStandardUserPolicy ) {
				$FullUsersOuPath = $UsersOuPath.Insert(0,'OU=Full Users,')
				$LightUsersOuPath = $UsersOuPath.Insert(0,'OU=Light Users,')
				$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox4.AddText(" Creating StandardUserPolicy Policy `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployStandardGpoStart.Value = $I } )
				$GpoName = 'StandardUserPolicy'
				New-GPO -Name $GpoName -ErrorAction Ignore
				If ( $error ) {
                    $ErrorList += "New-GPO -Name $GpoName -ErrorAction Stop"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }
				$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox4.AddText(" Linking $GpoName  Policy to $FullUsersOuPath `n") } )
				$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox4.AddText(" Linking $GpoName  Policy to $LightUsersOuPath `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployStandardGpoStart.Value = $I } )
				New-GPLink -Name "$GpoName" -Target "$FullUsersOuPath" -ErrorAction Continue
				New-GPLink -Name "$GpoName" -Target "$LightUsersOuPath" -ErrorAction Continue
				If ( $error ) {
                    $ErrorList += "New-GPLink -Name $GpoName -Target $UsersOuPath -ErrorAction Stop"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }
				$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox4.AddText(" Injecting $GpoName  Policy Keys `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployStandardGpoStart.Value = $I } )
				$StandardUserPolicy | ForEach-Object {
					$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployStandardGpoStart.Value = $I } )
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
			If ( $CheckBoxStandardHardwareAccelerationUserPolicy ) {
				$FullUsersOuPath = $UsersOuPath.Insert(0,'OU=Full Users,')
				$LightUsersOuPath = $UsersOuPath.Insert(0,'OU=Light Users,')
				$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox4.AddText(" Creating StandardHardwareAccelerationUserPolicy Policy `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployStandardGpoStart.Value = $I } )
				$GpoName = 'StandardHardwareAccelerationUserPolicy'
				New-GPO -Name $GpoName -ErrorAction Ignore
				If ( $error ) {
                    $ErrorList += "New-GPO -Name $GpoName -ErrorAction Stop"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }
				$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox4.AddText(" Linking $GpoName  Policy to $FullUsersOuPath `n") } )
				$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox4.AddText(" Linking $GpoName  Policy to $LightUsersOuPath `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployStandardGpoStart.Value = $I } )
				New-GPLink -Name "$GpoName" -Target "$FullUsersOuPath" -ErrorAction Continue
				New-GPLink -Name "$GpoName" -Target "$LightUsersOuPath" -ErrorAction Continue
				If ( $error ) {
                    $ErrorList += "New-GPLink -Name $GpoName -Target $UsersOuPath -ErrorAction Stop"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }
				$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox4.AddText(" Injecting $GpoName  Policy Keys `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployStandardGpoStart.Value = $I } )
				$StandardHardwareAccelerationUserPolicy | ForEach-Object {
					$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployStandardGpoStart.Value = $I } )
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
			If ( $CheckBoxStandardO365UserPolicy ) {
				$FullUsersOuPath = $UsersOuPath.Insert(0,'OU=Full Users,')
				$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox4.AddText(" Creating StandardO365UserPolicy Policy `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployStandardGpoStart.Value = $I } )
				$GpoName = 'StandardO365UserPolicy'
				New-GPLink -Name "$GpoName" -Target "$FullUsersOuPath" -ErrorAction Continue
				If ( $error ) {
                    $ErrorList += "New-GPO -Name $GpoName -ErrorAction Stop"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }
				$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox4.AddText(" Linking $GpoName  Policy to $FullUsersOuPath `n") } )
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployStandardGpoStart.Value = $I } )
				New-GPLink -Name "$GpoName" -Target "$UsersOuPath.Insert(0,'OU=Full Users,')" -ErrorAction Continue
				If ( $error ) {
                    $ErrorList += "New-GPLink -Name $GpoName -Target $UsersOuPath -ErrorAction Stop"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }
				$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox4.AddText(" Injecting $GpoName  Policy Keys `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployStandardGpoStart.Value = $I } )
				$StandardO365UserPolicy | ForEach-Object {
					$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployStandardGpoStart.Value = $I } )
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
			If ( $CheckBoxStandardOutlookUserPolicy ) {
				$FullUsersOuPath = $UsersOuPath.Insert(0,'OU=Full Users,')
				$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox4.AddText(" Creating StandardOutlookUserPolicy Policy `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployStandardGpoStart.Value = $I } )
				$GpoName = 'StandardOutlookUserPolicy'
				New-GPLink -Name "$GpoName" -Target "$FullUsersOuPath" -ErrorAction Continue
				If ( $error ) {
                    $ErrorList += "New-GPO -Name $GpoName -ErrorAction Stop"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }
				$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox4.AddText(" Linking $GpoName  Policy to $FullUsersOuPath `n") } )
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ;  $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployStandardGpoStart.Value = $I } )
				New-GPLink -Name "$GpoName" -Target "$UsersOuPath.Insert(0,'OU=Full Users,')" -ErrorAction Continue
				If ( $error ) {
                    $ErrorList += "New-GPLink -Name $GpoName -Target $UsersOuPath -ErrorAction Stop"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }
				$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox4.AddText(" Injecting $GpoName  Policy Keys `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployStandardGpoStart.Value = $I } )
				$StandardOutlookUserPolicy | ForEach-Object {
					$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployStandardGpoStart.Value = $I } )
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
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployStandardGpoStart.Visibility = "Hidden" } )
            If ( $ErrorList ) 
                {
                (Get-Date).tostring('dd-MM-yyyy HH:mm:ss') | Out-File -FilePath "$env:windir\Logs\PushTheButtonError.log" -Append -Force
                $ErrorList | Out-File -FilePath "$env:windir\Logs\PushTheButtonError.log" -Append -Force
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.LabelStatusDeployStandardGpoStart.Content = "Deployment Finished with ERRORS $(' .'*115)$(' '*30)Please consult PushTheButtonError.log" } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployStandardGpoStart.Visibility = "Visible"  } )
				}
                Else
                {
		        New-ItemProperty -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'RdsOuPath' -PropertyType 'String' -Value $RdsOuPath -Force
		        New-ItemProperty -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'UsersOuPath' -PropertyType 'String' -Value $UsersOuPath -Force
		        New-ItemProperty -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'DeployStandardGpoStart' -PropertyType 'String' -Value 'Hidden' -Force
		        $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.LabelStatusDeployStandardGpoStart.Content = "Deployment Finished $(' .'*135)$(' '*30)" } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployFolderRedirectionStart.IsEnabled = $True } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployRdsStart.IsEnabled = $True } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployO365Start.IsEnabled = $True } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployWUStart.IsEnabled = $True } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployUserStart.IsEnabled = $True } )
		        }
            }
        $PSinstance = [powershell]::Create().AddScript($Code)
        $PSinstance.Runspace = $Runspace
        $job = $PSinstance.BeginInvoke()      
		}
	Function DeployFolderRedirectionStart {
		Param($syncHash,$CheckBoxDocuments,$DocumentsPath,$CheckBoxMusic,$MusicPath,$CheckBoxPictures,$PicturesPath,$CheckBoxVideos,$VideosPath,$UsersOuPath)
        $Runspace = [runspacefactory]::CreateRunspace()
        $Runspace.ApartmentState = "STA"
        $Runspace.ThreadOptions = "ReuseThread"
        $Runspace.Open()
        $Runspace.SessionStateProxy.SetVariable("syncHash",$syncHash)
		$Runspace.SessionStateProxy.SetVariable("CheckBoxDocuments",$CheckBoxDocuments)
		$Runspace.SessionStateProxy.SetVariable("DocumentsPath",$DocumentsPath)
		$Runspace.SessionStateProxy.SetVariable("CheckBoxMusic",$CheckBoxMusic)
		$Runspace.SessionStateProxy.SetVariable("MusicPath",$MusicPath)
		$Runspace.SessionStateProxy.SetVariable("CheckBoxPictures",$CheckBoxPictures)
		$Runspace.SessionStateProxy.SetVariable("PicturesPath",$PicturesPath)
		$Runspace.SessionStateProxy.SetVariable("CheckBoxVideos",$CheckBoxVideos)
		$Runspace.SessionStateProxy.SetVariable("VideosPath",$VideosPath)
		$Runspace.SessionStateProxy.SetVariable("UsersOuPath",$UsersOuPath)
        $code = {
            $Error.Clear()
            $ErrorList = @()
            [INT]$I = 0
    	    # Create and Assemble User GPOs
    	    # Link User GPOs to OU Users
            If ( $CheckBoxDocuments -or $CheckBoxMusic -or $CheckBoxPictures -or $CheckBoxVideos ) {
				$FullUsersOuPath = $UsersOuPath.Insert(0,'OU=Full Users,')
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox5.AddText(" Creating StandardUserPolicy Policy `n") } ) 
                $I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployFolderRedirectionStart.Value = $I } )
			    $GpoName = 'StandardUserFolderRedirectionPolicy'
			    New-GPO -Name $GpoName -ErrorAction Ignore
			    If ( $error ) {
                    $ErrorList += "New-GPO -Name $GpoName -ErrorAction Stop"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }
				$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox5.AddText(" Linking $GpoName  Policy to $FullUsersOuPath `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployFolderRedirectionStart.Value = $I } )
				New-GPLink -Name "$GpoName" -Target "$FullUsersOuPath" -ErrorAction Continue
				If ( $error ) {
                    $ErrorList += "New-GPLink -Name $GpoName -Target $UsersOuPath -ErrorAction Stop"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }
				$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox5.AddText(" Injecting $GpoName  Policy Keys `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployFolderRedirectionStart.Value = $I } )
				}
			If ( $CheckBoxDocuments ) {
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox5.AddText(" Setting DocumentsPath to $DocumentsPath `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployFolderRedirectionStart.Value = $I } )
				Set-GPRegistryValue -Name $GpoName -Key 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -ValueName 'Personal' -Type 'ExpandString' -Value $DocumentsPath  -ErrorAction Continue
				If ( $error ) {
                    $ErrorList += "Set-GPRegistryValue -Name $GpoName -Key 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -ValueName 'Personal' -Type 'ExpandString' -Value $DocumentsPath  -ErrorAction Continue"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }            
				}
			If ( $CheckBoxMusic ) {
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployFolderRedirectionStart.Value = $I } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox5.AddText(" Setting MusicPath to $MusicPath `n") } ) 
				Set-GPRegistryValue -Name $GpoName -Key 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -ValueName 'My Music' -Type 'ExpandString' -Value $MusicPath  -ErrorAction Continue
				If ( $error ) {
                    $ErrorList += "Set-GPRegistryValue -Name $GpoName -Key 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -ValueName 'My Music' -Type 'ExpandString' -Value $MusicPath  -ErrorAction Continue"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }            
				}
			If ( $CheckBoxPictures ) {
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox5.AddText(" Setting PicturesPath to $PicturesPath `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployFolderRedirectionStart.Value = $I } )
				Set-GPRegistryValue -Name $GpoName -Key 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -ValueName 'My Pictures' -Type 'ExpandString' -Value $PicturesPath  -ErrorAction Continue
				If ( $error ) {
                    $ErrorList += "Set-GPRegistryValue -Name $GpoName -Key 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -ValueName 'My Pictures' -Type 'ExpandString' -Value $PicturesPath  -ErrorAction Continue"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }            
				}
			If ( $CheckBoxVideos ) {
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox5.AddText(" Setting VideosPath to $VideosPath `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployFolderRedirectionStart.Value = $I } )
				Set-GPRegistryValue -Name $GpoName -Key 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -ValueName 'My Video' -Type 'ExpandString' -Value $VideosPath  -ErrorAction Continue
				If ( $error ) {
                    $ErrorList += "Set-GPRegistryValue -Name $GpoName -Key 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -ValueName 'My Video' -Type 'ExpandString' -Value $VideosPath  -ErrorAction Continue"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }            
				}
			$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployFolderRedirectionStart.Visibility = "Hidden" } )
			If ( $ErrorList ) 
                {
                (Get-Date).tostring('dd-MM-yyyy HH:mm:ss') | Out-File -FilePath "$env:windir\Logs\PushTheButtonError.log" -Append -Force
                $ErrorList | Out-File -FilePath "$env:windir\Logs\PushTheButtonError.log" -Append -Force
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.LabelStatusDeployFolderRedirectionStart.Content = "Deployment Finished with ERRORS $(' .'*115)$(' '*30)Please consult PushTheButtonError.log" } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployFolderRedirectionStart.Visibility = "Visible"  } )				
                }
				Else
                {
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.LabelStatusDeployFolderRedirectionStart.Content = "Deployment Finished $(' .'*135)$(' '*30)" } ) }
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployFolderRedirectionStart.Visibility = "Visible"  } )
            New-ItemProperty -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'DeployFolderRedirectionStart' -PropertyType 'String' -Value 'Hidden' -Force
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployRdsStart.IsEnabled = $True } )
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployO365Start.IsEnabled = $True } )
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployWUStart.IsEnabled = $True } )
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployUserStart.IsEnabled = $True } )                				
            }
		$PSinstance = [powershell]::Create().AddScript($Code)
		$PSinstance.Runspace = $Runspace
		$job = $PSinstance.BeginInvoke()       
		}
	Function DeployRdsStart {
		Param($syncHash,$RdsServerIpAddress,$RdsServerName,$AdminUserName,$AdminPassword,$OstFolderRootPath,$DataFolderRootPath,$RdsOuPath,$DomainDnsName,$CheckBoxRas,$RasLicenseEmail,$RasLicensePassword,$CheckBoxRasKey,$RasKey)
        $Runspace = [runspacefactory]::CreateRunspace()
        $Runspace.ApartmentState = "STA"
        $Runspace.ThreadOptions = "ReuseThread"
        $Runspace.Open()
        $Runspace.SessionStateProxy.SetVariable("syncHash",$syncHash)
		$Runspace.SessionStateProxy.SetVariable("RdsServerIpAddress",$RdsServerIpAddress)
		$Runspace.SessionStateProxy.SetVariable("RdsServerName",$RdsServerName)
		$Runspace.SessionStateProxy.SetVariable("AdminUserName",$AdminUserName)
		$Runspace.SessionStateProxy.SetVariable("AdminPassword",$AdminPassword)
		$Runspace.SessionStateProxy.SetVariable("OstFolderRootPath",$OstFolderRootPath)
		$Runspace.SessionStateProxy.SetVariable("DataFolderRootPath",$DataFolderRootPath)
		$Runspace.SessionStateProxy.SetVariable("RdsOuPath",$RdsOuPath)
		$Runspace.SessionStateProxy.SetVariable("DomainDnsName",$DomainDnsName)
		$Runspace.SessionStateProxy.SetVariable("CheckBoxRas",$CheckBoxRas)
		$Runspace.SessionStateProxy.SetVariable("RasLicenseEmail",$RasLicenseEmail)
		$Runspace.SessionStateProxy.SetVariable("RasLicensePassword",$RasLicensePassword)
		$Runspace.SessionStateProxy.SetVariable("CheckBoxRasKey",$CheckBoxRasKey)
		$Runspace.SessionStateProxy.SetVariable("RasKey",$RasKey)
        $code = {
            [INT]$I = 0
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployRdsStart.Value = $I } )
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox3.AddText(" Connecting to $RdsServerIpAddress `n") } )
            $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ("$RdsServerIpAddress\$AdminUserName", $(ConvertTo-SecureString -String $AdminPassword -AsPlainText -Force))
            Set-Item WSMan:\localhost\Client\TrustedHosts -Value "$RdsServerIpAddress" -Force
            Try { 
                $PsSession = New-PSSession -ComputerName $RdsServerIpAddress -Credential $Credential -ErrorAction Stop
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBoxO365AdminUserName.Text = $AdminUserName } ) 
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBoxO365AdminPassword.Text = $AdminPassword } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBoxWuAdminUserName.Text = $AdminUserName } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBoxWuAdminPassword.Text = $AdminPassword } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBoxDeployUSERAdminUserName.Text = $AdminUserName } ) 
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBoxDeployUSERAdminPassword.Text = $AdminPassword } ) 
                }
                Catch {
                    $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployRdsStart.Visibility = "Hidden" } )
                    $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.LabelStatusDeployRdsStart.Content = "Connection Failure $(' .'*130)$(' '*30)Please check Server - Username - Password" } )
                    $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployRdsStart.IsEnabled = $True } )
                    $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployRdsStart.Visibility = "Visible"  } )
                    Return
                    }
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox3.AddText(" Setting Autostart for RDS related Services `n") } )			
            $Job = Invoke-Command -Session $PsSession -AsJob -JobName 'RdsServices' -ScriptBlock {
				$Services = @{
					'Audiosrv' =  'Auto'
					'SCardSvr' = 'Auto'
					'WSearch'  = 'Auto'
					}
				$Services.keys | ForEach-Object { Set-Service -Name $_ -StartupType $($Services.$_) }
				}
            While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployRdsStart.Value = $I } ) }
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox3.AddText(" Installing RDS related Roles & Features `n") } )
	        $Job = Invoke-Command -Session $PsSession  -AsJob -JobName 'RdsRoles' -ScriptBlock {
				$Roles = [ordered]@{
					'Windows TIFF IFilter' =  'Windows-TIFF-IFilter'
					'Remote Desktop Services' = 'RDS-RD-Server'
					'Group Policy Management' = 'GPMC'
					'Remote Server Administration Tools' = ('RSAT-AD-Tools','RSAT-DNS-Server','RSAT-RDS-Licensing-Diagnosis-UI','RDS-Licensing-UI')
					}
				$Roles.Values | ForEach-Object { Install-WindowsFeature -Name $_ }
				}
	        While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployRdsStart.Value = $I } ) }
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox3.AddText(" Configuring Disk 'DataOST' `n") } )
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox3.AddText(" Creating D:\Users and Setting NTFS Security `n") } )
            $Job = Invoke-Command -Session $PsSession -AsJob -JobName 'DataOST' -ScriptBlock {
                    Param($OstFolderRootPath)
                    If ( (get-disk -Number 1).AllocatedSize -eq 0 ) {
			            Initialize-Disk -Number 1
                    	New-Partition -DiskNumber 1 -DriveLetter 'D' -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel 'DataOst'
                        # Set ACL FullControl to System & Administrators on Root
                        # Disable Inheritance
                    	# $ACL.SetAccessRuleProtection($true,$true)
						[STRING]$Root = 'D:\'
						$ACL = Get-Acl -Path $Root
						$AccessRule = New-Object system.security.AccessControl.FileSystemAccessRule('NT AUTHORITY\SYSTEM', 'FullControl', 'None', 'None', 'Allow')
                    	$ACL.AddAccessRule($AccessRule)
						$AccessRule = New-Object system.security.AccessControl.FileSystemAccessRule('BUILTIN\Administrators', 'FullControl', 'None', 'None', 'Allow')
                    	$ACL.AddAccessRule($AccessRule)
						Set-Acl -Path $Root -AclObject $ACL
                        # Create User Folder
                    	# $OstFolderRootPath = 'D:\Users'
                    	New-Item -Path $OstFolderRootPath -type directory -Force
			            }
                    } -ArgumentList ($OstFolderRootPath) 
            While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployRdsStart.Value = $I } ) }
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox3.AddText(" Configuring Disk 'DATA' `n") } )
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox3.AddText(" Creating E:\Users and Setting NTFS Security `n") } )
			$Job = Invoke-Command -Session $PsSession -AsJob -JobName 'UserData' -ScriptBlock {
                    Param($DataFolderRootPath)
                    If ( (get-disk -Number 2).AllocatedSize -eq 0 ) {
			            Initialize-Disk -Number 2
                    	New-Partition -DiskNumber 2 -DriveLetter 'E' -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel 'Data'
                        # Set ACL FullControl to System & Administrators , Set ACL ListOnly to Users on Root
                        # Disable Inheritance
                    	# $ACL.SetAccessRuleProtection($true,$true)
						[STRING]$Root = 'E:\'
						$ACL = Get-Acl -Path $Root
						$AccessRule = New-Object system.security.AccessControl.FileSystemAccessRule('NT AUTHORITY\SYSTEM', 'FullControl', 'None', 'None', 'Allow')
                    	$ACL.AddAccessRule($AccessRule)
						$AccessRule = New-Object system.security.AccessControl.FileSystemAccessRule('BUILTIN\Administrators', 'FullControl', 'None', 'None', 'Allow')
                    	$ACL.AddAccessRule($AccessRule)
                    	$AccessRule = New-Object system.security.AccessControl.FileSystemAccessRule('BUILTIN\Users', 'ReadData, ReadAttributes, Synchronize', 'None', 'None', 'Allow')
                    	$ACL.AddAccessRule($AccessRule)
						Set-Acl -Path $Root -AclObject $ACL
                        # Create User Folder
                    	# $DataFolderRootPath = 'E:\Users'
                    	New-Item -Path $DataFolderRootPath -type directory -Force
			            }
                    } -ArgumentList ($DataFolderRootPath)
            While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployRdsStart.Value = $I } ) }
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox3.AddText(" Configuring IPv4 DNS IP @ 192.168.13.100 `n") } )
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox3.AddText(" Joining to Domain $DomainDnsName `n") } )
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox3.AddText(" Renaming NetBiosName to $RdsServerName `n") } )
			$Job = Invoke-Command -Session $PsSession -AsJob -JobName 'RenameJoinRDS' -ScriptBlock {
                    Param($RdsServerIpAddress,$RdsServerName,$AdminUserName,$AdminPassword,$RdsOuPath,$DomainDnsName) ; 
                    Get-NetIPConfiguration | Set-DnsClientServerAddress -ServerAddresses '192.168.13.100'
                    $DomainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ("$($AdminUserName)@$($DomainDnsName)", $(ConvertTo-SecureString -String $AdminPassword -AsPlainText -Force))
                    Add-Computer -DomainName $DomainDnsName -OUPath $RdsOuPath -Credential $DomainCredential -Force
                    Rename-Computer -NewName $RdsServerName -DomainCredential $DomainCredential -Force
                    } -ArgumentList ($RdsServerIpAddress,$RdsServerName,$AdminUserName,$AdminPassword,$RdsOuPath,$DomainDnsName) 
            While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployRdsStart.Value = $I } ) }
            If ( $CheckBoxRas ) {
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox3.AddText(" Downloading and Installing Parallels RAS 17.0.21475 `n") } )
			    $Job = Invoke-Command -Session $PsSession -AsJob -JobName 'Download and Install Parallels RAS 17.0.21475' -ScriptBlock {
                    [STRING]$UrlDownload =  'https://download.parallels.com/ras/v17/17.0.1.21475/RASInstaller-17.0.21475.msi'
                    [STRING]$FileDownload = "$ENV:TEMP\$($UrlDownload.Split('/')[-1])"
                    Invoke-WebRequest -Uri $UrlDownload -UseBasicParsing  -OutFile $FileDownload -PassThru | Out-Null
                    Start-Sleep -Seconds 5
                    Invoke-Expression -Command "CMD.exe /C 'MsiExec.exe /i $FileDownload /qn /norestart'"
                    }
                While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployRdsStart.Value = $I } ) }
			    $Job = Invoke-Command -Session $PsSession -AsJob -JobName "Deploy Parallels RAS Farm" -ScriptBlock {
                    Param($RasLicenseEmail,$RasLicensePassword,$AdminUserName,$AdminPassword,$RdsServerIpAddress)
                    If (-Not (Test-Path -Path 'C:\Program Files (x86)\Parallels\ApplicationServer\Modules\PSAdmin\PSAdmin.psd1')) { Start-Sleep -Seconds 5 }
                    Start-Sleep -Seconds 5
                    Import-Module 'C:\Program Files (x86)\Parallels\ApplicationServer\Modules\PSAdmin\PSAdmin.psd1'
                    Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Parallels\Setup\ApplicationServer -Name ProductDir -Value "C:\Program Files (x86)\Parallels\ApplicationServer\"
                    [securestring]$SecPassword = ConvertTo-SecureString $AdminPassword -AsPlainText -Force
                    New-RASSession -Username $AdminUserName -Password $SecPassword -Server 'localhost'
                    #Invoke Trial License
                    $SecRAsLicensePassword = ConvertTo-SecureString $RasLicensePassword -AsPlainText -Force
                    Invoke-LicenseActivate -Email $RasLicenseEmail -Password $SecRAsLicensePassword
                    Invoke-Apply
                    } -ArgumentList ($RasLicenseEmail,$RasLicensePassword,$AdminUserName,$AdminPassword,$RdsServerIpAddress) 
                While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployRdsStart.Value = $I } ) }
                }
            Get-Job | Select-Object -Property Name, State, Command, @{Name='Error';Expression={ $_.ChildJobs[0].JobStateInfo.Reason }} | Export-Csv -Path "$env:windir\Logs\PushTheButtonJobs.csv" -NoTypeInformation -Force
            If ((Get-Job).Where({$_.State -eq 'Failed'}).count -ne 0 ) 
                {
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployRdsStart.Visibility = "Hidden" } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.LabelStatusDeployRdsStart.Content = "Deployment Finished with ERRORS $(' .'*115)$(' '*30)Please consult PushTheButtonJobs.csv" } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployRdsStart.IsEnabled = $True } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployRdsStart.Visibility = "Visible" } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployUserStart.IsEnabled = $True } )
                }
                Else 
                {
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployRdsStart.Visibility = "Hidden" } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.LabelStatusDeployRdsStart.Content = "Deployment Finished $(' .'*135)$(' '*30) Please  REBOOT" } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployRdsStart.Visibility = "Hidden" } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployRdsReboot.Visibility = "Visible"  } )
                }
            }
        $PSinstance = [powershell]::Create().AddScript($Code)
        $PSinstance.Runspace = $Runspace
        $job = $PSinstance.BeginInvoke()      
		}
	Function DeployRdsReboot {
		Param($syncHash,$RdsServerIpAddress,$AdminUserName,$AdminPassword)
        $Runspace = [runspacefactory]::CreateRunspace()
        $Runspace.ApartmentState = "STA"
        $Runspace.ThreadOptions = "ReuseThread"
        $Runspace.Open()
        $Runspace.SessionStateProxy.SetVariable("syncHash",$syncHash)
		$Runspace.SessionStateProxy.SetVariable("RdsServerIpAddress",$RdsServerIpAddress)
		$Runspace.SessionStateProxy.SetVariable("AdminUserName",$AdminUserName)
		$Runspace.SessionStateProxy.SetVariable("AdminPassword",$AdminPassword)
        $code = {
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox3.AddText(" Rebooting $RdsServerIpAddress `n") } )
            $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ("$RdsServerIpAddress\$AdminUserName", $(ConvertTo-SecureString -String $AdminPassword -AsPlainText -Force))
            Set-Item WSMan:\localhost\Client\TrustedHosts -Value "$RdsServerIpAddress" -Force
			$Job = Invoke-Command -ComputerName $RdsServerIpAddress -Credential $Credential -AsJob -JobName "RebootRDS" -ScriptBlock { Restart-Computer -Force }
            Get-Job | Select-Object -Property Name, State, Command, @{Name='Error';Expression={ $_.ChildJobs[0].JobStateInfo.Reason }} | Export-Csv -Path "$env:windir\Logs\PushTheButtonJobs.csv" -NoTypeInformation -Force
            While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployRdsStart.Value = $I } ) }
            If ((Get-Job).Where({$_.State -eq 'Failed'}).count -ne 0 ) 
                {
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployRdsStart.Visibility = "Hidden" } )
				$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployRdsReboot.Visibility = "Hidden"  } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.LabelStatusDeployRdsStart.Content = "REBOOT Finished with ERRORS $(' .'*115)$(' '*30)Please consult PushTheButtonJobs.csv" } )
                }
                Else 
                {
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployRdsStart.Visibility = "Hidden" } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployRdsReboot.Visibility = "Hidden"  } )				
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.LabelStatusDeployRdsStart.Content = "Reboot Initiated $(' .'*50)" } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployO365Start.IsEnabled = $True } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployWUStart.IsEnabled = $True } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployUserStart.IsEnabled = $True } )                				
                }	
			}
        $PSinstance = [powershell]::Create().AddScript($Code)
        $PSinstance.Runspace = $Runspace
        $job = $PSinstance.BeginInvoke()        
		}
	Function DeployO365Start {
		Param($syncHash,$ServerIpAddressList,$AdminUserName,$AdminPassword,$RadioButton1,$RadioButton2,$RadioButton3,$RadioButton4,$CheckBoxExcludeApp)
        $Runspace = [runspacefactory]::CreateRunspace()
        $Runspace.ApartmentState = "STA"
        $Runspace.ThreadOptions = "ReuseThread"
        $Runspace.Open()
        $Runspace.SessionStateProxy.SetVariable("syncHash",$syncHash)
		$Runspace.SessionStateProxy.SetVariable("ServerIpAddressList",$ServerIpAddressList)
		$Runspace.SessionStateProxy.SetVariable("AdminUserName",$AdminUserName)
		$Runspace.SessionStateProxy.SetVariable("AdminPassword",$AdminPassword)
		$Runspace.SessionStateProxy.SetVariable("RadioButton1",$RadioButton1)
		$Runspace.SessionStateProxy.SetVariable("RadioButton2",$RadioButton2)
		$Runspace.SessionStateProxy.SetVariable("RadioButton3",$RadioButton3)
		$Runspace.SessionStateProxy.SetVariable("RadioButton4",$RadioButton4)
		$Runspace.SessionStateProxy.SetVariable("CheckBoxExcludeApp",$CheckBoxExcludeApp)
        $code = {
            [INT]$I = 0
            ForEach ( $ServerIpAddress in $ServerIpAddressList.Split(',') ) {
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployO365Start.Value = $I } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox7.AddText(" Connecting to $ServerIpAddress `n") } )
                $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ("$ServerIpAddress\$AdminUserName", $(ConvertTo-SecureString -String $AdminPassword -AsPlainText -Force))
                Set-Item WSMan:\localhost\Client\TrustedHosts -Value "$ServerIpAddress" -Force
                Try { $PsSession = New-PSSession -ComputerName $ServerIpAddress -Credential $Credential -ErrorAction Stop }
                    Catch {
                    $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployO365Start.Visibility = "Hidden" } )
                    $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.LabelStatusDeployO365Start.Content = "Connection Failure $(' .'*130)$(' '*30)Please check Server - Username - Password" } )
                    $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployO365Start.IsEnabled = $True } )
                    $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployO365Start.Visibility = "Visible"  } )
                    Return
                    }
                If ( $RadioButton1 ) { $ProductId = 'O365ProPlusRetail' ; $O365version = '32' }
                If ( $RadioButton2 ) { $ProductId = 'O365ProPlusRetail' ; $O365version = '64'  }
                If ( $RadioButton3 ) { $ProductId = 'O365BusinessRetail' ; $O365version = '32'  }
                If ( $RadioButton4 ) { $ProductId = 'O365BusinessRetail' ; $O365version = '64'  }
                If ( $CheckBoxExcludeApp ) { $ExcludeApp = 'Teams' } Else  { $ExcludeApp = '' }
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox7.AddText(" Downloading and Extracting Office Deployment Tool `n") } )
			    $Job = Invoke-Command -Session $PsSession -AsJob -JobName 'Download and Extract Office Deployment Tool' -ScriptBlock {
                    Param($O365version,$ProductId,$ExcludeApp)
                    $Url = 'https://www.microsoft.com/en-us/download/confirmation.aspx?id=49117'
                    $UrlDownload =  (Invoke-WebRequest -Uri $url  -UseBasicParsing | ForEach-Object { $_.links } | Where-Object { $_.href -like '*officedeploymenttool*' }).href[0]
                    $FileDownload = "$Env:TEMP\ODT.exe"
                    (New-Object System.Net.WebClient).DownloadFile($UrlDownload, $FileDownload)
                    Do { Start-Sleep -Seconds 2 } Until ( Test-Path -Path $FileDownload ) 
                    Invoke-Expression -Command "CMD.EXE /C '$FileDownload /quiet /extract:$FileDownload\..'"
                    [STRING]$Config = @"
    <Configuration>
	    <Add 
	    SourcePath="c:\install\O365"
	    OfficeClientEdition="$O365version"
	    Channel="Broad">
        	<Product ID="$ProductId">
			<Language
			ID="en-us">
			</Language>
			<Language
			ID="nl-nl">
			</Language>
			<Language
			ID="fr-fr">
			</Language>
			<ExcludeApp
			ID="$ExcludeApp">
			</ExcludeApp>
        	</Product>
    	</Add>
        <Updates
	    Channel="Broad"
	    Enabled="TRUE">
	    </Updates>
	    <Display
	    Level="Full"
	    AcceptEULA="TRUE">
	    </Display>
	    <Logging
	    Level="Standard"
	    Path="c:\windows\logs\O365">
	    </Logging>
	    <Property
	    Name="FORCEAPPSHUTDOWN"
	    Value="TRUE">
	    </Property>
	    <Property
	    Name="SharedComputerLicensing"
	    Value="1">
	    </Property>
	    <Property
	    Name="PinIconsToTaskbar"
	    Value="FALSE">
	    </Property>
    </Configuration>
"@
                    $Config | Out-File -FilePath "$Env:TEMP\configuration.xml"               
                    } -ArgumentList ($O365version,$ProductId,$ExcludeApp) 
                While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployO365Start.Value = $I } ) }
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox7.AddText(" Downloading $ProductId $O365version bit `n") } )
			    $Job = Invoke-Command -Session $PsSession -AsJob -JobName "Download $ProductId $O365version bit" -ScriptBlock { Invoke-Expression -Command "$Env:TEMP\setup.exe /download  $Env:TEMP\configuration.xml" }
                While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployO365Start.Value = $I } ) }
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox7.AddText(" Installing $ProductId $O365version bit `n") } )
			    $Job = Invoke-Command -Session $PsSession -AsJob -JobName "Install $ProductId $O365version bit" -ScriptBlock { Invoke-Expression -Command "$Env:TEMP\setup.exe /configure  $Env:TEMP\configuration.xml" }
                While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployO365Start.Value = $I } ) }
            }   
            Get-Job | Select-Object -Property Name, State, Command, @{Name='Error';Expression={ $_.ChildJobs[0].JobStateInfo.Reason }} | Export-Csv -Path "$env:windir\Logs\PushTheButtonJobs.csv" -NoTypeInformation -Force
            If ((Get-Job).Where({$_.State -eq 'Failed'}).count -ne 0 ) 
                {
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployO365Start.Visibility = "Hidden" } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.LabelStatusDeployO365Start.Content = "Deployment Finished with ERRORS $(' .'*115)$(' '*30)Please consult PushTheButtonJobs.csv" } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployO365Start.IsEnabled = $True } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployO365Start.Visibility = "Visible" } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployUserStart.IsEnabled = $True } )
                }
                Else 
                {
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployO365Start.Visibility = "Hidden" } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.LabelStatusDeployO365Start.Content = "Deployment Finished$(' .'*135)$(' '*30)" } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployO365Start.IsEnabled = $True } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployWUStart.IsEnabled = $True } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployUserStart.IsEnabled = $True } )                				
                }
            }
        $PSinstance = [powershell]::Create().AddScript($Code)
        $PSinstance.Runspace = $Runspace
        $job = $PSinstance.BeginInvoke()
		}
	Function DeployWuStart {
		Param($syncHash,$WuServerIpAddress,$WuAdminUserName,$WuAdminPassword,$WuDayOfWeek,$WuTimeHour,$WuTimeMinutes)
        $Runspace = [runspacefactory]::CreateRunspace()
        $Runspace.ApartmentState = "STA"
        $Runspace.ThreadOptions = "ReuseThread"
        $Runspace.Open()
        $Runspace.SessionStateProxy.SetVariable("syncHash",$syncHash)
		$Runspace.SessionStateProxy.SetVariable("WuServerIpAddress",$WuServerIpAddress)
		$Runspace.SessionStateProxy.SetVariable("WuAdminUserName",$WuAdminUserName)
		$Runspace.SessionStateProxy.SetVariable("WuAdminPassword",$WuAdminPassword)
		$Runspace.SessionStateProxy.SetVariable("WuDayOfWeek",$WuDayOfWeek)
		$Runspace.SessionStateProxy.SetVariable("WuTimeHour",$WuTimeHour)
		$Runspace.SessionStateProxy.SetVariable("WuTimeMinutes",$WuTimeMinutes)
        $code = {
            [INT]$I = 0
            ForEach ( $ServerIpAddress in  $WuServerIpAddress.Split(',') ) {
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployWUStart.Value = $I } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox8.AddText(" Connecting to $ServerIpAddress `n") } )
                $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ("$ServerIpAddress\$WuAdminUserName", $(ConvertTo-SecureString -String $WuAdminPassword -AsPlainText -Force))
                Set-Item WSMan:\localhost\Client\TrustedHosts -Value "$ServerIpAddress" -Force
                Try { $PsSession = New-PSSession -ComputerName $ServerIpAddress -Credential $Credential -ErrorAction Stop }
                    Catch {
                    $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployWUStart.Visibility = "Hidden" } )
                    $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.LabelStatusDeployWUStart.Content = "Connection Failure $(' .'*130)$(' '*30)Please check Server - Username - Password" } )
                    $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployWUStart.IsEnabled = $True } )
                    $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployWUStart.Visibility = "Visible"  } )
                    Return
                    }
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox8.AddText(" Assembling c:\windows\WindowsUpdate.ps1 `n") } )
			    $Job = Invoke-Command -Session $PsSession -AsJob -JobName 'Assemble c:\windows\WindowsUpdate.ps1' -ScriptBlock {
                    $Script = @'
Set-Service -Name 'wuauserv' -StartupType 'Manual'
Start-Service -Name 'wuauserv'
# Create Objects Microsoft.Update.* to Search-Download-Install Windows Updates
# $WindowsUpdateServiceManager = New-Object -ComObject 'Microsoft.Update.ServiceManager'
# Default Service = 'Windows Server Update Service' (Cfr GPO)
$WindowsUpdateSearch = New-Object -ComObject 'Microsoft.Update.Searcher'
$WindowsUpdateDownload = New-Object -ComObject 'Microsoft.Update.Downloader'
$WindowsUpdateInstall = New-Object -ComObject 'Microsoft.Update.Installer'
# Search-Download-Install Windows Updates
Try	{ $WindowsUpdateList = $WindowsUpdateSearch.Search($Null).Updates }
	Catch { Write-Output 'WSUS not Reachable. No Internet Connection. Please Check DNS & Gateway Config.' }
If	( $WindowsUpdateList.Count -gt 0 )
		{
        $WindowsUpdateDownload.Updates = $WindowsUpdateList
		$WindowsUpdateDownload.Download()
		$WindowsUpdateInstall.Updates = $WindowsUpdateList
		$WindowsUpdateInstall.Install()
        }
# Report Windows Updates to CSV File 'c:\windows\logs\WindowsUpdate.csv'
[PSCustomObject[]]$Table = $Null
Foreach	( $Update in $WindowsUpdateList ) 
		{ $Table += [PSCustomObject] @{
    			'DateTime' = (Get-Date).tostring('dd-MM-yyyy HH:mm:ss')
                'Title' = [STRING]$Update.Title
                'CategoriesName' = [STRING]$Update.Categories._NewEnum.Name
                'BundledUpdatesTitle' = [STRING]$Update.BundledUpdates._NewEnum.Title
                'BundledUpdatesLastDeploymentChangeTime' = [STRING]$Update.BundledUpdates._NewEnum.LastDeploymentChangeTime
                'BundledUpdatesMinDownloadSize' = [STRING]$Update.BundledUpdates._NewEnum.MinDownloadSize
                'KBArticleIDs' = [STRING]$Update.KBArticleIDs
			}
		}
$Table | Select-Object -Property DateTime,Title,CategoriesName,BundledUpdatesTitle,BundledUpdatesLastDeploymentChangeTime,BundledUpdatesMinDownloadSize,KBArticleIDs | Export-Csv -Path 'c:\windows\logs\WindowsUpdate.csv' -Append -Force -NoTypeInformation
# Change WindowsUpdate Service to Disabled
Set-Service -Name 'wuauserv' -StartupType 'Disabled'
# Restart Computer for applying Windows Updates
Shutdown.exe /r /t 5 /f /c 'Scheduled Windows Updates with Reboot' /d p:0:0
'@
                    $Script | Out-File -FilePath 'c:\windows\WindowsUpdate.ps1' -Force
                    }
                While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 5 ; If ( $I -ge 100 ) { $I = 1 }; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployWUStart.Value = $I } ) }
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox8.AddText(" Creating Scheduled Job CMscripts\WindowsUpdate `n") } )
			    $Job = Invoke-Command -Session $PsSession -AsJob -JobName 'Creating Scheduled Job CMscripts\WindowsUpdate' -ScriptBlock {
					Param([INT]$WuDayOfWeek,[INT]$WuTimeHour,[INT]$WuTimeMinutes)
					$DAY = ('MON','TUE','WED','THU','FRI','SAT','SUN')[$WuDayOfWeek]
					$Hour = ('00','01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23')[$WuTimeHour]
					$MIN = ('00','10','20','30','40','50')[$WuTimeMinutes]
					$TIME = "$($Hour):$($MIN)"
					schtasks.exe /CREATE /RU SYSTEM /SC Weekly /MO 1 /D $DAY /ST $TIME /TN CMscripts\WindowsUpdate /TR "Powershell.exe -File '$Env:Windir\WindowsUpdate.ps1'"
					} -ArgumentList ($WuDayOfWeek,$WuTimeHour,$WuTimeMinutes)
                While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 5 ; If ( $I -ge 100 ) { $I = 1 }; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployWUStart.Value = $I } ) }
                }
            Get-Job | Select-Object -Property Name, State, Command, @{Name='Error';Expression={ $_.ChildJobs[0].JobStateInfo.Reason }} | Export-Csv -Path "$env:windir\Logs\PushTheButtonJobs.csv" -NoTypeInformation -Force
            If ((Get-Job).Where({$_.State -eq 'Failed'}).count -ne 0 ) 
                {
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployWUStart.Visibility = "Hidden" } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.LabelStatusDeployWUStart.Content = "Deployment Finished with ERRORS $(' .'*115)$(' '*30)Please consult PushTheButtonJobs.csv" } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployWUtart.IsEnabled = $True } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployWUStart.Visibility = "Visible" } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployUserStart.IsEnabled = $True } )
                }
                Else 
                {
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployWUStart.Visibility = "Hidden" } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.LabelStatusDeployWUStart.Content = "Deployment Finished $(' .'*135)$(' '*30)" } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployO365Start.IsEnabled = $True } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployWUStart.IsEnabled = $True } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployUserStart.IsEnabled = $True } )                				
                }
			}
        $PSinstance = [powershell]::Create().AddScript($Code)
        $PSinstance.Runspace = $Runspace
        $job = $PSinstance.BeginInvoke()
		}
	Function DeployUserStart {
		Param($syncHash,$ServerIpAddress,$AdminUserName,$AdminPassword, $USEROstFolderRootPath, $USERDataFolderRootPath, $PrincipalName,$UserGivenName,$UserSurname,$Department,$HomeDirectory,$HomeDrive,$UsersOuPath,$DomainDnsName,$DomainNetbiosName)
        $Runspace = [runspacefactory]::CreateRunspace()
        $Runspace.ApartmentState = "STA"
        $Runspace.ThreadOptions = "ReuseThread"
        $Runspace.Open()
        $Runspace.SessionStateProxy.SetVariable("syncHash",$syncHash)
		$Runspace.SessionStateProxy.SetVariable("ServerIpAddress",$ServerIpAddress)
		$Runspace.SessionStateProxy.SetVariable("AdminUserName",$AdminUserName)
		$Runspace.SessionStateProxy.SetVariable("AdminPassword",$AdminPassword)
		$Runspace.SessionStateProxy.SetVariable("USEROstFolderRootPath",$USEROstFolderRootPath)
		$Runspace.SessionStateProxy.SetVariable("USERDataFolderRootPath",$USERDataFolderRootPath)
		$Runspace.SessionStateProxy.SetVariable("PrincipalName",$PrincipalName)
		$Runspace.SessionStateProxy.SetVariable("UserGivenName",$UserGivenName)
		$Runspace.SessionStateProxy.SetVariable("UserSurname",$UserSurname)
		$Runspace.SessionStateProxy.SetVariable("Department",$Department)
		$Runspace.SessionStateProxy.SetVariable("UsersOuPath",$UsersOuPath)
		$Runspace.SessionStateProxy.SetVariable("DomainDnsName",$DomainDnsName)
		$Runspace.SessionStateProxy.SetVariable("DomainNetbiosName",$DomainNetbiosName)
        $code = {
            [INT]$I = 0
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployUserStart.Value = $I } )
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox6.AddText(" Connecting to $ServerIpAddress `n") } )
	        $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ("$ServerIpAddress\$AdminUserName", $(ConvertTo-SecureString -String $AdminPassword -AsPlainText -Force))
            Set-Item WSMan:\localhost\Client\TrustedHosts -Value "$ServerIpAddress" -Force
            Try { $PsSession = New-PSSession -ComputerName $ServerIpAddress -Credential $Credential -ErrorAction Stop }
                    Catch {
                    $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployUserStart.Visibility = "Hidden" } )
                    $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.LabelStatusDeployUserStart.Content = "Connection Failure $(' .'*130)$(' '*30)Please check Server - Username - Password" } )
                    $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployUserStart.IsEnabled = $True } )
                    $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployUserStart.Visibility = "Visible"  } )
                    Return
                    }
            [STRING]$RandomPasswordPlainText = ((([char[]](65..90) | sort {get-random})[0..2] + ([char[]](33,35,36,37,42,43,45) | sort {get-random})[0] + ([char[]](97..122) | sort {get-random})[0..4] + ([char[]](48..57) | sort {get-random})[0]) | get-random -Count 10) -join ''
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBoxUserPassword.Text = $RandomPasswordPlainText } )
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox6.AddText(" Creating User $PrincipalName in $UsersOuPath `n") } )
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox6.AddText(" With Password $RandomPasswordPlainText `n") } )
            $Job = Start-Job -Name 'Active Directory Add User' -ScriptBlock {
                    Param ($PrincipalName,$UserGivenName,$UserSurname,$Department,$UsersOuPath,$DomainDnsName,$RandomPasswordPlainText)
                    $NewUserParams = @{
                    	    'UserPrincipalName' = "$($PrincipalName)@$($DomainDnsName)"
		                    'DisplayName' = $PrincipalName
		                    'Name' = $PrincipalName
		                    'SamAccountName' = $PrincipalName
                        	'GivenName' = $UserGivenName
                        	'Surname' = $UserSurname
            		        'Description' = $ClearmediaAdminUserName
                        	'Department' = $Department
                        	'Enabled' = $TRUE
	                        'ChangePasswordAtLogon' = $FALSE
		                    'AccountPassword' =  ConvertTo-SecureString $RandomPasswordPlainText -AsPlainText -Force
	                        'Path' = $UsersOuPath
				            'HomeDirectory' = "E:\users\$PrincipalName"
                             }
                    New-ADUser @NewUserParams -ErrorAction Stop
                    } -ArgumentList ($PrincipalName,$UserGivenName,$UserSurname,$Department,$UsersOuPath,$DomainDnsName,$RandomPasswordPlainText)
            While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployUserStart.Value = $I } ) }
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox6.AddText(" Creating User OST Folder `n") } )
	        $Job = Invoke-Command -ComputerName "$ServerIpAddress" -Credential $Credential  -AsJob -JobName  'Create User OST Folder' -ScriptBlock {
                    Param ($USEROstFolderRootPath,$PrincipalName,$DomainNetbiosName)
                    [STRING]$FolderPath = "D:\Users\$PrincipalName"
                    New-Item -Path $FolderPath -type directory -Force
					# Add ACL Modify to PrincipalName on FolderPath
                    $ACL = Get-Acl  -Path  $FolderPath
                    $AccessRule = New-Object system.security.AccessControl.FileSystemAccessRule("$DomainNetbiosName\$PrincipalName", 'Modify', 'ObjectInherit,ContainerInherit', 'None', 'Allow')
                    $ACL.AddAccessRule($AccessRule)
                    Set-Acl  -Path $FolderPath -AclObject $ACL
                    } -ArgumentList ($USEROstFolderRootPath,$PrincipalName,$DomainNetbiosName)
            While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployUserStart.Value = $I } ) }
            $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.TextBlockOutBox6.AddText(" Creating User DATA Folder `n") } )
	        $Job = Invoke-Command -ComputerName "$ServerIpAddress" -Credential $Credential  -AsJob -JobName  'Create User Data Folder' -ScriptBlock {
                    Param ($USERDataFolderRootPath,$PrincipalName,$DomainNetbiosName)
                    [STRING]$FolderPath = "E:\Users\$PrincipalName"
                    New-Item -Path $FolderPath -type directory -Force
					# Add ACL Modify to PrincipalName on FolderPath
                    $ACL = Get-Acl  -Path  $FolderPath
                    $AccessRule = New-Object system.security.AccessControl.FileSystemAccessRule("$DomainNetbiosName\$PrincipalName", 'Modify', 'ObjectInherit,ContainerInherit', 'None', 'Allow')
                    $ACL.AddAccessRule($AccessRule)
                    Set-Acl  -Path $FolderPath -AclObject $ACL
                    New-Item -Path "$FolderPath\Documents" -type directory -Force
                    } -ArgumentList ($USERDataFolderRootPath,$PrincipalName,$DomainNetbiosName)
            While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployUserStart.Value = $I } ) }
            Get-Job | Select-Object -Property Name, State, Command, @{Name='Error';Expression={ $_.ChildJobs[0].JobStateInfo.Reason }} | Export-Csv -Path "$env:windir\Logs\PushTheButtonJobs.csv" -NoTypeInformation -Force
            If ((Get-Job).Where({$_.State -eq 'Failed'}).count -ne 0 ) 
                {
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployUserStart.Visibility = "Hidden" } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.LabelStatusDeployUserStart.Content = "User Added with ERRORS $(' .'*115)$(' '*30)Please consult PushTheButtonJobs.csv" } )
                							
                }
                Else 
                {
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.ProgressBarProgressDeployUserStart.Visibility = "Hidden" } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.LabelStatusDeployUserStart.Content = "User Added $(' .'*135)$(' '*30)" } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployO365Start.IsEnabled = $True } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployWUStart.IsEnabled = $True } )
                $syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployUserStart.IsEnabled = $True } )                				                								
                }
			$syncHash.Window.Dispatcher.invoke( [action]{ $syncHash.DeployUserStart.Visibility = "Visible"  } )	
            }
        $PSinstance = [powershell]::Create().AddScript($Code)
        $PSinstance.Runspace = $Runspace
        $job = $PSinstance.BeginInvoke()
		}

# AutoFind ( WPF - Windows Presentation Framework ) Controls
	$XAML.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]")  | ForEach-Object { $syncHash.Add($_.Name, $syncHash.Window.Findname($_.Name)) }

# Init ( WPF - Windows Presentation Framework ) Actions
    $syncHash.DeployDcStart.Add_Click({
        $syncHash.DeployDcStart.IsEnabled = $False
	    $syncHash.DeployOUStart.IsEnabled = $False
        $syncHash.DeployStandardGpoStart.IsEnabled = $False
        $syncHash.DeployFolderRedirectionStart.IsEnabled = $False
        $syncHash.DeployRdsStart.IsEnabled = $False		
        $syncHash.DeployO365Start.IsEnabled = $False
        $syncHash.DeployWUStart.IsEnabled = $False
        $syncHash.DeployUserStart.IsEnabled = $False
        $syncHash.LabelStatusDeployDcStart.Visibility = "Visible"
        $syncHash.ProgressBarProgressDeployDcStart.Visibility = "Visible"
	    DeployDcStart -syncHash $syncHash -DnsForwarder $syncHash.TextBoxDnsServerForwarders.Text -DomainNetbiosName $SyncHash.TextBoxDomainNetbiosName.Text -DomainDnsName $SyncHash.TextBoxDomainDnsName.Text
        # $SyncHash.host.ui.WriteVerboseLine($SyncHash.TextBoxDomainNetbiosName.Text)
        })
    $syncHash.DeployDcReboot.Add_Click({ Restart-Computer })
    $syncHash.DeployOUStart.Add_Click({
        $syncHash.DeployDcStart.IsEnabled = $False
	    $syncHash.DeployOUStart.IsEnabled = $False
        $syncHash.DeployStandardGpoStart.IsEnabled = $False
        $syncHash.DeployFolderRedirectionStart.IsEnabled = $False
        $syncHash.DeployRdsStart.IsEnabled = $False		
        $syncHash.DeployO365Start.IsEnabled = $False
        $syncHash.DeployWUStart.IsEnabled = $False
        $syncHash.DeployUserStart.IsEnabled = $False
        $syncHash.LabelStatusDeployOUStart.Visibility = "Visible"
        $syncHash.ProgressBarProgressDeployOUStart.Visibility = "Visible"
	    DeployOUStart -syncHash $syncHash -ManagedOuName $syncHash.TextBoxManagedOuName.Text -ClearmediaAdminUserName $SyncHash.TextBoxClearmediaAdminUserName.Text -ClearmediaAdminPassword $SyncHash.TextBoxClearmediaAdminPassword.Text
        # $SyncHash.host.ui.WriteVerboseLine($SyncHash.TextBoxDomainNetbiosName.Text)
        })
    $syncHash.DeployStandardGpoStart.Add_Click({
        $syncHash.DeployDcStart.IsEnabled = $False
	    $syncHash.DeployOUStart.IsEnabled = $False
        $syncHash.DeployStandardGpoStart.IsEnabled = $False
        $syncHash.DeployFolderRedirectionStart.IsEnabled = $False
        $syncHash.DeployRdsStart.IsEnabled = $False		
        $syncHash.DeployO365Start.IsEnabled = $False
        $syncHash.DeployWUStart.IsEnabled = $False
        $syncHash.DeployUserStart.IsEnabled = $False
        $syncHash.LabelStatusDeployStandardGpoStart.Visibility = "Visible"
        $syncHash.ProgressBarProgressDeployStandardGpoStart.Visibility = "Visible"
	    DeployStandardGpoStart -syncHash $syncHash -TemplateSourcePath $syncHash.TextBoxTemplateSourcePath.Text -RdsOuPath $SyncHash.TextBoxRdsOuPath.Text -UsersOuPath $SyncHash.TextBoxUsersOuPath.Text -OstPath $SyncHash.TextBoxOstPath.Text -CheckBoxCopyAdmFiles $SyncHash.CheckBoxCopyAdmFiles.IsChecked -CheckBoxStandardRdsServerPolicy $SyncHash.CheckBoxStandardRdsServerPolicy.IsChecked -CheckBoxStandardServerWindowsUpdate $SyncHash.CheckBoxStandardServerWindowsUpdate.IsChecked -CheckBoxStandardUserPolicy $SyncHash.CheckBoxStandardUserPolicy.IsChecked -CheckBoxStandardHardwareAccelerationUserPolicy $SyncHash.CheckBoxStandardHardwareAccelerationUserPolicy.IsChecked -CheckBoxStandardO365UserPolicy $SyncHash.CheckBoxStandardO365UserPolicy.IsChecked -CheckBoxStandardOutlookUserPolicy $SyncHash.CheckBoxStandardOutlookUserPolicy.IsChecked
        #$SyncHash.host.ui.WriteVerboseLine($SyncHash.CheckBoxStandardRdsServerPolicy.IsChecked)
        })
    $syncHash.DeployFolderRedirectionStart.Add_Click({
        $syncHash.DeployDcStart.IsEnabled = $False
	    $syncHash.DeployOUStart.IsEnabled = $False
        $syncHash.DeployStandardGpoStart.IsEnabled = $False
        $syncHash.DeployFolderRedirectionStart.IsEnabled = $False
        $syncHash.DeployRdsStart.IsEnabled = $False		
        $syncHash.DeployO365Start.IsEnabled = $False
        $syncHash.DeployWUStart.IsEnabled = $False
        $syncHash.DeployUserStart.IsEnabled = $False
        $syncHash.LabelStatusDeployFolderRedirectionStart.Visibility = "Visible"
        $syncHash.ProgressBarProgressDeployFolderRedirectionStart.Visibility = "Visible"
	    DeployFolderRedirectionStart -syncHash $syncHash -CheckBoxDocuments $syncHash.CheckBoxDocuments.IsChecked -DocumentsPath $syncHash.TextBoxDocumentsPath.Text -CheckBoxMusic $syncHash.CheckBoxMusic.IsChecked -MusicPath $syncHash.TextBoxMusicPath.Text -CheckBoxPictures $syncHash.CheckBoxPictures.IsChecked -PicturesPath $syncHash.TextBoxPicturesPath.Text -CheckBoxVideos $syncHash.CheckBoxVideos.IsChecked -VideosPath $syncHash.TextBoxVideosPath.Text -UsersOuPath $SyncHash.TextBoxUsersOuPath.Text
        #$SyncHash.host.ui.WriteVerboseLine($SyncHash.CheckBoxStandardRdsServerPolicy.IsChecked)
        })
    $syncHash.DeployRdsStart.Add_Click({
        $syncHash.DeployRdsStart.IsEnabled = $False		
        $syncHash.DeployO365Start.IsEnabled = $False
        $syncHash.DeployWUStart.IsEnabled = $False
        $syncHash.DeployUserStart.IsEnabled = $False
        $syncHash.LabelStatusDeployRdsStart.Content = "In Progress ...."
        $syncHash.LabelStatusDeployRdsStart.Visibility = "Visible"
        $syncHash.ProgressBarProgressDeployRdsStart.Visibility = "Visible"
	    DeployRdsStart -syncHash $syncHash -RdsServerIpAddress  $syncHash.TextBoxRdsServerIpAddress.Text -RdsServerName $syncHash.TextBoxRdsServerName.Text -AdminUserName $syncHash.TextBoxAdminUserName.Text -AdminPassword $syncHash.TextBoxAdminPassword.Text -OstFolderRootPath $syncHash.TextBoxOstFolderRootPath.Text -DataFolderRootPath $syncHash.TextBoxDataFolderRootPath.Text -RdsOuPath $SyncHash.TextBoxRdsOuPath.Text -DomainDnsName $SyncHash.TextBoxDomainDnsName.Text -CheckBoxRas $SyncHash.CheckBoxRasx.IsChecked  -RasLicenseEmail $syncHash.TextBoxRasLicenseEmailx.Text -RasLicensePassword $syncHash.TextBoxRasLicensePasswordx.Text -CheckBoxRasKey $SyncHash.CheckBoxRasKeyx.IsChecked -RasKey $syncHash.TextBoxRasKeyx.Text
        })
    $syncHash.DeployRdsReboot.Add_Click({
        $syncHash.DeployRdsReboot.Visibility = "Hidden"
        $syncHash.ProgressBarProgressDeployRdsStart.Visibility = "Hidden"
        $syncHash.DeployO365Start.IsEnabled = $True
        $syncHash.DeployWUStart.IsEnabled = $True	
        $syncHash.DeployUserStart.IsEnabled = $True
        DeployRdsReboot -syncHash $syncHash -RdsServerIpAddress  $syncHash.TextBoxRdsServerIpAddress.Text -AdminUserName $syncHash.TextBoxAdminUserName.Text -AdminPassword $syncHash.TextBoxAdminPassword.Text
        })
    $syncHash.DeployO365Start.Add_Click({
        $syncHash.DeployRdsStart.IsEnabled = $False
        $syncHash.DeployO365Start.IsEnabled = $False
        $syncHash.DeployWUStart.IsEnabled = $False
        $syncHash.DeployUserStart.IsEnabled = $False
        $syncHash.LabelStatusDeployO365Start.Content = "In Progress ...."
        $syncHash.LabelStatusDeployO365Start.Visibility = "Visible"
        $syncHash.ProgressBarProgressDeployO365Start.Visibility = "Visible"
	    DeployO365Start -syncHash $syncHash -ServerIpAddressList $syncHash.TextBoxO365ServerIpAddress.Text -AdminUserName $syncHash.TextBoxO365AdminUserName.Text -AdminPassword $syncHash.TextBoxO365AdminPassword.Text -CheckBoxExcludeApp $SyncHash.CheckBoxExcludeApp.IsChecked -RadioButton1 $SyncHash.RadioButton1.IsChecked -RadioButton2 $SyncHash.RadioButton2.IsChecked -RadioButton3 $SyncHash.RadioButton3.IsChecked -RadioButton4 $SyncHash.RadioButton4.IsChecked
        })
    $syncHash.DeployWUStart.Add_Click({
        $syncHash.DeployDcStart.IsEnabled = $False
	    $syncHash.DeployOUStart.IsEnabled = $False
        $syncHash.DeployStandardGpoStart.IsEnabled = $False
        $syncHash.DeployFolderRedirectionStart.IsEnabled = $False
        $syncHash.DeployRdsStart.IsEnabled = $False		
        $syncHash.DeployO365Start.IsEnabled = $False
        $syncHash.DeployWUStart.IsEnabled = $False
        $syncHash.DeployUserStart.IsEnabled = $False
        $syncHash.LabelStatusDeployWUStart.Content = "In Progress ...."
        $syncHash.LabelStatusDeployWUStart.Visibility = "Visible"
        $syncHash.ProgressBarProgressDeployWUStart.Visibility = "Visible"
	    DeployWUStart -syncHash $syncHash -WuServerIpAddress $syncHash.TextBoxWuServerIpAddress.Text -WuAdminUserName $syncHash.TextBoxWuAdminUserName.Text -WuAdminPassword $syncHash.TextBoxWuAdminPassword.Text -WuDayOfWeek $syncHash.ComboBoxWuDayOfWeek.SelectedIndex -WuTimeHour $syncHash.ComboBoxWuTimeHour.SelectedIndex -WuTimeMinutes $syncHash.ComboBoxWuTimeMinutes.SelectedIndex
        })
    $syncHash.DeployUserStart.Add_Click({
        $syncHash.DeployDcStart.IsEnabled = $False
	    $syncHash.DeployOUStart.IsEnabled = $False
        $syncHash.DeployStandardGpoStart.IsEnabled = $False
        $syncHash.DeployFolderRedirectionStart.IsEnabled = $False
        $syncHash.DeployRdsStart.IsEnabled = $False		
        $syncHash.DeployO365Start.IsEnabled = $False
        $syncHash.DeployWUStart.IsEnabled = $False
        $syncHash.DeployUserStart.IsEnabled = $False
        $syncHash.LabelStatusDeployUserStart.Content = "In Progress ...."
        $syncHash.LabelStatusDeployUserStart.Visibility = "Visible"
        $syncHash.ProgressBarProgressDeployUserStart.Visibility = "Visible"
	    DeployUserStart -syncHash $syncHash -ServerIpAddress $syncHash.TextBoxDeployUSERServerIpAddress.Text -AdminUserName $syncHash.TextBoxDeployUSERAdminUserName.Text -AdminPassword $syncHash.TextBoxDeployUSERAdminPassword.Text -USEROstFolderRootPath $syncHash.TextBoxDeployUSEROstFolderRootPath -USERDataFolderRootPath $syncHash.TextBoxDeployUSERUserDataFolderRootPath -PrincipalName $syncHash.TextBoxUserPrincipalName.Text -UserGivenName $syncHash.TextBoxUserGivenName.Text -UserSurname $syncHash.TextBoxUserSurname.Text -Department $syncHash.TextBoxDepartment.Text -UsersOuPath $syncHash.TextBoxUsersOuPath.Text -DomainDnsName $SyncHash.TextBoxDomainDnsName.Text -DomainNetbiosName $SyncHash.TextBoxDomainNetbiosName.Text
        #$SyncHash.host.ui.WriteVerboseLine($SyncHash.CheckBoxStandardRdsServerPolicy.IsChecked)
        })

# End ( WPF - Windows Presentation Framework ) Process on Exit
   $syncHash.Window.Add_Closing( { [System.Windows.Forms.Application]::Exit() ; Stop-Process $PID } )
 
# Start ( WPF - Windows Presentation Framework ) Process 
   $syncHash.Window.ShowDialog()
