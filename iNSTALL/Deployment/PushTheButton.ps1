# Push Current Directory
Push-Location %0\..\
# Copy Shortcut to current Desktop
Copy-Item -Path '.\PushButton.lnk' -Destination "$Env:USERPROFILE\Desktop" -Force

# Init History
If ( -Not ( Test-Path -Path 'HKLM:\Software\ClearMedia' ) ) { New-Item -Path  'HKLM:\Software\ClearMedia' }
If ( -Not ( Test-Path -Path 'HKLM:\Software\ClearMedia\PushTheButton' ) ) { New-Item -Path  'HKLM:\Software\ClearMedia\PushTheButton' }

# Check History
Try { $DeployFirebox = Get-ItemPropertyValue -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'DeployFirebox' }
    Catch { $DeployFirebox = 'Visible' }
Try { $FireboxExternalIp = Get-ItemPropertyValue -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'FireboxExternalIp' }
    Catch { $FireboxExternalIp = '172.16.X.Y' }
Try { $FireboxExternalIpGatewayCIDR = Get-ItemPropertyValue -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'FireboxExternalIpGatewayCIDR' }
    Catch { $FireboxExternalIpGatewayCIDR = '172.16.X.Z/24' }
Try { $DeployDcStart = Get-ItemPropertyValue -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'DeployDcStart' }
    Catch { $DeployDcStart = 'Visible' }
Try { $DomainNetbiosName = Get-ItemPropertyValue -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'DomainNetbiosName' }
    Catch { $DomainNetbiosName = 'ClearMedia' }
Try { $DomainDNSName = Get-ItemPropertyValue -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'DomainDNSName' }
    Catch { $DomainDNSName = 'ClearMedia.cloud' }
Try { $DnsServerForwarders = Get-ItemPropertyValue -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'DnsServerForwarders' }
    Catch { $DnsServerForwarders = '195.238.2.21,195.238.2.22,8.8.8.8' }
Try { $DeployOuStart = Get-ItemPropertyValue -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'DeployOuStart' }
    Catch { $DeployOuStart = 'Visible' }
Try { $DeployStandardGpoStart = Get-ItemPropertyValue -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'DeployStandardGpoStart' }
    Catch { $DeployStandardGpoStart = 'Visible' }
Try { $DeployFolderRedirectionStart = Get-ItemPropertyValue -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'DeployFolderRedirectionStart' }
    Catch { $DeployFolderRedirectionStart = 'Visible' }
Try { $ManagedOuName = Get-ItemPropertyValue -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'ManagedOuName' }
    Catch { $ManagedOuName = 'SME' }
$ADRootDSE = $(($DomainDNSName.Replace('.',',DC=')).Insert(0,'DC='))
Try { $RdsOuPath = Get-ItemPropertyValue -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'RdsOuPath' }
    Catch { $RdsOuPath = "OU=RDS,OU=Servers,OU=$ManagedOuName,$ADRootDSE" }
Try { $UsersOuPath = Get-ItemPropertyValue -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'UsersOuPath' }
    Catch { $UsersOuPath = "OU=Users,OU=$ManagedOuName,$ADRootDSE" }
Try { $DomainDcServerName = Get-ItemPropertyValue -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'DomainDcServerName' }
    Catch { $DomainDcServerName = "$env:COMPUTERNAME" }
Try { $DomainDnsServerIpAddress = Get-ItemPropertyValue -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'DomainDnsServerIpAddress' }
    Catch { $DomainDnsServerIpAddress = Get-NetIPAddress | Where-Object { ( $PSItem.InterfaceAlias -like 'Ethernet?' ) -and ( $PSItem.AddressFamily -eq 'IPv4' ) } | Select-Object -ExpandProperty IpAddress }
Try { $FSLogixFolderRootPath = Get-ItemPropertyValue -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'FSLogixFolderRootPath' }
    Catch { $FSLogixFolderRootPath = 'D:\Users' }
Try { $DataFolderRootPath = Get-ItemPropertyValue -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'DataFolderRootPath' }
    Catch { $DataFolderRootPath = 'E:\Users' }

# Set Full Screen WXGA 1280 x 800
Set-DisplayResolution -Width 1280 -Height 800 -Force

# Load Assembly ( WPF - Windows Presentation Framework )
Add-Type -AssemblyName PresentationFramework

# Init Synchronized HashTable for RunSpaces AKA MultiThreading
$SyncHash = [hashtable]::Synchronized(@{})
$SyncHash.Host = $Host

# Init  ( WPF - Windows Presentation Framework ) XAML Config
[XML]$XAML = @"
 <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="PushTheButton" Width="1280" Height="800" WindowState="Maximized"  ShowInTaskbar = "True" Topmost="False">
    <Grid>
        <TabControl HorizontalAlignment="Left" Width="1260" Height="730" Margin="10,0,0,0" VerticalAlignment="Top">
            <TabControl.Resources>
                <Style TargetType="TabItem">
                    <Setter Property="Template">
                        <Setter.Value>
                            <ControlTemplate TargetType="TabItem">
                                <Border Name="Border" BorderBrush="Gainsboro" BorderThickness="1,1,1,0" CornerRadius="8,8,8,8" Margin="3,2">
                                    <ContentPresenter Name="ContentSite" Margin="10,2" HorizontalAlignment="Center" VerticalAlignment="Center" ContentSource="Header"/>
                                </Border>
                                <ControlTemplate.Triggers>
                                    <Trigger Property="IsSelected" Value="True">
                                        <Setter TargetName="Border" Property="Background" Value="LightSkyBlue"/>
                                    </Trigger>
                                    <Trigger Property="IsSelected" Value="False">
                                        <Setter TargetName="Border" Property="Background" Value="GhostWhite"/>
                                    </Trigger>
                                </ControlTemplate.Triggers>
                            </ControlTemplate>
                        </Setter.Value>
                    </Setter>
                </Style>
            </TabControl.Resources>
            <TabItem Name="DeployFirebox" Header="   Deploy FireboxV   ">
                <Grid Background="#FFE5E5E5">
                    <Label Name="LabelFireboxIpAddress" Content="Firebox Intenal IP Address" HorizontalAlignment="Left" Height="28" Margin="30,28,0,0" VerticalAlignment="Top" Width="165"/>
                    <Label Name="LabelFireboxAdminUserName" Content="Firebox Admin Name" HorizontalAlignment="Left" Height="28" Margin="30,61,0,0" VerticalAlignment="Top" Width="165"/>
                    <Label Name="LabelFireboxAdminPassword" Content="Firebox Admin Password" HorizontalAlignment="Left" Height="28" Margin="30,94,0,0" VerticalAlignment="Top" Width="165"/>
                    <Label Name="LabelFireboxExternalIp" Content="Firebox External NAT IP" HorizontalAlignment="Left" Height="28" Margin="550,28,0,0" VerticalAlignment="Top" Width="250"/>
                    <Label Name="LabelFireboxExternalIpGatewayCIDR" Content="Firebox Default Gateway IP CIDR" HorizontalAlignment="Left" Height="28" Margin="550,61,0,0" VerticalAlignment="Top" Width="250"/>
                    <TextBox Name="TextBoxFireboxIpAddress"  HorizontalAlignment="Left" Height="22" Margin="220,32,0,0" Text="192.168.13.254" VerticalAlignment="Top" Width="180"/>
                    <TextBox Name="TextBoxFireboxAdminUserName" HorizontalAlignment="Left" Height="22" Margin="220,65,0,0" Text="admin" VerticalAlignment="Top" Width="180"/>
                    <TextBox Name="TextBoxFireboxAdminPassword" HorizontalAlignment="Left" Height="22" Margin="220,98,0,0" Text="readwrite" VerticalAlignment="Top" Width="180"/>
                    <TextBox Name="TextBoxFireboxExternalIp" HorizontalAlignment="Left" Height="22" Margin="760,32,0,0" Text="$FireboxExternalIp" VerticalAlignment="Top" Width="180" ToolTip="Please Fill in IP Address for NIC 0 - You will find Info in the Virtual Machines Section of the vApp under My Cloud"/>
                    <TextBox Name="TextBoxFireboxExternalIpGatewayCIDR" HorizontalAlignment="Left" Height="22" Margin="760,65,0,0" Text="$FireboxExternalIpGatewayCIDR" VerticalAlignment="Top" Width="180" ToolTip="Please Fill in Network CIDR - You will find Info in the Org VDC Networks Section of the VDC under Administration"/>
                    <ScrollViewer VerticalScrollBarVisibility="Auto" Margin="2,250,0,0" Height="380" Width="1256"  HorizontalScrollBarVisibility="Disabled">
						<TextBlock Name="TextBlockOutBoxFirebox" Text="" Foreground="WHITE" Background="#FF22206F" />
                    </ScrollViewer>
                    <Border Name="BorderDeployFireboxStart" CornerRadius="220" Padding="20,20,20,20" Width="220" Height="220" VerticalAlignment="Top" HorizontalAlignment="Left"  Margin="1000,28,0,0" Visibility="$DeployFirebox" ToolTip="Push It real Good" ToolTipService.ShowDuration="1000">
                        <Border.Background>
                            <LinearGradientBrush StartPoint="0,0" EndPoint="0,1">
								<GradientStop Color="DarkGreen" Offset="0.4" />
								<GradientStop Color="Black" Offset="0.8" />
                            </LinearGradientBrush>
                        </Border.Background>
                        <Button Name="ButtonFireboxStart" Content="START" BorderBrush="Transparent" Background="Red" Foreground="Blue" FontSize="50" FontWeight="Bold">
                            <Button.Resources>
                                <Style TargetType="{x:Type Border}">
                                    <Setter Property="CornerRadius" Value="220"/>
                                </Style>
                            </Button.Resources>
                        </Button>
                    </Border>
                    <StatusBar Name="StatusBarFirebox" HorizontalAlignment="Left" Height="24" Margin="2,670,0,0" VerticalAlignment="Top" Width="1256" Background="#FFD6D2B0" >
                        <Label Name="LabelStatusFirebox" Content="In Progress ...." Height="25" FontSize="12" VerticalAlignment="Center" HorizontalAlignment="Center"  Visibility="Hidden" />
                        <ProgressBar Name="ProgressBarFirebox" Width="1150" Height="15" Value="1" Visibility="Hidden" />
                    </StatusBar>
                </Grid>
            </TabItem>
            <TabItem Name="TabItemDeployDC" Header="   Deploy DC   ">
                <Grid Background="#FFE5E5E5">
                    <Label Name="LabelDomainNetbiosName" Content="Domain NetbiosName" HorizontalAlignment="Left" Height="28" Margin="30,28,0,0" VerticalAlignment="Top" Width="165"/>
                    <Label Name="LabelDomainName" Content="Domain Name" HorizontalAlignment="Left" Height="28" Margin="30,61,0,0" VerticalAlignment="Top" Width="165"/>
                    <Label Name="LabelDnsServerForwarders" Content="Dns Server Forwarders" HorizontalAlignment="Left" Height="28" Margin="30,94,0,0" VerticalAlignment="Top" Width="165"/>
                    <Label Name="LabelSafeModeAdministratorPassword" Content="AD Restore Mode Password" HorizontalAlignment="Left" Height="28" Margin="30,127,0,0" VerticalAlignment="Top" Width="165"/>
                    <TextBox Name="TextBoxDomainNetbiosName"  HorizontalAlignment="Left" Height="22" Margin="220,28,0,0" Text="$DomainNetbiosName" VerticalAlignment="Top" Width="180" ToolTip="Fill in Domain NetbiosName - Please limit to 15 Characters"/>
                    <TextBox Name="TextBoxDomainDnsName" HorizontalAlignment="Left" Height="22" Margin="220,61,0,0" Text="$DomainDNSName" VerticalAlignment="Top" Width="180"/>
                    <TextBox Name="TextBoxDnsServerForwarders" HorizontalAlignment="Left" Height="22" Margin="220,94,0,0" Text="$DnsServerForwarders" VerticalAlignment="Top" Width="180"/>
                    <TextBox Name="TextBoxSafeModeAdministratorPassword" HorizontalAlignment="Left" Height="22" Margin="220,127,0,0" Text="$('*'*35)" VerticalAlignment="Top" Width="180" ToolTip="If You don't Fill In the Password it will be Generated. Otherwise Fill In the Password - Please Use Complex Password"/>
                    <ScrollViewer VerticalScrollBarVisibility="Auto" Margin="2,250,0,0" Height="380" Width="1256"  HorizontalScrollBarVisibility="Disabled">
                    <TextBlock Name="TextBlockOutBoxDC" Text="" Foreground="WHITE" Background="#FF22206F" />
                    </ScrollViewer>
                    <Border Name="BorderDeployDcStart" CornerRadius="220" Padding="20,20,20,20" Width="220" Height="220" VerticalAlignment="Top" HorizontalAlignment="Left"  Margin="1000,28,0,0"  Visibility="$DeployDcStart" ToolTip="Push It real Good" ToolTipService.ShowDuration="1000">
						<Border.Background>
							<LinearGradientBrush StartPoint="0,0" EndPoint="0,1">
								<GradientStop Color="DarkGreen" Offset="0.4" />
								<GradientStop Color="Black" Offset="0.8" />
							</LinearGradientBrush>
						</Border.Background>
						<Button Name="ButtonDeployDcStart" Content="START" BorderBrush="Transparent" Background="Red" Foreground="Blue" FontSize="50" FontWeight="Bold">
							<Button.Resources>
								<Style TargetType="{x:Type Border}">
									<Setter Property="CornerRadius" Value="220"/>
								</Style>
							</Button.Resources>
						</Button>
                    </Border>
					<Border Name="BorderDeployDcReboot" CornerRadius="220" Padding="20,20,20,20" Width="220" Height="220" VerticalAlignment="Top" HorizontalAlignment="Left"  Margin="1000,28,0,0" Visibility="Hidden" ToolTip="Push It real Good" ToolTipService.ShowDuration="1000">
						<Border.Background>
							<LinearGradientBrush StartPoint="0,0" EndPoint="0,1">
								<GradientStop Color="DarkGreen" Offset="0.4" />
								<GradientStop Color="Black" Offset="0.8" />
							</LinearGradientBrush>
						</Border.Background>
						<Button Name="ButtonDeployDcReboot" Content="REBOOT" BorderBrush="Transparent" Background="Red" Foreground="Blue" FontSize="40" FontWeight="Bold">
							<Button.Resources>
								<Style TargetType="{x:Type Border}">
									<Setter Property="CornerRadius" Value="220"/>
								</Style>
							</Button.Resources>
						</Button>
                    </Border>
                     <StatusBar Name="StatusBarStatusDC" HorizontalAlignment="Left" Height="24" Margin="2,670,0,0" VerticalAlignment="Top" Width="1256" Background="#FFD6D2B0" >
                        <Label Name="LabelStatusDc" Content="In Progress ...." Height="25" FontSize="12" VerticalAlignment="Center" HorizontalAlignment="Center"  Visibility="Hidden" />
                        <ProgressBar Name="ProgressBarDc" Width="1150" Height="15" Value="1" Visibility="Hidden" />
                    </StatusBar>
                </Grid>
            </TabItem>
            <TabItem Name="TabItemDeployOU" Header="   Deploy OU   ">
                <Grid Background="#FFE5E5E5">
                    <Label Name="LabelManagedOuName" Content="Managed OU Name" HorizontalAlignment="Left" Height="28" Margin="30,28,0,0" VerticalAlignment="Top" Width="165"/>
                    <Label Name="LabelClearmediaAdminUserName" Content="ClearmediaAdmin UserName" HorizontalAlignment="Left" Height="28" Margin="30,61,0,0" VerticalAlignment="Top" Width="165" RenderTransformOrigin="0.452,2.089"/>
                    <Label Name="LabelClearmediaAdminPassword" Content="ClearmediaAdmin Password" HorizontalAlignment="Left" Height="28" Margin="30,94,0,0" VerticalAlignment="Top" Width="165"/>
                    <TextBox Name="TextBoxManagedOuName"  HorizontalAlignment="Left" Height="22" Margin="220,28,0,0" Text="$ManagedOuName" VerticalAlignment="Top" Width="180" TabIndex="1" IsTabStop="False" RenderTransformOrigin="0.673,0.523"/>
                    <TextBox Name="TextBoxClearmediaAdminUserName" HorizontalAlignment="Left" Height="22" Margin="220,61,0,0" Text="ClearmediaAdmin" VerticalAlignment="Top" Width="180" RenderTransformOrigin="0.462,0.455"/>
                    <TextBox Name="TextBoxClearmediaAdminPassword" HorizontalAlignment="Left" Height="22" Margin="220,94,0,0" Text="$('*'*35)" VerticalAlignment="Top" Width="180" ToolTip="If You don't Fill In the Password it will be Generated. Otherwise Fill In the Password - Please Use Complex Password"/>
                    <ScrollViewer VerticalScrollBarVisibility="Auto" Margin="2,250,0,0" Height="380" Width="1256"  HorizontalScrollBarVisibility="Disabled">
                    <TextBlock Name="TextBlockOutBoxOU" Text="" Foreground="WHITE" Background="#FF22206F" />
                    </ScrollViewer>
                    <Border Name="BorderDeployOUStart" CornerRadius="220" Padding="20,20,20,20" Width="220" Height="220" VerticalAlignment="Top" HorizontalAlignment="Left"  Margin="1000,28,0,0"  Visibility="$DeployOuStart" ToolTip="Push It real Good" ToolTipService.ShowDuration="1000">
						<Border.Background>
							<LinearGradientBrush StartPoint="0,0" EndPoint="0,1">
								<GradientStop Color="DarkGreen" Offset="0.4" />
								<GradientStop Color="Black" Offset="0.8" />
							</LinearGradientBrush>
						</Border.Background>
						<Button Name="ButtonDeployOUStart" Content="START" BorderBrush="Transparent" Background="Red" Foreground="Blue" FontSize="50" FontWeight="Bold">
							<Button.Resources>
								<Style TargetType="{x:Type Border}">
									<Setter Property="CornerRadius" Value="220"/>
								</Style>
							</Button.Resources>
						</Button>
                    </Border>
                    <StatusBar Name="StatusBarStatusOU" HorizontalAlignment="Left" Height="24" Margin="2,670,0,0" VerticalAlignment="Top" Width="1256" Background="#FFD6D2B0" >
                        <Label Name="LabelStatusOU" Content="In Progress ...." Height="25" FontSize="12" VerticalAlignment="Center" HorizontalAlignment="Center"  Visibility="Hidden" />
                        <ProgressBar Name="ProgressBarOU" Width="1150" Height="15" Value="1" Visibility="Hidden" />
                    </StatusBar>
                </Grid>
            </TabItem>
            <TabItem Name="TabItemDelployGPO" Header="   Deploy Standard GPO   ">
                <Grid Background="#FFE5E5E5">
                    <CheckBox Name="CheckBoxCopyAdmFiles" Content="Copy ADM(X) Files to Local and SYSVOL ADM(X) Store" HorizontalAlignment="Left" Margin="32,12,0,0" VerticalAlignment="Top" IsChecked="True"/>
                    <Label Name="LabelTemplateSourcePath" Content="ADM(X) Source Path" Margin="27,32,0,0" Height="28" HorizontalAlignment="Left" VerticalAlignment="Top" Width="150" />
                    <TextBox Name="TextBoxTemplateSourcePath" Margin="155,36,0,0" Text="C:\Install\GPO\Templates" Height="22" HorizontalAlignment="Left" VerticalAlignment="Top" Width="275"/>
                    <Label Name="LabelRdsOuPath" Content="RDS OU Path" Margin="27,80,0,0" Height="28" HorizontalAlignment="Left" VerticalAlignment="Top" Width="150" />
                    <TextBox Name="TextBoxRdsOuPath" Margin="110,84,0,0" Text="$RdsOuPath" Height="22" HorizontalAlignment="Left" VerticalAlignment="Top" Width="320"/>
                    <Label Name="LabelUsersOuPath" Content="Users OU Path" Margin="545,80,0,0" Height="28" HorizontalAlignment="Left" VerticalAlignment="Top" Width="150" />
                    <TextBox Name="TextBoxUsersOuPath" Margin="640,84,0,0" Text="$UsersOuPath" Height="22" HorizontalAlignment="Left" VerticalAlignment="Top" Width="260"/>
                    <CheckBox Name="CheckBoxStandardServerRDSPolicy" Content="StandardServerRdsPolicy" HorizontalAlignment="Left" Margin="110,120,0,0" VerticalAlignment="Top" IsChecked="True"/>
                    <CheckBox Name="CheckBoxStandardServerWindowsUpdatePolicy" Content="StandardServerWindowsUpdatePolicy" HorizontalAlignment="Left" Margin="110,145,0,0" VerticalAlignment="Top" IsChecked="True"/>
                    <CheckBox Name="CheckBoxStandardServerFSLogixPolicy" Content="StandardServerFSLogixPolicy" HorizontalAlignment="Left" Margin="110,170,0,0" VerticalAlignment="Top" IsChecked="True"/>
                    <CheckBox Name="CheckBoxStandardUserPolicy" Content="StandardUserPolicy" HorizontalAlignment="Left" Margin="640,120,0,0" VerticalAlignment="Top" IsChecked="True"/>
                    <CheckBox Name="CheckBoxStandardUserHardwareAccelerationPolicy" Content="StandardUserHardwareAccelerationPolicy" HorizontalAlignment="Left" Margin="640,145,0,0" VerticalAlignment="Top" IsChecked="True"/>
                    <CheckBox Name="CheckBoxStandardUserO365Policy" Content="StandardUserO365Policy" HorizontalAlignment="Left" Margin="640,170,0,0" VerticalAlignment="Top" IsChecked="True"/>
                    <CheckBox Name="CheckBoxStandardUserOutlookPolicy" Content="StandardUserOutlookPolicy" HorizontalAlignment="Left" Margin="640,195,0,0" VerticalAlignment="Top" IsChecked="True"/>
                    <ScrollViewer VerticalScrollBarVisibility="Auto" Margin="2,250,0,0" Height="380" Width="1256"  HorizontalScrollBarVisibility="Disabled">
                        <TextBlock Name="TextBlockOutBoxGPO" Text="" Foreground="WHITE" Background="#FF22206F" />
                    </ScrollViewer>
                    <Border Name="BorderDeployStandardGpoStart" CornerRadius="220" Padding="20,20,20,20" Width="220" Height="220" VerticalAlignment="Top" HorizontalAlignment="Left"  Margin="1000,28,0,0"  Visibility="$DeployStandardGpoStart" ToolTip="Push It real Good" ToolTipService.ShowDuration="1000">
						<Border.Background>
							<LinearGradientBrush StartPoint="0,0" EndPoint="0,1">
								<GradientStop Color="DarkGreen" Offset="0.4" />
								<GradientStop Color="Black" Offset="0.8" />
							</LinearGradientBrush>
						</Border.Background>
						<Button Name="ButtonDeployStandardGpoStart" Content="START" BorderBrush="Transparent" Background="Red" Foreground="Blue" FontSize="50" FontWeight="Bold">
							<Button.Resources>
								<Style TargetType="{x:Type Border}">
									<Setter Property="CornerRadius" Value="220"/>
								</Style>
							</Button.Resources>
						</Button>
                    </Border>
                    <StatusBar Name="StatusBarStatusGPO" HorizontalAlignment="Left" Height="24" Margin="2,670,0,0" VerticalAlignment="Top" Width="1256" Background="#FFD6D2B0" >
                        <Label Name="LabelStatusGPO" Content="In Progress ...." Height="25" FontSize="12" VerticalAlignment="Center" HorizontalAlignment="Center"  Visibility="Hidden" />
                        <ProgressBar Name="ProgressBarGPO" Width="1150" Height="15" Value="1" Visibility="Hidden" />
                    </StatusBar>
                </Grid>
            </TabItem>
            <TabItem Name="TabItemFolderRedirection" Header="   Deploy Folder Redirection   ">
                <Grid Background="#FFE5E5E5">
                    <CheckBox Name="CheckBoxDocuments" Content="Documents" HorizontalAlignment="Left" Margin="30,12,0,0" VerticalAlignment="Top" IsChecked="True"/>
                    <Label Name="LabelDocumentsPath" Content="Documents Path" Margin="50,32,0,0" Height="28" HorizontalAlignment="Left" VerticalAlignment="Top" Width="300" />
                    <TextBox Name="TextBoxDocumentsPath" Margin="220,36,0,0" Text="E:\USERS\%USERNAME%\Documents" Height="22" HorizontalAlignment="Left" VerticalAlignment="Top" Width="220"/>
                    <CheckBox Name="CheckBoxMusic" Content="Music" HorizontalAlignment="Left" Margin="30,65,0,0" VerticalAlignment="Top" IsChecked="True"/>
                    <Label Name="LabelMusicPath" Content="Music Path" Margin="50,85,0,0" Height="28" HorizontalAlignment="Left" VerticalAlignment="Top" Width="150" />
                    <TextBox Name="TextBoxMusicPath" Margin="220,89,0,0" Text="E:\USERS\%USERNAME%\Music" Height="22" HorizontalAlignment="Left" VerticalAlignment="Top" Width="220"/>
                    <CheckBox Name="CheckBoxPictures" Content="Pictures" HorizontalAlignment="Left" Margin="30,118,0,0" VerticalAlignment="Top" IsChecked="True"/>
                    <Label Name="LabelPicturesPath" Content="Pictures Path" Margin="50,138,0,0" Height="28" HorizontalAlignment="Left" VerticalAlignment="Top" Width="150" />
                    <TextBox Name="TextBoxPicturesPath" Margin="220,142,0,0" Text="E:\USERS\%USERNAME%\Pictures" Height="22" HorizontalAlignment="Left" VerticalAlignment="Top" Width="220"/>
                    <CheckBox Name="CheckBoxVideos" Content="Videos" HorizontalAlignment="Left" Margin="30,171,0,0" VerticalAlignment="Top" IsChecked="True"/>
                    <Label Name="LabelVideosPath" Content="Videos Path" Margin="50,191,0,0" Height="28" HorizontalAlignment="Left" VerticalAlignment="Top" Width="150" />
                    <TextBox Name="TextBoxVideosPath" Margin="220,195,0,0" Text="E:\USERS\%USERNAME%\Videos" Height="22" HorizontalAlignment="Left" VerticalAlignment="Top" Width="220"/>
                    <ScrollViewer VerticalScrollBarVisibility="Auto" Margin="2,250,0,0" Height="380" Width="1256"  HorizontalScrollBarVisibility="Disabled">
                        <TextBlock Name="TextBlockOutBoxFolderRedirection" Text="" Foreground="WHITE" Background="#FF22206F" />
                    </ScrollViewer>
                    <Border Name="BorderDeployFolderRedirectionStart" CornerRadius="220" Padding="20,20,20,20" Width="220" Height="220" VerticalAlignment="Top" HorizontalAlignment="Left"  Margin="1000,28,0,0"  Visibility="$DeployFolderRedirectionStart" ToolTip="Push It real Good" ToolTipService.ShowDuration="1000">
						<Border.Background>
							<LinearGradientBrush StartPoint="0,0" EndPoint="0,1">
								<GradientStop Color="DarkGreen" Offset="0.4" />
								<GradientStop Color="Black" Offset="0.8" />
							</LinearGradientBrush>
						</Border.Background>
						<Button Name="ButtonDeployFolderRedirectionStart" Content="START" BorderBrush="Transparent" Background="Red" Foreground="Blue" FontSize="50" FontWeight="Bold">
							<Button.Resources>
								<Style TargetType="{x:Type Border}">
									<Setter Property="CornerRadius" Value="220"/>
								</Style>
							</Button.Resources>
						</Button>
                    </Border>
                    <StatusBar Name="StatusBarStatusFolderRedirection" HorizontalAlignment="Left" Height="24" Margin="2,670,0,0" VerticalAlignment="Top" Width="1256" Background="#FFD6D2B0" >
                        <Label Name="LabelStatusFolderRedirection" Content="In Progress ...." Height="25" FontSize="12" VerticalAlignment="Center" HorizontalAlignment="Center"  Visibility="Hidden" />
                        <ProgressBar Name="ProgressBarFolderRedirection" Width="1150" Height="15" Value="1" Visibility="Hidden" />
                    </StatusBar>
                </Grid>
            </TabItem>
            <TabItem Name="TabItemDeployRDS" Header="   Deploy RDS    ">
                <Grid Background="#FFE5E5E5">
                    <Label Name="LabelRDSServerIpAddress" Content="RDS Server IpAddress" HorizontalAlignment="Left" Height="28" Margin="30,28,0,0" VerticalAlignment="Top" Width="180"/>
                    <Label Name="LabelRDSLocalAdminUserName" Content="Local Administrator Name" HorizontalAlignment="Left" Height="28" Margin="30,61,0,0" VerticalAlignment="Top" Width="180"/>
                    <Label Name="LabelRDSLocalAdminPassword" Content="Local Administrator Password" HorizontalAlignment="Left" Height="28" Margin="30,94,0,0" VerticalAlignment="Top" Width="180"/>
                    <Label Name="LabelRDSDomainAdminUserName" Content="Domain Administrator Name" HorizontalAlignment="Left" Height="28" Margin="30,127,0,0" VerticalAlignment="Top" Width="180"/>
                    <Label Name="LabelRDSDomainAdminPassword" Content="Domain Administrator Password" HorizontalAlignment="Left" Height="28" Margin="30,160,0,0" VerticalAlignment="Top" Width="180"/>
                    <Label Name="LabelRDSDomainDcServerName" Content="Domain DC Server Name" HorizontalAlignment="Left" Height="28" Margin="30,193,0,0" VerticalAlignment="Top" Width="180"/>
                    <Label Name="LabelRDSDomainDnsServerIpAddress" Content="Domain DNS Server IP Address" HorizontalAlignment="Left" Height="28" Margin="30,226,0,0" VerticalAlignment="Top" Width="180"/>
					<Label Name="LabelRDSFSLogixFolderRootPath" Content="User FsLogix Root Path" HorizontalAlignment="Left" Margin="550,28,0,0" VerticalAlignment="Top"/>
					<Label Name="LabelRDSDataFolderRootPath" Content="User Data Root Path" HorizontalAlignment="Left" Margin="550,62,0,0" VerticalAlignment="Top"/>
                    <TextBox Name="TextBoxRDSServerIpAddress"  HorizontalAlignment="Left" Height="22" Margin="220,32,0,0" Text="192.168.13.101" VerticalAlignment="Top" Width="180" ToolTip="Fill in Target Server IpAddress"/>
                    <TextBox Name="TextBoxRDSLocalAdminUserName" HorizontalAlignment="Left" Height="22" Margin="220,65,0,0" Text="Administrator" VerticalAlignment="Top" Width="180" ToolTip="Fill in Target Local Administrator Name"/>
                    <TextBox Name="TextBoxRDSLocalAdminPassword" HorizontalAlignment="Left" Height="22" Margin="220,98,0,0" Text="$('*'*35)" VerticalAlignment="Top" Width="180" ToolTip="Fill in Target Local Administrator Password"/>
                    <TextBox Name="TextBoxRDSDomainAdminUserName" HorizontalAlignment="Left" Height="22" Margin="220,131,0,0" Text="Administrator" VerticalAlignment="Top" Width="180" ToolTip="Fill in Target Domain Administrator Name"/>
                    <TextBox Name="TextBoxRDSDomainAdminPassword" HorizontalAlignment="Left" Height="22" Margin="220,164,0,0" Text="$('*'*35)" VerticalAlignment="Top" Width="180" ToolTip="Fill in Target Domain Administrator Password"/>
                    <TextBox Name="TextBoxRDSDomainDcServerName" HorizontalAlignment="Left" Height="22" Margin="220,197,0,0" Text="$DomainDcServerName" VerticalAlignment="Top" Width="180" ToolTip="Fill in Target Domain DC Server Name"/>
                    <TextBox Name="TextBoxRDSDomainDnsServerIpAddress" HorizontalAlignment="Left" Height="22" Margin="220,230,0,0" Text="$DomainDnsServerIpAddress" VerticalAlignment="Top" Width="180" ToolTip="Fill in Target Domain DNS IP Address"/>
                    <TextBox Name="TextBoxRDSFSLogixFolderRootPath" Margin="713,28,0,0" Text='$FSLogixFolderRootPath' Height="22" HorizontalAlignment="Left" VerticalAlignment="Top" Width="180"/>
                    <TextBox Name="TextBoxRDSDataFolderRootPath" Margin="713,61,0,0" Text="$DataFolderRootPath" Height="22" HorizontalAlignment="Left" VerticalAlignment="Top" Width="180"/>
                    <CheckBox Name="CheckBoxRDSRas" Content="Deploy Parallels RAS" HorizontalAlignment="Left" Margin="554,140,0,0" VerticalAlignment="Top" IsChecked="False"/>
                    <Label Name="LabelRDSRasLicenseEmail" Content="Parallels RAS Email" HorizontalAlignment="Left" Height="28" Margin="570,160,0,0" VerticalAlignment="Top" Width="165"/>
                    <Label Name="LabelRDSRasLicensePassword" Content="Parallels RAS Password" HorizontalAlignment="Left" Height="28" Margin="570,190,0,0" VerticalAlignment="Top" Width="165"/>
                    <Label Name="LabelRDSRasKey" Content="Parallels RAS Key" HorizontalAlignment="Left" Height="28" Margin="570,220,0,0" VerticalAlignment="Top" Width="165"/>
                    <TextBox Name="TextBoxRDSRasLicenseEmail"  HorizontalAlignment="Left" Height="22" Margin="713,164,0,0" Text="Support@ClearMedia.be" VerticalAlignment="Top" Width="180" TabIndex="1" IsTabStop="False"/>
                    <TextBox Name="TextBoxRDSRasLicensePassword" HorizontalAlignment="Left" Height="22" Margin="713,194,0,0" Text="$('*'*35)" VerticalAlignment="Top" Width="180"/>
                    <TextBox Name="TextRDSBoxRasKey" Margin="713,224,0,0" Text="TRIAL" Height="22" HorizontalAlignment="Left" VerticalAlignment="Top" Width="180"/>
                    <ScrollViewer VerticalScrollBarVisibility="Auto" Margin="2,250,0,0" Height="380" Width="1256"  HorizontalScrollBarVisibility="Disabled">
						<TextBlock Name="TextBlockOutBoxRDS" Text="" Foreground="WHITE" Background="#FF22206F" />
                    </ScrollViewer>
                    <Border Name="BorderDeployRdsStart" CornerRadius="220" Padding="20,20,20,20" Width="220" Height="220" VerticalAlignment="Top" HorizontalAlignment="Left"  Margin="1000,28,0,0" Visibility="Visible" ToolTip="Push It real Good" ToolTipService.ShowDuration="1000">
						<Border.Background>
							<LinearGradientBrush StartPoint="0,0" EndPoint="0,1">
								<GradientStop Color="DarkGreen" Offset="0.4" />
								<GradientStop Color="Black" Offset="0.8" />
							</LinearGradientBrush>
						</Border.Background>
						<Button Name="ButtonDeployRdsStart" Content="START" BorderBrush="Transparent" Background="Red" Foreground="Blue" FontSize="50" FontWeight="Bold">
							<Button.Resources>
								<Style TargetType="{x:Type Border}">
									<Setter Property="CornerRadius" Value="220"/>
								</Style>
							</Button.Resources>
						</Button>
                    </Border>
                    <Border Name="BorderDeployRdsReboot" CornerRadius="220" Padding="20,20,20,20" Width="220" Height="220" VerticalAlignment="Top" HorizontalAlignment="Left"  Margin="1000,28,0,0" Visibility="Hidden" ToolTip="Push It real Good" ToolTipService.ShowDuration="1000">
						<Border.Background>
							<LinearGradientBrush StartPoint="0,0" EndPoint="0,1">
								<GradientStop Color="DarkGreen" Offset="0.4" />
								<GradientStop Color="Black" Offset="0.8" />
							</LinearGradientBrush>
						</Border.Background>
						<Button Name="ButtonDeployRdsReboot" Content="REBOOT" BorderBrush="Transparent" Background="Red" Foreground="Blue" FontSize="40" FontWeight="Bold">
							<Button.Resources>
								<Style TargetType="{x:Type Border}">
									<Setter Property="CornerRadius" Value="220"/>
								</Style>
							</Button.Resources>
						</Button>
                    </Border>
                     <StatusBar Name="StatusBarStatusRDS" HorizontalAlignment="Left" Height="24" Margin="2,670,0,0" VerticalAlignment="Top" Width="1256" Background="#FFD6D2B0" >
                        <Label Name="LabelStatusRDS" Content="In Progress ...." Height="25" FontSize="12" VerticalAlignment="Center" HorizontalAlignment="Center"  Visibility="Hidden" />
                        <ProgressBar Name="ProgressBarRDS" Width="1150" Height="15" Value="1" Visibility="Hidden" />
                    </StatusBar>
                </Grid>
            </TabItem>
            <TabItem Name="TabItemDeployO365" Header="   Deploy O365   ">
                <Grid Background="#FFE5E5E5">
                    <Label Name="LabelO365ServerIpAddress" Content="Server IpAddress(es)" HorizontalAlignment="Left" Height="28" Margin="30,28,0,0" VerticalAlignment="Top" Width="165"/>
                    <Label Name="LabelO365AdminUserName" Content="Administrator Name" HorizontalAlignment="Left" Height="28" Margin="30,61,0,0" VerticalAlignment="Top" Width="165"/>
                    <Label Name="LabelO365AdminPassword" Content="Administrator Password" HorizontalAlignment="Left" Height="28" Margin="30,94,0,0" VerticalAlignment="Top" Width="165"/>
                    <TextBox Name="TextBoxO365ServerIpAddress"  HorizontalAlignment="Left" Height="22" Margin="220,32,0,0" Text="192.168.13.101" VerticalAlignment="Top" Width="180" ToolTip="Fill in Target - Server IpAddress or Server Name - Multiple Servers seperated by Comma"/>
                    <TextBox Name="TextBoxO365AdminUserName" HorizontalAlignment="Left" Height="22" Margin="220,65,0,0" Text="Administrator" VerticalAlignment="Top" Width="180" ToolTip="Fill in Target Local Administrator Name"/>
                    <TextBox Name="TextBoxO365AdminPassword" HorizontalAlignment="Left" Height="22" Margin="220,98,0,0" Text="$('*'*35)" VerticalAlignment="Top" Width="180" ToolTip="Fill in Target Local Administrator Password"/>
                    <RadioButton Name="RadioButtonO365ProPlusRetail32Bit" Content="O365ProPlusRetail 32 Bit" HorizontalAlignment="Left" Height="22" Margin="550,28,0,0" VerticalAlignment="Top" ClickMode="Press" IsChecked="True"/>
                    <RadioButton Name="RadioButtonO365ProPlusRetail64Bit" Content="O365ProPlusRetail 64 Bit" HorizontalAlignment="Left" Height="22" Margin="550,61,0,0" VerticalAlignment="Top" ClickMode="Press" IsChecked="False"/>
					<CheckBox Name="CheckBoxExcludeApp" Content="Exclude Teams App" HorizontalAlignment="Left" Height="22" Margin="750,28,0,0" VerticalAlignment="Top" IsChecked="True"/>
                    <ScrollViewer VerticalScrollBarVisibility="Auto" Margin="2,250,0,0" Height="380" Width="1256"  HorizontalScrollBarVisibility="Disabled">
						<TextBlock Name="TextBlockOutBoxO365" Text="" Foreground="WHITE" Background="#FF22206F" />
                    </ScrollViewer>
                    <Border Name="BorderDeployO365Start" CornerRadius="220" Padding="20,20,20,20" Width="220" Height="220" VerticalAlignment="Top" HorizontalAlignment="Left"  Margin="1000,28,0,0" Visibility="Visible" ToolTip="Push It real Good" ToolTipService.ShowDuration="1000">
						<Border.Background>
							<LinearGradientBrush StartPoint="0,0" EndPoint="0,1">
								<GradientStop Color="DarkGreen" Offset="0.4" />
								<GradientStop Color="Black" Offset="0.8" />
							</LinearGradientBrush>
						</Border.Background>
						<Button Name="ButtonDeployO365Start" Content="START" BorderBrush="Transparent" Background="Red" Foreground="Blue" FontSize="50" FontWeight="Bold">
							<Button.Resources>
								<Style TargetType="{x:Type Border}">
									<Setter Property="CornerRadius" Value="220"/>
								</Style>
							</Button.Resources>
						</Button>
                    </Border>
                     <StatusBar Name="StatusBarStatusO365" HorizontalAlignment="Left" Height="24" Margin="2,670,0,0" VerticalAlignment="Top" Width="1256" Background="#FFD6D2B0" >
                        <Label Name="LabelStatusO365" Content="In Progress ...." Height="25" FontSize="12" VerticalAlignment="Center" HorizontalAlignment="Center"  Visibility="Hidden" />
                        <ProgressBar Name="ProgressBarO365" Width="1150" Height="15" Value="1" Visibility="Hidden" />
                    </StatusBar>
                </Grid>
            </TabItem>
            <TabItem Name="TabItemDeployWU" Header="   Deploy Windows Updates   ">
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
                        <ComboBoxItem Content="Saturday"/>
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
                        <ComboBoxItem Content="21"/>
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
                    <TextBox Name="TextBoxWuServerIpAddress"  HorizontalAlignment="Left" Height="22" Margin="220,32,0,0" Text="192.168.13.101" VerticalAlignment="Top" Width="180" ToolTip="Fill in Target - Server IpAddress or Server Name - Multiple Servers seperated by Comma"/>
                    <TextBox Name="TextBoxWuAdminUserName" HorizontalAlignment="Left" Height="22" Margin="220,65,0,0" Text="Administrator" VerticalAlignment="Top" Width="180" ToolTip="Fill in Target Local Administrator Name"/>
                    <TextBox Name="TextBoxWuAdminPassword" HorizontalAlignment="Left" Height="22" Margin="220,98,0,0" Text="$('*'*35)" VerticalAlignment="Top" Width="180" ToolTip="Fill in Target Local Administrator Password"/>
                    <ScrollViewer VerticalScrollBarVisibility="Auto" Margin="2,250,0,0" Height="380" Width="1256"  HorizontalScrollBarVisibility="Disabled">
						<TextBlock Name="TextBlockOutBoxWU" Text="" Foreground="WHITE" Background="#FF22206F" />
                    </ScrollViewer>
                    <Border Name="BorderDeployWUStart" CornerRadius="220" Padding="20,20,20,20" Width="220" Height="220" VerticalAlignment="Top" HorizontalAlignment="Left"  Margin="1000,28,0,0" Visibility="Visible" ToolTip="Push It real Good" ToolTipService.ShowDuration="1000">
						<Border.Background>
							<LinearGradientBrush StartPoint="0,0" EndPoint="0,1">
								<GradientStop Color="DarkGreen" Offset="0.4" />
								<GradientStop Color="Black" Offset="0.8" />
							</LinearGradientBrush>
						</Border.Background>
						<Button Name="ButtonDeployWUStart" Content="START" BorderBrush="Transparent" Background="Red" Foreground="Blue" FontSize="50" FontWeight="Bold">
							<Button.Resources>
								<Style TargetType="{x:Type Border}">
									<Setter Property="CornerRadius" Value="220"/>
								</Style>
							</Button.Resources>
						</Button>
                    </Border>
                     <StatusBar Name="StatusBarStatusWU" HorizontalAlignment="Left" Height="24" Margin="2,670,0,0" VerticalAlignment="Top" Width="1256" Background="#FFD6D2B0" >
                        <Label Name="LabelStatusWU" Content="In Progress ...." Height="25" FontSize="12" VerticalAlignment="Center" HorizontalAlignment="Center"  Visibility="Hidden" />
                        <ProgressBar Name="ProgressBarWU" Width="1150" Height="15" Value="1" Visibility="Hidden" />
                    </StatusBar>
                </Grid>
            </TabItem>
            <TabItem Name="TabItemDeployUSER" Header="   Deploy USER   ">
                <Grid Background="#FFE5E5E5">
                    <Label Name="LabelUSERServerIpAddress" Content="RDS Server IpAddress" HorizontalAlignment="Left" Height="28" Margin="30,28,0,0" VerticalAlignment="Top" Width="180"/>
                    <Label Name="LabelUSERLocalAdminUserName" Content="Local Administrator Name" HorizontalAlignment="Left" Height="28" Margin="30,61,0,0" VerticalAlignment="Top" Width="180"/>
                    <Label Name="LabelUSERLocalAdminPassword" Content="Local Administrator Password" HorizontalAlignment="Left" Height="28" Margin="30,94,0,0" VerticalAlignment="Top" Width="180"/>
                    <Label Name="LabelUSERDomainAdminUserName" Content="Domain Administrator Name" HorizontalAlignment="Left" Height="28" Margin="30,127,0,0" VerticalAlignment="Top" Width="180"/>
                    <Label Name="LabelUSERDomainAdminPassword" Content="Domain Administrator Password" HorizontalAlignment="Left" Height="28" Margin="30,160,0,0" VerticalAlignment="Top" Width="180"/>
                    <Label Name="LabelUSERDomainDcServerName" Content="Domain DC Server Name" HorizontalAlignment="Left" Height="28" Margin="30,193,0,0" VerticalAlignment="Top" Width="180"/>
                    <Label Name="LabelUSERUserType" Content="User Type" HorizontalAlignment="Left" VerticalAlignment="Top" Height="28" Margin="550,28,0,0" Width="165"/>
                    <Label Name="LabelUSERDatatFolderRootPath" Content="User Data Root Path" HorizontalAlignment="Left" VerticalAlignment="Top" Height="28" Margin="550,61,0,0" Width="165"/>
                    <Label Name="LabelUSERAccountName" Content="User Account Name" HorizontalAlignment="Left" VerticalAlignment="Top" Height="28" Margin="550,94,0,0" Width="165"/>
                    <Label Name="LabelUSERUserGivenName" Content="User Given Name" HorizontalAlignment="Left" VerticalAlignment="Top" Height="28" Margin="550,127,0,0" Width="165"/>
                    <Label Name="LabelUSERUserSurname" Content="User Sur Name" HorizontalAlignment="Left" VerticalAlignment="Top" Height="28" Margin="550,160,0,0" Width="165"/>
                    <Label Name="LabelUSERUserEmailAddress" Content="User Email Address" HorizontalAlignment="Left" VerticalAlignment="Top" Height="28" Margin="550,193,0,0" Width="165"/>
                    <Label Name="LabelUSERUserPassword" Content="User Password" HorizontalAlignment="Left" VerticalAlignment="Top" Height="28" Margin="550,226,0,0" Width="165"/>
                    <ComboBox Name="ComboBoxUSERUserType" HorizontalAlignment="Left" Height="26" Margin="713,28,0,0" VerticalAlignment="Top" Width="180" ToolTip="Select User Type from List">
                        <ComboBoxItem Content="Full User" IsSelected="True"/>
                        <ComboBoxItem Content="Light User"/>
                    </ComboBox>
                    <TextBox Name="TextBoxUSERServerIpAddress"  HorizontalAlignment="Left" Height="22" Margin="220,32,0,0" Text="192.168.13.101" VerticalAlignment="Top" Width="180" ToolTip="Fill in Target Server IpAddress"/>
                    <TextBox Name="TextBoxUSERLocalAdminUserName" HorizontalAlignment="Left" Height="22" Margin="220,65,0,0" Text="Administrator" VerticalAlignment="Top" Width="180" ToolTip="Fill in Target Local Administrator Name"/>
                    <TextBox Name="TextBoxUSERLocalAdminPassword" HorizontalAlignment="Left" Height="22" Margin="220,98,0,0" Text="$('*'*35)" VerticalAlignment="Top" Width="180" ToolTip="Fill in Target Local Administrator Password"/>
                    <TextBox Name="TextBoxUSERDomainAdminUserName" HorizontalAlignment="Left" Height="22" Margin="220,131,0,0" Text="Administrator" VerticalAlignment="Top" Width="180" ToolTip="Fill in Target Domain Administrator Name"/>
                    <TextBox Name="TextBoxUSERDomainAdminPassword" HorizontalAlignment="Left" Height="22" Margin="220,164,0,0" Text="$('*'*35)" VerticalAlignment="Top" Width="180" ToolTip="Fill in Target Domain Administrator Password"/>
                    <TextBox Name="TextBoxUSERDomainDcServerName" HorizontalAlignment="Left" Height="22" Margin="220,197,0,0" Text="$DomainDcServerName" VerticalAlignment="Top" Width="180" ToolTip="Fill in Target Domain DC Server Name"/>
                    <TextBox Name="TextBoxUSERUserType" Margin="713,32,0,0" Height="22" Width="180"/>
                    <TextBox Name="TextBoxUSERDataFolderRootPath" Text="$DataFolderRootPath" HorizontalAlignment="Left" VerticalAlignment="Top" Height="22" Margin="713,65,0,0" Width="180"/>
                    <TextBox Name="TextBoxUSERUserAccountName" Text="" HorizontalAlignment="Left" VerticalAlignment="Top" Height="22" Margin="713,98,0,0" Width="180" ToolTip="Fill in User Account Name"/>
                    <TextBox Name="TextBoxUSERUserGivenName" Text="" HorizontalAlignment="Left" VerticalAlignment="Top" Height="22" Margin="713,131,0,0" Width="180" ToolTip="Fill in User First Name"/>
                    <TextBox Name="TextBoxUSERUserSurname" Text="" HorizontalAlignment="Left" VerticalAlignment="Top" Height="22" Margin="713,164,0,0" Width="180" ToolTip="Fill in User Last Name"/>
                    <TextBox Name="TextBoxUSERUserEmailAddress" Text="" HorizontalAlignment="Left" VerticalAlignment="Top" Height="22" Margin="713,197,0,0" Width="180" ToolTip="Fill in User Email Address"/>
                    <TextBox Name="TextBoxUSERUserPassword" Text="" HorizontalAlignment="Left" VerticalAlignment="Top" Height="22" Margin="713,230,0,0" Width="180" ToolTip="If You don't Fill In the Password it will be Generated. Otherwise Fill In the Password - Please Use Complex Password"/>
                    <ScrollViewer VerticalScrollBarVisibility="Auto" Margin="2,250,0,0" Height="380" Width="1256"  HorizontalScrollBarVisibility="Disabled">
						<TextBlock Name="TextBlockOutBoxUser" Text="" Foreground="WHITE" Background="#FF22206F" />
                    </ScrollViewer>
                    <Border Name="BorderDeployUserStart" CornerRadius="220" Padding="20,20,20,20" Width="220" Height="220" VerticalAlignment="Top" HorizontalAlignment="Left"  Margin="1000,28,0,0" Visibility="Visible" ToolTip="Push It real Good" ToolTipService.ShowDuration="1000">
						<Border.Background>
							<LinearGradientBrush StartPoint="0,0" EndPoint="0,1">
								<GradientStop Color="DarkGreen" Offset="0.4" />
								<GradientStop Color="Black" Offset="0.8" />
							</LinearGradientBrush>
						</Border.Background>
						<Button Name="ButtonDeployUserStart" Content="START" BorderBrush="Transparent" Background="Red" Foreground="Blue" FontSize="50" FontWeight="Bold">
							<Button.Resources>
								<Style TargetType="{x:Type Border}">
									<Setter Property="CornerRadius" Value="220"/>
								</Style>
							</Button.Resources>
						</Button>
                    </Border>
                    <StatusBar Name="StatusBarStatusUser" HorizontalAlignment="Left" Height="24" Margin="2,670,0,0" VerticalAlignment="Top" Width="1256" Background="#FFD6D2B0" >
                        <Label Name="LabelStatusUser" Content="In Progress ...." Height="25" FontSize="12" VerticalAlignment="Center" HorizontalAlignment="Center"  Visibility="Hidden" />
                        <ProgressBar Name="ProgressBarUser" Width="1150" Height="15" Value="1" Visibility="Hidden" />
                    </StatusBar>
                </Grid>
            </TabItem>
        </TabControl>
    </Grid>
 </Window>
"@

# Init ( WPF - Windows Presentation Framework )
$SyncHash.Window=[Windows.Markup.XamlReader]::Load( [System.Xml.XmlNodeReader]::new($XAML) )

# AutoFind ( WPF - Windows Presentation Framework ) Controls
$XAML.SelectNodes("//*[@Name]") | ForEach-Object { $SyncHash.Add($_.Name, $SyncHash.Window.Findname($_.Name)) }

# Init ( WPF - Windows Presentation Framework ) Functions
Function DeployFireboxStart {
 	Param($SyncHash,$FireboxIpAddress,$FireboxAdminUserName,$FireboxAdminPassword,$FireboxExternalIp,$FireboxExternalIpGatewayCIDR,$FireboxExternalIpCIDR,$FireboxExternalIpGateway)
	$Runspace = [runspacefactory]::CreateRunspace()
	$Runspace.ApartmentState = "STA"
	$Runspace.ThreadOptions = "ReuseThread"
	$Runspace.Open()
	$Runspace.SessionStateProxy.SetVariable("SyncHash",$SyncHash)
	$Runspace.SessionStateProxy.SetVariable("FireboxIpAddress",$FireboxIpAddress)
	$Runspace.SessionStateProxy.SetVariable("FireboxAdminUserName",$FireboxAdminUserName)
	$Runspace.SessionStateProxy.SetVariable("FireboxAdminPassword",$FireboxAdminPassword)
	$Runspace.SessionStateProxy.SetVariable("FireboxExternalIp",$FireboxExternalIp)
	$Runspace.SessionStateProxy.SetVariable("FireboxExternalIpGatewayCIDR",$FireboxExternalIpGatewayCIDR)
	$Runspace.SessionStateProxy.SetVariable("FireboxExternalIpCIDR",$FireboxExternalIpCIDR)
	$Runspace.SessionStateProxy.SetVariable("FireboxExternalIpGateway",$FireboxExternalIpGateway)
	$code = {
		$I = 0
		$Step = 8
		$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarFirebox.Value = $I } )
		$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxFirebox.AddText(" Importing PowerShell Module Posh-SSH `n") } )
		# Force Posh-SSH Version to 2.3.0
		Import-Module -FullyQualifiedName 'C:\iNSTALL\Deployment\Posh-SSH\2.3.0\Posh-SSH.psd1' -Force
		$I += $Step ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarFirebox.Value = $I } )
		$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxFirebox.AddText(" Creating SSH Session `n") } )
		$Credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ( $FireboxAdminUserName , $(ConvertTo-SecureString -String $FireboxAdminPassword -AsPlainText -Force) )
		Try { New-SshSession -ComputerName $FireboxIpAddress -Port 4118 -Credential $Credentials -AcceptKey -ErrorAction Stop }
			Catch {
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarFirebox.Visibility = "Hidden" } )
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.LabelStatusFirebox.Content = "Connection Failure $(' .'*130)$(' '*30)Please check FireboxV - Username - Password" } )
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployFireboxStart.IsEnabled = $True } )
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployFireboxStart.Visibility = "Visible"  } )
				Return
				}
		$I += $Step ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarFirebox.Value = $I } )
		$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxFirebox.AddText(" Creating SSH Stream `n") } )
		$Stream = $SshSessions[0].Session.CreateShellStream( "dumb" , 0 , 0 , 0 , 0 , 1024 )
		$I += $Step ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarFirebox.Value = $I } )
		$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxFirebox.AddText(" Sending conf `n") } )
		Do { $Stream.WriteLine("conf") ; Start-Sleep -Seconds 2 ; $Return = $Stream.Read() } Until ( $Return.Split([CHAR]10).Split([CHAR]13)[-1] -eq 'WG(config)#' )
		$I += $Step ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarFirebox.Value = $I } )
		$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxFirebox.AddText(" Sending int f 0 `n") } )
		$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxFirebox.AddText(" Sending ip a $FireboxExternalIpCIDR d $FireboxExternalIpGateway `n") } )
		$I += $Step ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarFirebox.Value = $I } )
		Do { $Stream.WriteLine("int f 0") ; Start-Sleep -Seconds 2 ; $Stream.WriteLine("ip a $FireboxExternalIpCIDR d $FireboxExternalIpGateway") ; $Return = $Stream.Read() } Until ( $Return.Split([CHAR]10).Split([CHAR]13)[-1] -eq 'WG(config/if-fe00)#' )
		$I += $Step ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarFirebox.Value = $I } )
		$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxFirebox.AddText(" Sending exit `n") } )
		Do { $Stream.WriteLine("exit") ; Start-Sleep -Seconds 2 ; $Return = $Stream.Read() } Until ( $Return.Split([CHAR]10).Split([CHAR]13)[-1] -eq 'WG#' )
		$I += $Step ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarFirebox.Value = $I } )
		$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxFirebox.AddText(" Closing SSH Stream `n") } )
		Start-Sleep -Seconds 3 ; $Stream.Close() ; $Stream.Dispose()
		$I += $Step ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarFirebox.Value = $I } )
		$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxFirebox.AddText(" Closing SSH Session `n") } )
		Remove-SshSession ; Start-Sleep -Seconds 3
        $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxFirebox.AddText(" Testing Internet Connection `n") } )
		$J = 1
		Do {
			$J++
			$Job = Invoke-Command -ComputerName localhost -AsJob -JobName 'TestConnectionGoogle' -ScriptBlock { Test-Connection -ComputerName '8.8.4.4' -Count 1 -Delay  1 }
			While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarFirebox.Value = $I } ) }
			}
		    While ( $Job.ChildJobs[0].Error -and ( $J -le 5 ) )
		If ( $Job.ChildJobs[0].Error ) {
                    $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarFirebox.Visibility = "Hidden" } )
                    $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.LabelStatusFirebox.Content = "Connection Failure $(' .'*130)$(' '*30)Please check NAT IP & Gateway IP CIDR" } )
                    $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployFireboxStart.IsEnabled = $True } )
                    $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployFireboxStart.Visibility = "Visible"  } )
                    Return
                    }
            Else { Start-Sleep -Milliseconds 2500 ; [System.Net.ServicePointManager]::SecurityProtocol = 'Tls12' ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxFirebox.AddText(" Public IP Address :  $((Invoke-WebRequest -Uri 'https://api.ipify.org' -UseBasicParsing).content) `n") } )}	 
		New-ItemProperty -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'FireboxExternalIp' -PropertyType 'String' -Value $FireboxExternalIp -Force
		New-ItemProperty -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'FireboxExternalIpGatewayCIDR' -PropertyType 'String' -Value $FireboxExternalIpGatewayCIDR -Force
		$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarFirebox.Visibility = "Hidden" } )
		$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.LabelStatusFirebox.Visibility = "Hidden" } )
		$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployFireboxStart.Visibility = "Hidden" } )
		New-ItemProperty -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'DeployFirebox' -PropertyType 'String' -Value 'Hidden' -Force
		}
	$PSinstance = [powershell]::Create().AddScript($Code)
	$PSinstance.Runspace = $Runspace
	$job = $PSinstance.BeginInvoke()
	}
Function DeployDcStart {
	Param($SyncHash,$SafeModeAdministratorPassword,$DnsServerForwarders,$DomainNetbiosName,$DomainDnsName)
	$Runspace = [runspacefactory]::CreateRunspace()
	$Runspace.ApartmentState = "STA"
	$Runspace.ThreadOptions = "ReuseThread"
	$Runspace.Open()
	$Runspace.SessionStateProxy.SetVariable("SyncHash",$SyncHash)
	$Runspace.SessionStateProxy.SetVariable("SafeModeAdministratorPassword",$SafeModeAdministratorPassword)
	$Runspace.SessionStateProxy.SetVariable("DnsServerForwarders",$DnsServerForwarders)
	$Runspace.SessionStateProxy.SetVariable("DomainNetbiosName",$DomainNetbiosName)
	$Runspace.SessionStateProxy.SetVariable("DomainDnsName",$DomainDnsName)
	$code = {
			$I = 0
			[STRING]$RandomPasswordPlainText = ((([char[]](65..90) | sort {get-random})[0..2] + ([char[]](33,35,36,37,42,43,45) | sort {get-random})[0] + ([char[]](97..122) | sort {get-random})[0..4] + ([char[]](48..57) | sort {get-random})[0]) | get-random -Count 10) -join ''
			If ( $SafeModeAdministratorPassword -ne "$('*'*35)" ) { $SafeModeAdministratorPassword = ConvertTo-SecureString $SafeModeAdministratorPassword -AsPlainText -Force }
                Else { $SafeModeAdministratorPassword = ConvertTo-SecureString $RandomPasswordPlainText -AsPlainText -Force ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBoxSafeModeAdministratorPassword.Text = $RandomPasswordPlainText } ) }
            $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarDc.Value = $I } )
            $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxDC.AddText(" Installing Active Directory Domain Services `n") } )
            $Job = Start-Job -Name 'Active Directory Domain Services' -ScriptBlock { Install-WindowsFeature -Name 'AD-Domain-Services' -ErrorAction Stop }
            While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarDc.Value = $I } ) }
            $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxDC.AddText(" Installing Group Policy Management `n") } )
            $Job = Start-Job -Name 'Group Policy Management' -ScriptBlock { Install-WindowsFeature -Name 'GPMC' -ErrorAction Stop }
            While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500  ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarDc.Value = $I } ) }
            $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxDC.AddText(" Installing DNS Server `n") } )
            $Job = Start-Job -Name 'DNS Server' -ScriptBlock { Install-WindowsFeature -Name 'DNS' }
            While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500  ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarDc.Value = $I } ) }
            $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxDC.AddText(" Installing Remote Desktop Licensing Services `n") } )
            $Job = Start-Job -Name 'Remote Desktop Licensing Services' -ScriptBlock { Install-WindowsFeature -Name 'RDS-Licensing' -ErrorAction Stop }
            While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarDc.Value = $I } )  }
            $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxDC.AddText(" Installing Remote Server Administration Tools `n") } )
            $Job = Start-Job -Name 'Remote Server Administration Tools' -ScriptBlock { Install-WindowsFeature -Name  'RSAT-AD-Tools','RSAT-DNS-Server','RSAT-RDS-Licensing-Diagnosis-UI','RDS-Licensing-UI' -ErrorAction Stop }
            While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500  ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarDc.Value = $I } ) }
			$DnsServerForwarders.Split(',') | Sort-Object -Descending | ForEach-Object {
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxDC.AddText(" Adding DNS Forwarder $_ `n") } )
				$Job = Start-Job -Name "Adding DNS Forwarder $_" -ScriptBlock { Param( $DnsServerForwarders ) ; Add-DnsServerForwarder -IPAddress ($DnsServerForwarders.Split(',') | Sort-Object) -ErrorAction Stop } -ArgumentList ( $_ )
				While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarDc.Value = $I } )  }
                }
            $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxDC.AddText(" Creating AD Forest for $DomainDnsName `n") } )
            $Job = Start-Job -Name 'Install-ADDSForest' -ScriptBlock { Param($DomainDnsName,$DomainNetbiosName,$SafeModeAdministratorPassword) ; Install-ADDSForest -DomainName $DomainDnsName -DomainNetbiosName $DomainNetbiosName -SafeModeAdministratorPassword $SafeModeAdministratorPassword -NoRebootOnCompletion -ErrorAction Stop -Force} -ArgumentList ($DomainDnsName,$DomainNetbiosName,$SafeModeAdministratorPassword) 
            While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarDc.Value = $I } )  }
			Get-Job | Select-Object -Property Name, State, Command, @{Name='Error';Expression={ $_.ChildJobs[0].JobStateInfo.Reason }} | Export-Csv -Path "$env:windir\Logs\PushTheButtonJobs.csv" -NoTypeInformation -Force
            [Boolean]$JobError = Get-Job | Where-Object { $_.State -eq 'Failed' } | ForEach-Object { $_.count -gt 0 }
            If ( $JobError ) {
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarDc.Visibility = "Hidden" } )
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.LabelStatusDc.Content = "Deployment Finished with ERRORS $(' .'*115)$(' '*30)Please consult PushTheButtonJobs.csv" } )
                }
                Else {
					New-ItemProperty -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'DeployDcStart' -PropertyType 'String' -Value 'Hidden' -Force
					New-ItemProperty -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'DomainNetbiosName' -PropertyType 'String' -Value $DomainNetbiosName -Force
					New-ItemProperty -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'DomainDNSName' -PropertyType 'String' -Value $DomainDNSName -Force
					New-ItemProperty -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'DnsServerForwarders' -PropertyType 'String' -Value $DnsServerForwarders -Force
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarDc.Visibility = "Hidden" } )
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.LabelStatusDc.Content = "Deployment Finished $(' .'*135)$(' '*30) Please  REBOOT" } )
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployDcStart.Visibility = "Hidden" } )
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployDcReboot.IsEnabled = $True } )
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployDcReboot.Visibility = "Visible" } )    
					}
			}
	$PSinstance = [powershell]::Create().AddScript($Code)
	$PSinstance.Runspace = $Runspace
	$job = $PSinstance.BeginInvoke()
	}
Function DeployOuStart {
	Param($SyncHash,$ManagedOuName,$ClearmediaAdminUserName,$ClearmediaAdminPassword)
	$Runspace = [runspacefactory]::CreateRunspace()
	$Runspace.ApartmentState = "STA"
	$Runspace.ThreadOptions = "ReuseThread"
	$Runspace.Open()
	$Runspace.SessionStateProxy.SetVariable("SyncHash",$SyncHash)
	$Runspace.SessionStateProxy.SetVariable("ManagedOuName",$ManagedOuName)
	$Runspace.SessionStateProxy.SetVariable("ClearmediaAdminUserName",$ClearmediaAdminUserName)
	$Runspace.SessionStateProxy.SetVariable("ClearmediaAdminPassword",$ClearmediaAdminPassword)
	$code = {
			$Error.Clear()
			$ErrorList = @()
			$I = 0
			[STRING]$RandomPasswordPlainText = ((([char[]](65..90) | sort {get-random})[0..2] + ([char[]](33,35,36,37,42,43,45) | sort {get-random})[0] + ([char[]](97..122) | sort {get-random})[0..4] + ([char[]](48..57) | sort {get-random})[0]) | get-random -Count 10) -join ''
			If ( $ClearmediaAdminPassword -eq "$('*'*35)" ) { $ClearmediaAdminPassword = $RandomPasswordPlainText ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBoxClearmediaAdminPassword.Text = $ClearmediaAdminPassword } ) }
			[STRING]$ManagedOU = $ManagedOuName
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
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxOU.AddText(" Creating OU $_ `n") } ) 
                $I += 4
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarOU.Value = $I } )
                New-ADOrganizationalUnit -Server $env:COMPUTERNAME -Name $_ -Path $($OUs.$_) -ErrorAction Stop
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
				'FSLogix-Users' = "OU=Groups,OU=$ManagedOU,$ADRootDSE"
				'VPN-Users' = "OU=Groups,OU=$ManagedOU,$ADRootDSE"
				}
            ForEach ($Group in $Groups.keys) {
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxOU.AddText(" Adding Group $Group in $($Groups.$Group) `n") } ) 
                $I += 4
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarOU.Value = $I } )
                New-ADGroup -Server $env:COMPUTERNAME -Name $Group -GroupScope 'Global' -Path $($Groups.$Group) -ErrorAction Stop
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
            $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxOU.AddText(" Creating $ClearmediaAdminUserName User `n") } ) 
            $I += 2
            $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarOU.Value = $I } )
            New-ADUser -Server $env:COMPUTERNAME @NewUserParams -ErrorAction Stop
            If ( $error ) {
                $ErrorList += "New-ADUser @NewUserParams -ErrorAction Stop"
                $ErrorList += $error[0].Exception.Message.ToString()
                $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                $Error.Clear()
                }
            # Add ClearMedia User to Admin & Enterprise Groups
            ('Domain Admins','Enterprise Admins') | ForEach-Object { 
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxOU.AddText(" Adding ClearMedia User to $_ `n") } ) 
                $I += 4
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarOU.Value = $I } )
                Add-ADGroupMember -Server $env:COMPUTERNAME -Identity "CN=$_,CN=Users,$ADRootDSE" -Members "CN=$($NewUserParams.Name),$($NewUserParams.Path)"  -ErrorAction Stop
                If ( $error ) {
                    $ErrorList += "Add-ADGroupMember -Identity CN=$_,CN=Users,$ADRootDSE -Members CN=$($NewUserParams.Name),$($NewUserParams.Path)  -ErrorAction Stop"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }
                }
            $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarOU.Visibility = "Hidden" } )
            If ( $ErrorList ) { 
                $ErrorList | Out-File -FilePath "$env:windir\Logs\PushTheButtonError.log" -Append -Force
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.LabelStatusOU.Content = "Deployment Finished with ERRORS $(' .'*115)$(' '*30)Please consult PushTheButtonError.log" } )
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployOUStart.IsEnabled = $True } )
                }
                Else {
					New-ItemProperty -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'ManagedOuName' -PropertyType 'String' -Value $ManagedOuName -Force
					New-ItemProperty -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'RdsOuPath' -PropertyType 'String' -Value "OU=RDS,OU=Servers,OU=$ManagedOuName,$ADRootDSE" -Force
					New-ItemProperty -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'UsersOuPath' -PropertyType 'String' -Value "OU=Users,OU=$ManagedOuName,$ADRootDSE" -Force
					New-ItemProperty -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'DeployOuStart' -PropertyType 'String' -Value 'Hidden' -Force
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBoxRdsOuPath.Text = "OU=RDS,OU=Servers,OU=$ManagedOuName,$ADRootDSE" } )
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBoxUsersOuPath.Text = "OU=Users,OU=$ManagedOuName,$ADRootDSE" } )
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.LabelStatusOU.Content = "Deployment Finished $(' .'*135)$(' '*30)" } )
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployOUStart.Visibility = "Hidden" } )
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployStandardGpoStart.IsEnabled = $True } )
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployFolderRedirectionStart.IsEnabled = $True } )
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployRdsStart.IsEnabled = $True } )
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployO365Start.IsEnabled = $True } )
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployWUStart.IsEnabled = $True } )
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployUserStart.IsEnabled = $True } )
					}
            }
	$PSinstance = [powershell]::Create().AddScript($Code)
	$PSinstance.Runspace = $Runspace
	$job = $PSinstance.BeginInvoke()
	}
Function DeployStandardGpoStart {
	Param($SyncHash,$TemplateSourcePath,$RdsOuPath,$UsersOuPath,$CheckBoxCopyAdmFiles,$CheckBoxStandardServerRDSPolicy,$CheckBoxStandardServerWindowsUpdatePolicy,$CheckBoxStandardServerFSLogixPolicy,$CheckBoxStandardUserPolicy,$CheckBoxStandardUserHardwareAccelerationPolicy,$CheckBoxStandardUserO365Policy,$CheckBoxStandardUserOutlookPolicy)
	$Runspace = [runspacefactory]::CreateRunspace()
	$Runspace.ApartmentState = "STA"
	$Runspace.ThreadOptions = "ReuseThread"
	$Runspace.Open()
	$Runspace.SessionStateProxy.SetVariable("SyncHash",$SyncHash)
	$Runspace.SessionStateProxy.SetVariable("TemplateSourcePath",$TemplateSourcePath)
	$Runspace.SessionStateProxy.SetVariable("RdsOuPath",$RdsOuPath)
	$Runspace.SessionStateProxy.SetVariable("UsersOuPath",$UsersOuPath)
	$Runspace.SessionStateProxy.SetVariable("CheckBoxCopyAdmFiles",$CheckBoxCopyAdmFiles)
	$Runspace.SessionStateProxy.SetVariable("CheckBoxStandardServerRDSPolicy",$CheckBoxStandardServerRDSPolicy)
	$Runspace.SessionStateProxy.SetVariable("CheckBoxStandardServerWindowsUpdatePolicy",$CheckBoxStandardServerWindowsUpdatePolicy)
	$Runspace.SessionStateProxy.SetVariable("CheckBoxStandardServerFSLogixPolicy",$CheckBoxStandardServerFSLogixPolicy)
	$Runspace.SessionStateProxy.SetVariable("CheckBoxStandardUserPolicy",$CheckBoxStandardUserPolicy)
	$Runspace.SessionStateProxy.SetVariable("CheckBoxStandardUserHardwareAccelerationPolicy",$CheckBoxStandardUserHardwareAccelerationPolicy)
	$Runspace.SessionStateProxy.SetVariable("CheckBoxStandardUserO365Policy",$CheckBoxStandardUserO365Policy)
	$Runspace.SessionStateProxy.SetVariable("CheckBoxStandardUserOutlookPolicy",$CheckBoxStandardUserOutlookPolicy)
	$code = {
			$Error.Clear()
			$ErrorList = @()
			$I = 0
			# Get ADRootDSE
			$ADRootDSE = $(($env:USERDNSDOMAIN.Replace('.',',DC=')).Insert(0,'DC='))
			# Copy ADM(X) Files to Local ADM(X) Store
			If ( $CheckBoxCopyAdmFiles ) {   
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxGPO.AddText(" Copying ADM(X) Files to Local ADM(X) Store `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarGPO.Value = $I } )
				Copy-Item -Path "$TemplateSourcePath\admx\*" -Destination 'C:\Windows\PolicyDefinitions' -ErrorAction Continue -Force
				If ( $error ) {
                    $ErrorList += "Copy-Item -Path $TemplateSourcePath\admx\* -Destination 'C:\Windows\PolicyDefinitions' -ErrorAction Stop -Force"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarGPO.Value = $I } )
				Copy-Item -Path "$TemplateSourcePath\admx\en-US\*" -Destination 'C:\Windows\PolicyDefinitions\en-US' -ErrorAction Continue -Force
				If ( $error ) {
                    $ErrorList += "Copy-Item -Path $TemplateSourcePath\admx\en-US\* -Destination 'C:\Windows\PolicyDefinitions' -ErrorAction Stop -Force"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarGPO.Value = $I } )
				Copy-Item -Path "$TemplateSourcePath\admx\fr-FR\*" -Destination 'C:\Windows\PolicyDefinitions\fr-FR' -ErrorAction Continue -Force
				If ( $error ) {
                    $ErrorList += "Copy-Item -Path $TemplateSourcePath\admx\fr-FR\* -Destination 'C:\Windows\PolicyDefinitions' -ErrorAction Stop -Force"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }
				# Create Central ADM(X) Store
				# Copy ADM(X) files to Central ADM(X) Store
				[STRING]$DomainName = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().Name
                If ( (Get-CimInstance -NameSpace root/CIMV2 -ClassName win32_ComputerSystem).DomainRole -in ( 4 , 5 ) ) { [STRING]$DcName = 'localhost' }
                    Else { [STRING]$DcName = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().PdcRoleOwner.Name }
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxGPO.AddText(" Creating Central ADM(X) Store `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarGPO.Value = $I } )
				New-Item -Path "\\$DcName\SYSVOL\$DomainName\Policies\PolicyDefinitions" -ItemType Directory -ErrorAction Continue -Force
				If ( $error ) {
                    $ErrorList += "New-Item -Path \\$DcName\SYSVOL\$DomainName\Policies\PolicyDefinitions -ItemType Directory -ErrorAction Stop -Force"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxGPO.AddText(" Copying ADM(X) files to Central ADM(X) Store `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarGPO.Value = $I } )
				Copy-Item -Path 'C:\Windows\PolicyDefinitions\*' -Destination "\\$DcName\SYSVOL\$DomainName\Policies\PolicyDefinitions" -ErrorAction Continue -Force
				If ( $error ) {
                    $ErrorList += "Copy-Item -Path 'C:\Windows\PolicyDefinitions\*' -Destination \\$DcName\SYSVOL\$DomainName\Policies\PolicyDefinitions -ErrorAction Stop -Force"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarGPO.Value = $I } )
				Copy-Item -Path 'C:\Windows\PolicyDefinitions\en-US\*' -Destination "\\$DcName\SYSVOL\$DomainName\Policies\PolicyDefinitions\en-US" -ErrorAction Continue  -Force
				If ( $error ) {
                    $ErrorList += "Copy-Item -Path 'C:\Windows\PolicyDefinitions\en-US\*' -Destination \\$DcName\SYSVOL\$DomainName\Policies\PolicyDefinitions\en-US -ErrorAction Stop  -Force"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }
				}
			# Create and Assemble Computer GPOs
			# Link Computer GPOs to OU RDS
			$StandardServerRDSPolicy = (
				'HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer,NoDriveTypeAutoRun,Dword,255',
				'HKLM\Software\Policies\Microsoft\Windows\Personalization,NoChangingLockScreen,Dword,1',
				'HKLM\Software\Policies\Microsoft\Windows\Session Manager\Quota System,EnableCpuQuota,Dword,0',
                'HKLM\SYSTEM\CurrentControlSet\Services\TSFairShare\Disk,EnableFairShare,Dword,0' ,
                'HKLM\SYSTEM\CurrentControlSet\Services\TSFairShare\NetFS,EnableFairShare,Dword,0' ,
				'HKLM\Software\Policies\Microsoft\Windows NT\Terminal Services,Shadow,Dword,2',
				'HKLM\Software\Policies\Microsoft\Windows NT\Terminal Services,LicensingMode,Dword,4',
				'HKLM\Software\Policies\Microsoft\Windows NT\Terminal Services,fResetBroken,Dword,1',
				'HKLM\Software\Policies\Microsoft\Windows NT\Terminal Services,LicenseServers,String,192.168.13.100',
				'HKLM\Software\Policies\Microsoft\Windows NT\Terminal Services,MaxDisconnectionTime,Dword,28800000',
				'HKLM\SYSTEM\CurrentControlSet\Control\FileSystem,LongPathsEnabled,Dword,1'
				)
			$StandardServerWindowsUpdatePolicy = (
				'HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate,WUServer,String,http://update.clearmedia.be',
				'HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate,WUStatusServer,String,http://update.clearmedia.be',
				'HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate,SetActiveHours,Dword,1',
				'HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate,ActiveHoursStart,Dword,22',
				'HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate,ActiveHoursEnd,Dword,6',
				'HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU,AUOptions,Dword,3',
				'HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU,UseWUServer,Dword,1',
				'HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU,NoAutoRebootWithLoggedOnUsers,Dword,1',
				'HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Servicing,RepairContentServerSource,Dword,2'
				)
            $StandardServerFSLogixPolicy = (
				'HKLM\Software\FSLogix\Profiles,Enabled,Dword,1',
				'HKLM\Software\FSLogix\Profiles,ProfileType,Dword,0',
				'HKLM\Software\FSLogix\Profiles,SizeInMBs,Dword,51200',
				'HKLM\Software\FSLogix\Profiles,VHDLocations,String,D:\Users',
				'HKLM\Software\FSLogix\Profiles,VolumeType,String,VHDX',
				'HKLM\Software\FSLogix\Profiles,FlipFlopProfileDirectoryName,Dword,1'
				)
			# Create and Assemble User GPOs
			# Link User GPOs to OU Users
			$StandardUserPolicy = (
				'HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer,NoDrives,Dword,15',
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
			$StandardUserHardwareAccelerationPolicy = (
				'HKCU\Software\Policies\Google\Chrome,BackgroundModeEnabled,Dword,0',
				'HKCU\Software\Policies\Google\Chrome,HardwareAccelerationModeEnabled,Dword,0',
				'HKCU\SOFTWARE\Microsoft\Internet Explorer\Main,UseSWRender,Dword,1',
				'HKCU\Software\Adobe\Acrobat Reader\DC\3D,b3DAllowSelect,Dword,0',
				'HKCU\Software\Microsoft\Office\16.0\Common\Graphics,DisableHardwareAcceleration,Dword,1',
				'HKLM\Software\Policies\Microsoft\Edge,HardwareAccelerationModeEnabled,Dword,0'
				)
			$StandardUserO365Policy = (
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
			$StandardUserOutlookPolicy = (
				'HKCU\Software\policies\microsoft\office\16.0\outlook\cached mode,cachedexchangemode,Dword,2',
				'HKCU\Software\policies\microsoft\office\16.0\outlook\cached mode,enable,Dword,1',
				'HKCU\Software\policies\microsoft\office\16.0\outlook\cached mode,syncwindowsetting,Dword,6',
				'HKCU\Software\policies\microsoft\office\16.0\outlook\cached mode,syncwindowsettingdays,Dword,0'
				)
			If ( $CheckBoxStandardServerRDSPolicy ) {
				$GpoName = 'StandardServerRDSPolicy'
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxGPO.AddText(" Creating $GpoName `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarGPO.Value = $I } )
				New-GPO -Server $env:COMPUTERNAME -Name $GpoName -ErrorAction Continue
				If ( $error ) {
                    $ErrorList += "New-GPO -Name $GpoName -ErrorAction Stop"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxGPO.AddText(" Linking $GpoName to $RdsOuPath `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarGPO.Value = $I } )
				New-GPLink -Server $env:COMPUTERNAME -Name "$GpoName" -Target "$RdsOuPath" -ErrorAction Continue
				If ( $error ) {
                    $ErrorList += "New-GPLink -Name $GpoName -Target $RdsOuPath -ErrorAction Stop"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxGPO.AddText(" Injecting $GpoName Keys `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarGPO.Value = $I } )
				$StandardServerRDSPolicy | ForEach-Object {
					$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarGPO.Value = $I } )
					$Table = $_.Split(',')
					If ( $Table[2] -eq 'Dword' ) { [INT]$Value = $Table[3] } Else { [STRING]$Value = $Table[3] }
					Set-GPRegistryValue -Server $env:COMPUTERNAME -Name "$GpoName" -Key $Table[0] -ValueName $Table[1] -Type $Table[2] -Value $Value  -ErrorAction Continue
					If ( $error ) {
                        $ErrorList += "Set-GPRegistryValue -Name $GpoName -Key $Table[0] -ValueName $Table[1] -Type $Table[2] -Value $Value  -ErrorAction Stop"
                        $ErrorList += $error[0].Exception.Message.ToString()
                        $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                        $Error.Clear()
                        }
					}
				}
			If ( $CheckBoxStandardServerWindowsUpdatePolicy ) {
				$GpoName = 'StandardServerWindowsUpdatePolicy'
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxGPO.AddText(" Creating $GpoName `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarGPO.Value = $I } )
				New-GPO -Server $env:COMPUTERNAME -Name $GpoName -ErrorAction Ignore
				If ( $error ) {
                    $ErrorList += "New-GPO -Name $GpoName -ErrorAction Stop"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxGPO.AddText(" Linking $GpoName to $RdsOuPath `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarGPO.Value = $I } )
				New-GPLink -Server $env:COMPUTERNAME -Name "$GpoName" -Target "$RdsOuPath" -ErrorAction Continue
				If ( $error ) {
                    $ErrorList += "New-GPLink -Name $GpoName -Target $RdsOuPath -ErrorAction Stop"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxGPO.AddText(" Linking $GpoName to OU=Domain Controllers,$ADRootDSE `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarGPO.Value = $I } )
				New-GPLink -Server $env:COMPUTERNAME -Name "$GpoName" -Target "OU=Domain Controllers,$ADRootDSE" -ErrorAction Continue
				If ( $error ) {
                    $ErrorList += "New-GPLink -Name $GpoName -Target OU=Domain Controllers,$ADRootDSE -ErrorAction Stop"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxGPO.AddText(" Injecting $GpoName Keys `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarGPO.Value = $I } )
				$StandardServerWindowsUpdatePolicy | ForEach-Object {
					$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarGPO.Value = $I } )
					$Table = $_.Split(',')
					If ( $Table[2] -eq 'Dword' ) { [INT]$Value = $Table[3] } Else { [STRING]$Value = $Table[3] }
					Set-GPRegistryValue -Server $env:COMPUTERNAME -Name "$GpoName" -Key $Table[0] -ValueName $Table[1] -Type $Table[2] -Value $Value  -ErrorAction Continue
					If ( $error ) {
                        $ErrorList += "Set-GPRegistryValue -Name $GpoName -Key $Table[0] -ValueName $Table[1] -Type $Table[2] -Value $Value  -ErrorAction Stop"
                        $ErrorList += $error[0].Exception.Message.ToString()
                        $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                        $Error.Clear()
                        }
					}
				}
			If ( $CheckBoxStandardServerFSLogixPolicy ) {
				$GpoName = 'StandardServerFSLogixPolicy'
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxGPO.AddText(" Creating $GpoName `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarGPO.Value = $I } )
				New-GPO -Server $env:COMPUTERNAME -Name $GpoName -ErrorAction Ignore
				If ( $error ) {
                    $ErrorList += "New-GPO -Name $GpoName -ErrorAction Stop"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxGPO.AddText(" Linking $GpoName to $RdsOuPath `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarGPO.Value = $I } )
				New-GPLink -Server $env:COMPUTERNAME -Name "$GpoName" -Target "$RdsOuPath" -ErrorAction Continue
				If ( $error ) {
                    $ErrorList += "New-GPLink -Name $GpoName -Target $RdsOuPath -ErrorAction Stop"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxGPO.AddText(" Creating - Importing $GpoName `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarGPO.Value = $I } )
                Push-Location 'C:\Install\GPO'
                New-Item -ItemType Directory -Force -Path '{049AD0DA-164D-4B1A-BFC8-6A6757A03FAA}\DomainSysvol\GPO\User' , '{049AD0DA-164D-4B1A-BFC8-6A6757A03FAA}\DomainSysvol\GPO\Machine\Scripts\Shutdown' , '{049AD0DA-164D-4B1A-BFC8-6A6757A03FAA}\DomainSysvol\GPO\Machine\Scripts\Startup' , '{049AD0DA-164D-4B1A-BFC8-6A6757A03FAA}\DomainSysvol\GPO\Machine\microsoft\windows nt\SecEdit'
                $GptTmpl = @"
[Unicode]
Unicode=yes
[Version]
signature="$('$')CHICAGO$('$')"
Revision=1
[Group Membership]
FSLogix Profile Include List__Memberof =
FSLogix Profile Include List__Members = FSLogix-Users
"@
                $GptTmpl | Out-File -FilePath '{049AD0DA-164D-4B1A-BFC8-6A6757A03FAA}\DomainSysvol\GPO\Machine\microsoft\windows nt\SecEdit\GptTmpl.inf'-Encoding ascii -Force
                $BackupXML = @'
<?xml version="1.0" encoding="utf-8"?><!-- Copyright (c) Microsoft Corporation.  All rights reserved. -->
<GroupPolicyBackupScheme bkp:version="2.0" bkp:type="GroupPolicyBackupTemplate" xmlns:bkp="http://www.microsoft.com/GroupPolicy/GPOOperations" xmlns="http://www.microsoft.com/GroupPolicy/GPOOperations">
<GroupPolicyObject>
<SecurityGroups><Group><Sid/><SamAccountName><![CDATA[FSLogix Profile Include List]]></SamAccountName><Type><![CDATA[Unknown]]></Type><NetBIOSDomainName/><DnsDomainName/><UPN/></Group><Group><Sid/><SamAccountName><![CDATA[FSLogix-Users]]></SamAccountName><Type><![CDATA[Unknown]]></Type><NetBIOSDomainName/><DnsDomainName/><UPN/></Group><Group bkp:Source="FromDACL"><Sid><![CDATA[S-1-5-21-1458650225-1119023680-1635465439-519]]></Sid><SamAccountName><![CDATA[Enterprise Admins]]></SamAccountName><Type><![CDATA[UniversalGroup]]></Type><NetBIOSDomainName><![CDATA[ClearMedia]]></NetBIOSDomainName><DnsDomainName><![CDATA[ClearMedia.cloud]]></DnsDomainName><UPN><![CDATA[Enterprise Admins@ClearMedia.cloud]]></UPN></Group><Group bkp:Source="FromDACL"><Sid><![CDATA[S-1-5-21-1458650225-1119023680-1635465439-512]]></Sid><SamAccountName><![CDATA[Domain Admins]]></SamAccountName><Type><![CDATA[GlobalGroup]]></Type><NetBIOSDomainName><![CDATA[ClearMedia]]></NetBIOSDomainName><DnsDomainName><![CDATA[ClearMedia.cloud]]></DnsDomainName><UPN><![CDATA[Domain Admins@ClearMedia.cloud]]></UPN></Group></SecurityGroups><FilePaths/><GroupPolicyCoreSettings><ID><![CDATA[{7FF64648-7C3F-4A80-A967-B9BBA2A17DD8}]]></ID><Domain><![CDATA[ClearMedia.cloud]]></Domain><SecurityDescriptor>01 00 04 9c 00 00 00 00 00 00 00 00 00 00 00 00 14 00 00 00 04 00 ec 00 08 00 00 00 05 02 28 00 00 01 00 00 01 00 00 00 8f fd ac ed b3 ff d1 11 b4 1d 00 a0 c9 68 f9 39 01 01 00 00 00 00 00 05 0b 00 00 00 00 00 24 00 ff 00 0f 00 01 05 00 00 00 00 00 05 15 00 00 00 71 3c f1 56 40 f2 b2 42 df 38 7b 61 00 02 00 00 00 02 24 00 ff 00 0f 00 01 05 00 00 00 00 00 05 15 00 00 00 71 3c f1 56 40 f2 b2 42 df 38 7b 61 00 02 00 00 00 02 24 00 ff 00 0f 00 01 05 00 00 00 00 00 05 15 00 00 00 71 3c f1 56 40 f2 b2 42 df 38 7b 61 07 02 00 00 00 02 14 00 94 00 02 00 01 01 00 00 00 00 00 05 09 00 00 00 00 02 14 00 94 00 02 00 01 01 00 00 00 00 00 05 0b 00 00 00 00 02 14 00 ff 00 0f 00 01 01 00 00 00 00 00 05 12 00 00 00 00 0a 14 00 ff 00 0f 00 01 01 00 00 00 00 00 03 00 00 00 00</SecurityDescriptor><DisplayName><![CDATA[FSLogixRestrictedGroups]]></DisplayName><Options><![CDATA[1]]></Options><UserVersionNumber><![CDATA[0]]></UserVersionNumber><MachineVersionNumber><![CDATA[65537]]></MachineVersionNumber><MachineExtensionGuids><![CDATA[[{827D319E-6EAC-11D2-A4EA-00C04F79F83A}{803E14A0-B4FB-11D0-A0D0-00A0C90F574B}]]]></MachineExtensionGuids><UserExtensionGuids/><WMIFilter/></GroupPolicyCoreSettings> 
<GroupPolicyExtension bkp:ID="{35378EAC-683F-11D2-A89A-00C04FBBCFA2}" bkp:DescName="Registry"><FSObjectFile bkp:Path="%GPO_FSPATH%\Adm\*.*" bkp:SourceExpandedPath="\\DC.ClearMedia.cloud\sysvol\ClearMedia.cloud\Policies\{7FF64648-7C3F-4A80-A967-B9BBA2A17DD8}\Adm\*.*"/></GroupPolicyExtension>
<GroupPolicyExtension bkp:ID="{827D319E-6EAC-11D2-A4EA-00C04F79F83A}" bkp:DescName="Security"><FSObjectFile bkp:Path="%GPO_MACH_FSPATH%\microsoft\windows nt\SecEdit\GptTmpl.inf" bkp:SourceExpandedPath="\\DC.ClearMedia.cloud\sysvol\ClearMedia.cloud\Policies\{7FF64648-7C3F-4A80-A967-B9BBA2A17DD8}\Machine\microsoft\windows nt\SecEdit\GptTmpl.inf" bkp:ReEvaluateFunction="SecurityValidateSettings" bkp:Location="DomainSysvol\GPO\Machine\microsoft\windows nt\SecEdit\GptTmpl.inf"/></GroupPolicyExtension>
<GroupPolicyExtension bkp:ID="{F15C46CD-82A0-4C2D-A210-5D0D3182A418}" bkp:DescName="Unknown Extension"><FSObjectDir bkp:Path="%GPO_MACH_FSPATH%\Microsoft" bkp:SourceExpandedPath="\\DC.ClearMedia.cloud\sysvol\ClearMedia.cloud\Policies\{7FF64648-7C3F-4A80-A967-B9BBA2A17DD8}\Machine\Microsoft" bkp:Location="DomainSysvol\GPO\Machine\Microsoft"/><FSObjectDir bkp:Path="%GPO_MACH_FSPATH%\Microsoft\Windows NT" bkp:SourceExpandedPath="\\DC.ClearMedia.cloud\sysvol\ClearMedia.cloud\Policies\{7FF64648-7C3F-4A80-A967-B9BBA2A17DD8}\Machine\Microsoft\Windows NT" bkp:Location="DomainSysvol\GPO\Machine\Microsoft\Windows NT"/><FSObjectDir bkp:Path="%GPO_MACH_FSPATH%\Microsoft\Windows NT\SecEdit" bkp:SourceExpandedPath="\\DC.ClearMedia.cloud\sysvol\ClearMedia.cloud\Policies\{7FF64648-7C3F-4A80-A967-B9BBA2A17DD8}\Machine\Microsoft\Windows NT\SecEdit" bkp:Location="DomainSysvol\GPO\Machine\Microsoft\Windows NT\SecEdit"/><FSObjectDir bkp:Path="%GPO_MACH_FSPATH%\Scripts" bkp:SourceExpandedPath="\\DC.ClearMedia.cloud\sysvol\ClearMedia.cloud\Policies\{7FF64648-7C3F-4A80-A967-B9BBA2A17DD8}\Machine\Scripts" bkp:Location="DomainSysvol\GPO\Machine\Scripts"/><FSObjectDir bkp:Path="%GPO_MACH_FSPATH%\Scripts\Shutdown" bkp:SourceExpandedPath="\\DC.ClearMedia.cloud\sysvol\ClearMedia.cloud\Policies\{7FF64648-7C3F-4A80-A967-B9BBA2A17DD8}\Machine\Scripts\Shutdown" bkp:Location="DomainSysvol\GPO\Machine\Scripts\Shutdown"/><FSObjectDir bkp:Path="%GPO_MACH_FSPATH%\Scripts\Startup" bkp:SourceExpandedPath="\\DC.ClearMedia.cloud\sysvol\ClearMedia.cloud\Policies\{7FF64648-7C3F-4A80-A967-B9BBA2A17DD8}\Machine\Scripts\Startup" bkp:Location="DomainSysvol\GPO\Machine\Scripts\Startup"/></GroupPolicyExtension>
</GroupPolicyObject>
</GroupPolicyBackupScheme>
'@
                $BackupXML | Out-File -FilePath '{049AD0DA-164D-4B1A-BFC8-6A6757A03FAA}\Backup.xml' -Encoding ascii -Force
                $bkupInfoXML = @'
<BackupInst xmlns="http://www.microsoft.com/GroupPolicy/GPOOperations/Manifest"><GPOGuid><![CDATA[{7FF64648-7C3F-4A80-A967-B9BBA2A17DD8}]]></GPOGuid><GPODomain><![CDATA[ClearMedia.cloud]]></GPODomain><GPODomainGuid><![CDATA[{b591e442-9b2a-4b3f-8572-3e3ceba3477c}]]></GPODomainGuid><GPODomainController><![CDATA[DC.ClearMedia.cloud]]></GPODomainController><BackupTime><![CDATA[2022-03-10T12:21:53]]></BackupTime><ID><![CDATA[{049AD0DA-164D-4B1A-BFC8-6A6757A03FAA}]]></ID><Comment><![CDATA[]]></Comment><GPODisplayName><![CDATA[FSLogixRestrictedGroups]]></GPODisplayName></BackupInst>
'@
                $bkupInfoXML | Out-File -FilePath '{049AD0DA-164D-4B1A-BFC8-6A6757A03FAA}\bkupInfo.xml' -Encoding ascii -Force
                Import-GPO -BackupGpoName FSLogixRestrictedGroups -Path C:\Install\GPO -TargetName $GpoName -CreateIfNeeded
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxGPO.AddText(" Injecting $GpoName Keys `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarGPO.Value = $I } )
				$StandardServerFSLogixPolicy | ForEach-Object {
					$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarGPO.Value = $I } )
					$Table = $_.Split(',')
					If ( $Table[2] -eq 'Dword' ) { [INT]$Value = $Table[3] } Else { [STRING]$Value = $Table[3] }
					Set-GPRegistryValue -Server $env:COMPUTERNAME -Name "$GpoName" -Key $Table[0] -ValueName $Table[1] -Type $Table[2] -Value $Value  -ErrorAction Continue
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
				$GpoName = 'StandardUserPolicy'
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxGPO.AddText(" Creating $GpoName `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarGPO.Value = $I } )
				New-GPO -Server $env:COMPUTERNAME -Name $GpoName -ErrorAction Ignore
				If ( $error ) {
                    $ErrorList += "New-GPO -Name $GpoName -ErrorAction Stop"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxGPO.AddText(" Linking $GpoName  Policy to $FullUsersOuPath `n") } )
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxGPO.AddText(" Linking $GpoName  Policy to $LightUsersOuPath `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarGPO.Value = $I } )
				New-GPLink -Server $env:COMPUTERNAME -Name "$GpoName" -Target "$FullUsersOuPath" -ErrorAction Continue
				New-GPLink -Server $env:COMPUTERNAME -Name "$GpoName" -Target "$LightUsersOuPath" -ErrorAction Continue
				If ( $error ) {
                    $ErrorList += "New-GPLink -Name $GpoName -Target $UsersOuPath -ErrorAction Stop"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxGPO.AddText(" Injecting $GpoName  Policy Keys `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarGPO.Value = $I } )
				$StandardUserPolicy | ForEach-Object {
					$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarGPO.Value = $I } )
					$Table = $_.Split(',')
					If ( $Table[2] -eq 'Dword' ) { [INT]$Value = $Table[3] } Else { [STRING]$Value = $Table[3] }
					Set-GPRegistryValue -Server $env:COMPUTERNAME -Name "$GpoName" -Key $Table[0] -ValueName $Table[1] -Type $Table[2] -Value $Value  -ErrorAction Continue
					If ( $error ) {
                        $ErrorList += "Set-GPRegistryValue -Name $GpoName -Key $Table[0] -ValueName $Table[1] -Type $Table[2] -Value $Value  -ErrorAction Stop"
                        $ErrorList += $error[0].Exception.Message.ToString()
                        $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                        $Error.Clear()
                        }
					}
				}
			If ( $CheckBoxStandardUserHardwareAccelerationPolicy ) {
				$FullUsersOuPath = $UsersOuPath.Insert(0,'OU=Full Users,')
				$LightUsersOuPath = $UsersOuPath.Insert(0,'OU=Light Users,')
				$GpoName = 'StandardUserHardwareAccelerationPolicy'
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxGPO.AddText(" Creating $GpoName `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarGPO.Value = $I } )
				New-GPO -Server $env:COMPUTERNAME -Name $GpoName -ErrorAction Ignore
				If ( $error ) {
                    $ErrorList += "New-GPO -Name $GpoName -ErrorAction Stop"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxGPO.AddText(" Linking $GpoName to $FullUsersOuPath `n") } )
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxGPO.AddText(" Linking $GpoName to $LightUsersOuPath `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarGPO.Value = $I } )
				New-GPLink -Server $env:COMPUTERNAME -Name "$GpoName" -Target "$FullUsersOuPath" -ErrorAction Continue
				New-GPLink -Server $env:COMPUTERNAME -Name "$GpoName" -Target "$LightUsersOuPath" -ErrorAction Continue
				If ( $error ) {
                    $ErrorList += "New-GPLink -Name $GpoName -Target $UsersOuPath -ErrorAction Stop"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxGPO.AddText(" Injecting $GpoName Keys `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarGPO.Value = $I } )
				$StandardUserHardwareAccelerationPolicy | ForEach-Object {
					$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarGPO.Value = $I } )
					$Table = $_.Split(',')
					If ( $Table[2] -eq 'Dword' ) { [INT]$Value = $Table[3] } Else { [STRING]$Value = $Table[3] }
					Set-GPRegistryValue -Server $env:COMPUTERNAME -Name "$GpoName" -Key $Table[0] -ValueName $Table[1] -Type $Table[2] -Value $Value  -ErrorAction Continue
					If ( $error ) {
                        $ErrorList += "Set-GPRegistryValue -Name $GpoName -Key $Table[0] -ValueName $Table[1] -Type $Table[2] -Value $Value  -ErrorAction Stop"
                        $ErrorList += $error[0].Exception.Message.ToString()
                        $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                        $Error.Clear()
                        }
					}
				}
			If ( $CheckBoxStandardUserO365Policy ) {
				$FullUsersOuPath = $UsersOuPath.Insert(0,'OU=Full Users,')
				$GpoName = 'StandardUserO365Policy'
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxGPO.AddText(" Creating $GpoName `n") } )
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarGPO.Value = $I } )
				New-GPO -Server $env:COMPUTERNAME -Name $GpoName -ErrorAction Ignore
				If ( $error ) {
                    $ErrorList += "New-GPO -Name $GpoName -ErrorAction Stop"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxGPO.AddText(" Linking $GpoName to $FullUsersOuPath `n") } )
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarGPO.Value = $I } )
				New-GPLink -Server $env:COMPUTERNAME -Name "$GpoName" -Target "$FullUsersOuPath" -ErrorAction Continue
				If ( $error ) {
                    $ErrorList += "New-GPLink -Name $GpoName -Target $UsersOuPath -ErrorAction Stop"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxGPO.AddText(" Injecting $GpoName Keys `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarGPO.Value = $I } )
				$StandardUserO365Policy | ForEach-Object {
					$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarGPO.Value = $I } )
					$Table = $_.Split(',')
					If ( $Table[2] -eq 'Dword' ) { [INT]$Value = $Table[3] } Else { [STRING]$Value = $Table[3] }
					Set-GPRegistryValue -Server $env:COMPUTERNAME -Name "$GpoName" -Key $Table[0] -ValueName $Table[1] -Type $Table[2] -Value $Value  -ErrorAction Continue
					If ( $error ) {
                        $ErrorList += "Set-GPRegistryValue -Name $GpoName -Key $Table[0] -ValueName $Table[1] -Type $Table[2] -Value $Value  -ErrorAction Stop"
                        $ErrorList += $error[0].Exception.Message.ToString()
                        $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                        $Error.Clear()
                        }
					}
				}
			If ( $CheckBoxStandardUserOutlookPolicy ) {
			$FullUsersOuPath = $UsersOuPath.Insert(0,'OU=Full Users,')
			$GpoName = 'StandardUserOutlookPolicy'
			$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxGPO.AddText(" Creating $GpoName `n") } ) 
			$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarGPO.Value = $I } )
			New-GPO -Server $env:COMPUTERNAME -Name $GpoName -ErrorAction Ignore
			If ( $error ) {
                    $ErrorList += "New-GPO -Name $GpoName -ErrorAction Stop"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }
			$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxGPO.AddText(" Linking $GpoName to $FullUsersOuPath `n") } )
			$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ;  $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarGPO.Value = $I } )
			New-GPLink -Server $env:COMPUTERNAME -Name "$GpoName" -Target "$FullUsersOuPath" -ErrorAction Continue
			If ( $error ) {
                    $ErrorList += "New-GPLink -Name $GpoName -Target $UsersOuPath -ErrorAction Stop"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }
			$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxGPO.AddText(" Injecting $GpoName Keys `n") } ) 
			$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarGPO.Value = $I } )
			$StandardUserOutlookPolicy | ForEach-Object {
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarGPO.Value = $I } )
				$Table = $_.Split(',')
				If ( $Table[2] -eq 'Dword' ) { [INT]$Value = $Table[3] } Else { [STRING]$Value = $Table[3] }
				Set-GPRegistryValue -Server $env:COMPUTERNAME -Name "$GpoName" -Key $Table[0] -ValueName $Table[1] -Type $Table[2] -Value $Value  -ErrorAction Continue
				If ( $error ) {
                        $ErrorList += "Set-GPRegistryValue -Name $GpoName -Key $Table[0] -ValueName $Table[1] -Type $Table[2] -Value $Value  -ErrorAction Stop"
                        $ErrorList += $error[0].Exception.Message.ToString()
                        $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                        $Error.Clear()
                        }
				}
			}
            $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarGPO.Visibility = "Hidden" } )
            If ( $ErrorList ) {
                (Get-Date).tostring('dd-MM-yyyy HH:mm:ss') | Out-File -FilePath "$env:windir\Logs\PushTheButtonError.log" -Append -Force
                $ErrorList | Out-File -FilePath "$env:windir\Logs\PushTheButtonError.log" -Append -Force
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.LabelStatusGPO.Content = "Deployment Finished with ERRORS $(' .'*115)$(' '*30)Please consult PushTheButtonError.log" } )
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployStandardGpoStart.IsEnabled = $True } )
				}
                Else
					{
					New-ItemProperty -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'RdsOuPath' -PropertyType 'String' -Value $RdsOuPath -Force
					New-ItemProperty -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'UsersOuPath' -PropertyType 'String' -Value $UsersOuPath -Force
					New-ItemProperty -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'DeployStandardGpoStart' -PropertyType 'String' -Value 'Hidden' -Force
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.LabelStatusGPO.Content = "Deployment Finished $(' .'*135)$(' '*30)" } )
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployStandardGpoStart.Visibility = "Hidden" } )
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployFolderRedirectionStart.IsEnabled = $True } )
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployRdsStart.IsEnabled = $True } )
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployO365Start.IsEnabled = $True } )
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployWUStart.IsEnabled = $True } )
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployUserStart.IsEnabled = $True } )
					}
		}
	$PSinstance = [powershell]::Create().AddScript($Code)
	$PSinstance.Runspace = $Runspace
	$job = $PSinstance.BeginInvoke()      
	}
Function DeployFolderRedirectionStart {
	Param($SyncHash,$CheckBoxDocuments,$DocumentsPath,$CheckBoxMusic,$MusicPath,$CheckBoxPictures,$PicturesPath,$CheckBoxVideos,$VideosPath,$UsersOuPath)
	$Runspace = [runspacefactory]::CreateRunspace()
	$Runspace.ApartmentState = "STA"
	$Runspace.ThreadOptions = "ReuseThread"
	$Runspace.Open()
	$Runspace.SessionStateProxy.SetVariable("SyncHash",$SyncHash)
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
			$I = 0
			# Create and Assemble User GPOs
			# Link User GPOs to OU Users
			If ( $CheckBoxDocuments -or $CheckBoxMusic -or $CheckBoxPictures -or $CheckBoxVideos ) {
				$FullUsersOuPath = $UsersOuPath.Insert( 0,'OU=Full Users,' )
				$LightUsersOuPath = $UsersOuPath.Insert( 0 , 'OU=Light Users,' )
				$GpoName = 'StandardUserFolderRedirectionPolicy'
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxFolderRedirection.AddText(" Creating $GpoName `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarFolderRedirection.Value = $I } )
				$Gpo = New-GPO -Server $env:COMPUTERNAME -Name $GpoName -ErrorAction Ignore
                [STRING]$PdcName = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().PdcRoleOwner.Name
                [STRING]$DomainName = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().Name
                $GpoPath = "\\$PdcName\SYSVOL\$DomainName\Policies\{$($Gpo.id.Guid)}"
                New-Item -Path "$GpoPath\Adm" -ItemType Directory -ErrorAction Continue -Force
                $StandardUserFolderRedirectionAdm = @"
CLASS USER
CATEGORY "User Folder Redirection"
    KEYNAME "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"
    POLICY "My Music"
        EXPLAIN "Path for My Music"
            PART "My Music Path" EDITTEXT REQUIRED
                VALUENAME "My Music"
                DEFAULT   $MusicPath
            END PART
    END POLICY
    POLICY "My Pictures"
        EXPLAIN "Path for My Pictures"
            PART "My Pictures Path" EDITTEXT REQUIRED
                VALUENAME "My Pictures"
                DEFAULT   $PicturesPath
            END PART
    END POLICY
    POLICY "My Video"
        EXPLAIN "Path for My Video"
            PART "My Video Path" EDITTEXT REQUIRED
                VALUENAME "My Video"
                DEFAULT   $VideosPath
            END PART
    END POLICY
    POLICY "My Documents"
        EXPLAIN "Path for My Documents"
            PART "My Documents Path" EDITTEXT REQUIRED
                VALUENAME "Personal"
                DEFAULT   $DocumentsPath
            END PART
    END POLICY
END CATEGORY
"@
                $StandardUserFolderRedirectionAdm | Out-File -FilePath "$GpoPath\Adm\StandardUserFolderRedirection.adm" -Encoding ascii -Force
				If ( $error ) {
                    $ErrorList += "New-GPO -Name $GpoName -ErrorAction Stop"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxFolderRedirection.AddText(" Linking $GpoName to $FullUsersOuPath `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarFolderRedirection.Value = $I } )
				New-GPLink -Server $env:COMPUTERNAME -Name "$GpoName" -Target "$FullUsersOuPath" -ErrorAction Continue
				New-GPLink -Server $env:COMPUTERNAME -Name "$GpoName" -Target "$LightUsersOuPath" -ErrorAction Continue
				If ( $error ) {
                    $ErrorList += "New-GPLink -Name $GpoName -Target $UsersOuPath -ErrorAction Stop"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxFolderRedirection.AddText(" Injecting $GpoName Keys `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarFolderRedirection.Value = $I } )
				}
			If ( $CheckBoxDocuments ) {
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxFolderRedirection.AddText(" Setting DocumentsPath to $DocumentsPath `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarFolderRedirection.Value = $I } )
				Set-GPRegistryValue -Server $env:COMPUTERNAME -Name $GpoName -Key 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -ValueName 'Personal' -Type 'ExpandString' -Value $DocumentsPath  -ErrorAction Continue
				If ( $error ) {
                    $ErrorList += "Set-GPRegistryValue -Name $GpoName -Key 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -ValueName 'Personal' -Type 'ExpandString' -Value $DocumentsPath  -ErrorAction Continue"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }            
				}
			If ( $CheckBoxMusic ) {
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarFolderRedirection.Value = $I } )
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxFolderRedirection.AddText(" Setting MusicPath to $MusicPath `n") } ) 
				Set-GPRegistryValue -Server $env:COMPUTERNAME -Name $GpoName -Key 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -ValueName 'My Music' -Type 'ExpandString' -Value $MusicPath  -ErrorAction Continue
				If ( $error ) {
                    $ErrorList += "Set-GPRegistryValue -Name $GpoName -Key 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -ValueName 'My Music' -Type 'ExpandString' -Value $MusicPath  -ErrorAction Continue"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }            
				}
			If ( $CheckBoxPictures ) {
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxFolderRedirection.AddText(" Setting PicturesPath to $PicturesPath `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarFolderRedirection.Value = $I } )
				Set-GPRegistryValue -Server $env:COMPUTERNAME -Name $GpoName -Key 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -ValueName 'My Pictures' -Type 'ExpandString' -Value $PicturesPath  -ErrorAction Continue
				If ( $error ) {
                    $ErrorList += "Set-GPRegistryValue -Name $GpoName -Key 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -ValueName 'My Pictures' -Type 'ExpandString' -Value $PicturesPath  -ErrorAction Continue"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }            
				}
			If ( $CheckBoxVideos ) {
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxFolderRedirection.AddText(" Setting VideosPath to $VideosPath `n") } ) 
				$I += 4 ; If ( $I -ge 100 ) { $I = 1 } ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarFolderRedirection.Value = $I } )
				Set-GPRegistryValue -Server $env:COMPUTERNAME -Name $GpoName -Key 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -ValueName 'My Video' -Type 'ExpandString' -Value $VideosPath  -ErrorAction Continue
				If ( $error ) {
                    $ErrorList += "Set-GPRegistryValue -Name $GpoName -Key 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -ValueName 'My Video' -Type 'ExpandString' -Value $VideosPath  -ErrorAction Continue"
                    $ErrorList += $error[0].Exception.Message.ToString()
                    $ErrorList += "TargetObject $($error[0].TargetObject.ToString())"
                    $Error.Clear()
                    }            
				}
	$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarFolderRedirection.Visibility = "Hidden" } )
	If ( $ErrorList ) {
		(Get-Date).tostring('dd-MM-yyyy HH:mm:ss') | Out-File -FilePath "$env:windir\Logs\PushTheButtonError.log" -Append -Force
		$ErrorList | Out-File -FilePath "$env:windir\Logs\PushTheButtonError.log" -Append -Force
		$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.LabelStatusFolderRedirection.Content = "Deployment Finished with ERRORS $(' .'*115)$(' '*30)Please consult PushTheButtonError.log" } )
		$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployFolderRedirectionStart.IsEnabled = $True } )    
        }
		Else {
			$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.LabelStatusFolderRedirection.Content = "Deployment Finished $(' .'*135)$(' '*30)" } )
			New-ItemProperty -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'DeployFolderRedirectionStart' -PropertyType 'String' -Value 'Hidden' -Force
			$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployFolderRedirectionStart.Visibility = "Hidden" } )
			$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployRdsStart.IsEnabled = $True } )
			$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployO365Start.IsEnabled = $True } )
			$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployWUStart.IsEnabled = $True } )
			$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployUserStart.IsEnabled = $True } )
			}
		}
	$PSinstance = [powershell]::Create().AddScript($Code)
	$PSinstance.Runspace = $Runspace
	$job = $PSinstance.BeginInvoke()       
	}
Function DeployRdsStart {
	Param( $SyncHash,$ServerIpAddress , $LocalAdminUserName , $LocalAdminPassword , $DomainAdminUserName , $DomainAdminPassword , $DomainDcServerName , $DomainDnsServerIpAddress , $FSLogixFolderRootPath , $DataFolderRootPath , $OuPath , $DomainDnsName , $CheckBoxRas , $RasLicenseEmail , $RasLicensePassword , $RasKey , $CheckBoxStandardServerFSLogixPolicy )
	$Runspace = [runspacefactory]::CreateRunspace()
	$Runspace.ApartmentState = "STA"
	$Runspace.ThreadOptions = "ReuseThread"
	$Runspace.Open()
	$Runspace.SessionStateProxy.SetVariable("SyncHash",$SyncHash)
	$Runspace.SessionStateProxy.SetVariable("ServerIpAddress",$ServerIpAddress)
	$Runspace.SessionStateProxy.SetVariable("LocalAdminUserName",$LocalAdminUserName)
	$Runspace.SessionStateProxy.SetVariable("LocalAdminPassword",$LocalAdminPassword)
	$Runspace.SessionStateProxy.SetVariable("DomainAdminUserName",$DomainAdminUserName)
	$Runspace.SessionStateProxy.SetVariable("DomainAdminPassword",$DomainAdminPassword)
	$Runspace.SessionStateProxy.SetVariable("DomainDcServerName",$DomainDcServerName)
	$Runspace.SessionStateProxy.SetVariable("DomainDnsServerIpAddress",$DomainDnsServerIpAddress)
	$Runspace.SessionStateProxy.SetVariable("FSLogixFolderRootPath",$FSLogixFolderRootPath)
	$Runspace.SessionStateProxy.SetVariable("DataFolderRootPath",$DataFolderRootPath)
	$Runspace.SessionStateProxy.SetVariable("OuPath",$OuPath)
	$Runspace.SessionStateProxy.SetVariable("DomainDnsName",$DomainDnsName)
	$Runspace.SessionStateProxy.SetVariable("CheckBoxRas",$CheckBoxRas)
	$Runspace.SessionStateProxy.SetVariable("RasLicenseEmail",$RasLicenseEmail)
	$Runspace.SessionStateProxy.SetVariable("RasLicensePassword",$RasLicensePassword)
	$Runspace.SessionStateProxy.SetVariable("RasKey",$RasKey)
	$Runspace.SessionStateProxy.SetVariable("CheckBoxStandardServerFSLogixPolicy",$CheckBoxStandardServerFSLogixPolicy)
	$code = {
            $I = 0
            $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarRDS.Value = $I } )
            $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxRDS.AddText(" Connecting to $ServerIpAddress `n") } )
            $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ( "$ServerIpAddress\$LocalAdminUserName", $( ConvertTo-SecureString -String $LocalAdminPassword -AsPlainText -Force ) )
            Set-Item WSMan:\localhost\Client\TrustedHosts -Value "$ServerIpAddress" -Force
            Try { 
                $PsSession = New-PSSession -ComputerName $ServerIpAddress -Credential $Credential -ErrorAction Stop
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBoxO365AdminUserName.Text = $LocalAdminUserName } ) 
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBoxO365AdminPassword.Text = $LocalAdminPassword } )
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBoxWuAdminUserName.Text = $LocalAdminUserName } )
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBoxWuAdminPassword.Text = $LocalAdminPassword } )
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBoxUSERLocalAdminUserName.Text = $LocalAdminUserName } )
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBoxUSERLocalAdminPassword.Text = $LocalAdminPassword } )
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBoxUSERDomainAdminUserName.Text = $DomainAdminUserName } ) 
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBoxUSERDomainAdminPassword.Text = $DomainAdminPassword } ) 
                }
                Catch {
                    $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarRDS.Visibility = "Hidden" } )
                    $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.LabelStatusRDS.Content = "Connection Failure $(' .'*130)$(' '*30)Please check Server - Username - Password" } )
                    $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployRdsStart.IsEnabled = $True } )
                    $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployRdsStart.Visibility = "Visible"  } )
                    Return
                    }
            $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxRDS.AddText(" Connected to $( Invoke-Command -Session $PsSession -ScriptBlock { [System.Net.Dns]::GetHostByName($env:computerName).HostName } ) `n") } )
            $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxRDS.AddText(" Testing Internet Connection `n") } )
            $Job = Invoke-Command -Session $PsSession -AsJob -JobName 'TestConnectionGoogle' -ScriptBlock { Test-Connection -ComputerName 'www.google.com' -Count 1 }
			While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarRDS.Value = $I } ) }
            If ( $Job.ChildJobs[0].Error ) {
                    $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarRDS.Visibility = "Hidden" } )
                    $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.LabelStatusRDS.Content = "Connection Failure $(' .'*130)$(' '*30)Please check Internet Connection" } )
                    $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployRdsStart.IsEnabled = $True } )
                    $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployRdsStart.Visibility = "Visible"  } )
                    Return
                    }
            If ( $FSLogixFolderRootPath -like '?:\*' ) {
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxRDS.AddText(" Configuring Disk 'FSLOGIX' `n") } )
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxRDS.AddText(" Creating $FSLogixFolderRootPath and Setting NTFS Security `n") } )
                $Job = Invoke-Command -Session $PsSession -AsJob -JobName 'DiskFSLogix' -ScriptBlock {
                    Param($FSLogixFolderRootPath)
                    If ( (get-disk -Number 1).AllocatedSize -eq 0 ) {
					    Initialize-Disk -Number 1
					    [STRING]$DriveLetter = $FSLogixFolderRootPath.Split(':')[0]
                        New-Partition -DiskNumber 1 -DriveLetter $DriveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel 'FSLOGIX'
                        # Remove All but System & Administrators from ACL on Root
						[STRING]$Folder = "$($DriveLetter):\"
						$ACL = Get-Acl -Path  $Folder
						$ACL.Access | Where-Object { $PSItem.IdentityReference -inotin ( 'NT AUTHORITY\SYSTEM','BUILTIN\Administrators' ) } | ForEach-Object { $ACL.RemoveAccessRule($PSItem) }
						Set-Acl -Path $Folder -AclObject $ACL
                        # Create User Folder
					    # $FSLogixFolderRootPath = 'D:\Users'
                        New-Item -Path $FSLogixFolderRootPath -type directory -Force
					    $ACL = Get-Acl  -Path  $FSLogixFolderRootPath
					    # Disable Inheritance
					    $ACL.SetAccessRuleProtection($true,$false)
					    # Add FSLogix Permissions on $FSLogixFolderRootPath
						$AccessRule = New-Object system.security.AccessControl.FileSystemAccessRule( 'NT AUTHORITY\SYSTEM' , 'FullControl' , 'ObjectInherit , ContainerInherit' , 'None' , 'Allow')
						$ACL.AddAccessRule($AccessRule)
						$AccessRule = New-Object system.security.AccessControl.FileSystemAccessRule( 'BUILTIN\Administrators' , 'FullControl' , 'ObjectInherit , ContainerInherit' , 'None' , 'Allow')
						$ACL.AddAccessRule($AccessRule)
						$AccessRule = New-Object system.security.AccessControl.FileSystemAccessRule( 'NT AUTHORITY\Creator Owner' , 'FullControl' , 'ObjectInherit , ContainerInherit' , 'None' , 'Allow')
						$ACL.AddAccessRule($AccessRule)
						$AccessRule = New-Object system.security.AccessControl.FileSystemAccessRule( 'BUILTIN\Users' , 'ReadData , AppendData , ExecuteFile , ReadAttributes' , 'None', 'None' , 'Allow')
						$ACL.AddAccessRule($AccessRule)
						Set-Acl -Path $FSLogixFolderRootPath -AclObject $ACL
					    }
                    } -ArgumentList ($FSLogixFolderRootPath) 
                While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarRDS.Value = $I } ) }
                }
            If ( $FSLogixFolderRootPath -like '\\*' ) {
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxRDS.AddText(" Configuring Share 'FSLOGIX' `n") } )
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxRDS.AddText(" Creating $FSLogixFolderRootPath and Setting NTFS Security `n") } )
                $Job = Invoke-Command -ComputerName 'localhost' -AsJob -JobName 'ShareFSLogix' -ScriptBlock {
                    Param( $FSLogixFolderRootPath )
					# Remove All but System & Administrators from ACL on Root
                    [STRING]$Folder = "\\$( $FSLogixFolderRootPath.split( '\' )[2,3] -join '\' )"
                    $ACL = Get-Acl -Path  $Folder
                    $ACL.Access | Where-Object { $PSItem.IdentityReference -inotin ( 'NT AUTHORITY\SYSTEM','BUILTIN\Administrators' ) } | ForEach-Object { $ACL.RemoveAccessRule($PSItem) }
                    Set-Acl -Path $Folder -AclObject $ACL
					# Create User Folder
                    New-Item -Path $FSLogixFolderRootPath -type directory -Force
                    $ACL = Get-Acl -Path  $FSLogixFolderRootPath
                    $ACL.SetAccessRuleProtection($true,$false)
					# Add FSLogix Permissions on $FSLogixFolderRootPath
                    $AccessRule = New-Object system.security.AccessControl.FileSystemAccessRule( 'NT AUTHORITY\SYSTEM' , 'FullControl' , 'ObjectInherit , ContainerInherit' , 'None' , 'Allow')
                    $ACL.AddAccessRule($AccessRule)
                    $AccessRule = New-Object system.security.AccessControl.FileSystemAccessRule( 'BUILTIN\Administrators' , 'FullControl' , 'ObjectInherit , ContainerInherit' , 'None' , 'Allow')
                    $ACL.AddAccessRule($AccessRule)
                    $AccessRule = New-Object system.security.AccessControl.FileSystemAccessRule( 'NT AUTHORITY\Creator Owner' , 'FullControl' , 'ObjectInherit , ContainerInherit' , 'None' , 'Allow')
                    $ACL.AddAccessRule($AccessRule)
                    $AccessRule = New-Object system.security.AccessControl.FileSystemAccessRule( 'BUILTIN\Users' , 'ReadData , AppendData , ExecuteFile , ReadAttributes' , 'None', 'None' , 'Allow')
                    $ACL.AddAccessRule($AccessRule)
                    Set-Acl -Path $FSLogixFolderRootPath -AclObject $ACL
                    $GpoName = 'StandardServerFSLogixPolicy'
                    } -ArgumentList ( $FSLogixFolderRootPath ) 
                While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarRDS.Value = $I } ) }
                }
            If ( $DataFolderRootPath -like '?:\*' ) {
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxRDS.AddText(" Configuring Disk 'DATA' `n") } )
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxRDS.AddText(" Creating $DataFolderRootPath and Setting NTFS Security `n") } )
			    $Job = Invoke-Command -Session $PsSession -AsJob -JobName 'DiskData' -ScriptBlock {
                    Param($DataFolderRootPath)
                    If ( (get-disk -Number 2).AllocatedSize -eq 0 ) {
					    Initialize-Disk -Number 2
					    [STRING]$DriveLetter = $DataFolderRootPath.Split(':')[0]
					    New-Partition -DiskNumber 2 -DriveLetter $DriveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel 'DATA'
					    # Remove All but System & Administrators from ACL on Root
						[STRING]$Folder = "$($DriveLetter):\"
						$ACL = Get-Acl -Path  $Folder
						$ACL.Access | Where-Object { $PSItem.IdentityReference -inotin ( 'NT AUTHORITY\SYSTEM','BUILTIN\Administrators' ) } | ForEach-Object { $ACL.RemoveAccessRule($PSItem) }
						Set-Acl -Path $Folder -AclObject $ACL
					    # Add Users with Folder List Only to ACL on Root
					    $AccessRule = New-Object system.security.AccessControl.FileSystemAccessRule('BUILTIN\Users', 'ReadData, ReadAttributes, Traverse', 'None', 'None', 'Allow')
					    $ACL.AddAccessRule($AccessRule)
					    Set-Acl -Path $Folder -AclObject $ACL
					    # Create User Folder
					    # $DataFolderRootPath = 'E:\Users'
					    New-Item -Path $DataFolderRootPath -type directory -Force
					    $ACL = Get-Acl  -Path  $DataFolderRootPath
					    # Disable Inheritance
					    $ACL.SetAccessRuleProtection($true,$true)
					    # Add Users with Folder List Only to ACL on $DataFolderRootPath
					    $AccessRule = New-Object system.security.AccessControl.FileSystemAccessRule('BUILTIN\Users', 'ReadData, ReadAttributes, Traverse', 'None', 'None', 'Allow')
					    $ACL.AddAccessRule($AccessRule)
					    Set-Acl -Path $DataFolderRootPath -AclObject $ACL
					    }
                    } -ArgumentList ($DataFolderRootPath)
                While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarRDS.Value = $I } ) }
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxRDS.AddText(" Installing FsLogix with Chocolatey `n") } )   
                }
            If ( $DataFolderRootPath -like '\\*' ) {
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxRDS.AddText(" Configuring Share 'DataFolder' `n") } )
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxRDS.AddText(" Creating $DataFolderRootPath and Setting NTFS Security `n") } )
                $Job = Invoke-Command -ComputerName 'localhost' -AsJob -JobName 'DataFolder' -ScriptBlock {
                    Param( $DataFolderRootPath )
                    [STRING]$Folder = "\\$( $DataFolderRootPath.split( '\' )[2,3] -join '\' )"
					$ACL = Get-Acl -Path  $Folder
					$ACL.Access | Where-Object { $PSItem.IdentityReference -inotin ( 'NT AUTHORITY\SYSTEM','BUILTIN\Administrators' ) } | ForEach-Object { $ACL.RemoveAccessRule($PSItem) }
					Set-Acl -Path $Folder -AclObject $ACL
					# Add Users with Folder List Only to ACL on Root
					$AccessRule = New-Object system.security.AccessControl.FileSystemAccessRule('BUILTIN\Users', 'ReadData, ReadAttributes, Traverse', 'None', 'None', 'Allow')
					$ACL.AddAccessRule($AccessRule)
					Set-Acl -Path $Folder -AclObject $ACL
					# Create User Folder
					# $DataFolderRootPath = 'E:\Users'
					New-Item -Path $DataFolderRootPath -type directory -Force
					$ACL = Get-Acl  -Path  $DataFolderRootPath
					# Disable Inheritance
					$ACL.SetAccessRuleProtection($true,$true)
					# Add Users with Folder List Only to ACL on $DataFolderRootPath
					$AccessRule = New-Object system.security.AccessControl.FileSystemAccessRule('BUILTIN\Users', 'ReadData, ReadAttributes, Traverse', 'None', 'None', 'Allow')
					$ACL.AddAccessRule($AccessRule)
					Set-Acl -Path $DataFolderRootPath -AclObject $ACL
                    } -ArgumentList ( $DataFolderRootPath ) 
                While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarRDS.Value = $I } ) }
                }
            $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxRDS.AddText(" Downloading and Installing FSLogix `n") } )
            $Job = Invoke-Command -Session $PsSession -AsJob -JobName 'Install FsLogix' -ScriptBlock {
				[System.Net.ServicePointManager]::SecurityProtocol = 'Tls12'
                		# Install Chocolatey as Package Manager
				Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')
				# Install FsLogix
				Invoke-Expression -Command '& C:\ProgramData\chocolatey\choco install fslogix -y -f'
				}
            While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarRDS.Value = $I } ) }
            $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxRDS.AddText(" Enabling FsLogix Profile Container `n") } ) 
			$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxRDS.AddText(" Setting FsLogix Profile Root to $FSLogixFolderRootPath `n") } )
            $Job = Invoke-Command -Session $PsSession -AsJob -JobName 'Enable FsLogix Profile Container' -ScriptBlock {
				Param($FSLogixFolderRootPath)
				New-ItemProperty -Path 'HKLM\Software\FSLogix\Profiles' -Name 'Enabled' -PropertyType 'Dword' -Value 1 -Force
				New-ItemProperty -Path 'HKLM\Software\FSLogix\Profiles' -Name 'ProfileType' -PropertyType 'Dword' -Value 0 -Force
				New-ItemProperty -Path 'HKLM\Software\FSLogix\Profiles' -Name 'SizeInMBs' -PropertyType 'Dword' -Value 51200 -Force
				New-ItemProperty -Path 'HKLM\Software\FSLogix\Profiles' -Name 'VHDLocations' -PropertyType 'String' -Value $FSLogixFolderRootPath -Force
				New-ItemProperty -Path 'HKLM\Software\FSLogix\Profiles' -Name 'VolumeType' -PropertyType 'String' -Value 'VHDX' -Force
				} -ArgumentList ($FSLogixFolderRootPath)
            While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarRDS.Value = $I } ) }
            $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxRDS.AddText(" Setting Smart Card Service to AutoStart `n") } )   
            $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxRDS.AddText(" Setting Windows Audio Service to AutoStart `n") } )   
            $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxRDS.AddText(" Setting Windows Search Service to AutoStart `n") } )
			$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxRDS.AddText(" Setting Printer Spooler Service to AutoStart `n") } )			
            $Job = Invoke-Command -Session $PsSession -AsJob -JobName 'RdsServices' -ScriptBlock {
				$Services = @{
					'Audiosrv' = 'Auto'
					'SCardSvr' = 'Auto'
					'WSearch'  = 'Auto'
					'Spooler'  = 'Auto'
					}
				$Services.keys | ForEach-Object { Set-Service -Name $_ -StartupType $($Services.$_) }
				}
            While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarRDS.Value = $I } ) }
            $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxRDS.AddText(" Installing Windows TIFF IFilter `n") } )
            $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxRDS.AddText(" Installing Remote Desktop Services `n") } )
            $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxRDS.AddText(" Installing Group Policy Management `n") } )
            $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxRDS.AddText(" Installing Remote Server Administration Tools `n") } )
			$Job = Invoke-Command -Session $PsSession  -AsJob -JobName 'RdsRoles' -ScriptBlock {
				$Roles = [ordered]@{
					'Windows TIFF IFilter'    = 'Windows-TIFF-IFilter'
					'Remote Desktop Services' = 'RDS-RD-Server'
					'Group Policy Management' = 'GPMC'
					'Remote Server Administration Tools' = ('RSAT-AD-Tools','RSAT-DNS-Server','RSAT-RDS-Licensing-Diagnosis-UI','RDS-Licensing-UI')
					}
				$Roles.Values | ForEach-Object { Install-WindowsFeature -Name $_ }
				}
			While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarRDS.Value = $I } ) }
            $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxRDS.AddText(" Configuring IPv4 DNS IP $DomainDnsServerIpAddress `n") } )
            $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxRDS.AddText(" Joining to Domain $DomainDnsName @ $DomainDcServerName in $OuPath `n") } )
            $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxRDS.AddText(" Renaming NetBiosName to $ServerName `n") } )
            $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxRDS.AddText(" Disabling Fair Share on CPU, Disk, Network `n") } )
			$Job = Invoke-Command -Session $PsSession -AsJob -JobName 'RenameJoinRDS' -ScriptBlock {
				Param($ServerIpAddress,$ServerName,$DomainAdminUserName,$DomainAdminPassword,$OuPath,$DomainDnsName,$DomainDnsServerIpAddress,$DomainDcServerName) ; 
				Get-NetIPConfiguration | Set-DnsClientServerAddress -ServerAddresses $DomainDnsServerIpAddress
				$DomainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ("$($DomainAdminUserName)@$($DomainDnsName)", $(ConvertTo-SecureString -String $DomainAdminPassword -AsPlainText -Force))
				Add-Computer -Server $DomainDcServerName -DomainName $DomainDnsName -OUPath $OuPath -Credential $DomainCredential -Force
				Rename-Computer -NewName $ServerName -DomainCredential $DomainCredential -Force
				Get-CimInstance -Namespace 'root/cimv2/TerminalServices' -ClassName Win32_TerminalServiceSetting | Set-CimInstance -argument  @{EnableDFSS=0;EnableDiskFSS=0;EnableNetworkFSS=0}
				} -ArgumentList ($ServerIpAddress,$ServerName,$DomainAdminUserName,$DomainAdminPassword,$OuPath,$DomainDnsName,$DomainDnsServerIpAddress,$DomainDcServerName) 
            While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarRDS.Value = $I } ) }
            $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxRDS.AddText(" Adding Administrators to 'FSLogix Profile Exclude List' Group `n") } ) 
            $Job = Invoke-Command -Session $PsSession -AsJob -JobName 'PurgeFsLogixGroups' -ScriptBlock {
				Param($DomainDnsName)
				$DomainNetbiosName = $DomainDnsName.Split('.')[0]
				Add-LocalGroupMember -Name 'FSLogix ODFC Exclude List' -Member 'Administrator'
				Add-LocalGroupMember -Name 'FSLogix ODFC Exclude List' -Member "$($DomainNetbiosName)\Domain Admins"
				Add-LocalGroupMember -Name 'FSLogix Profile Exclude List' -Member 'Administrator'
				Add-LocalGroupMember -Name 'FSLogix Profile Exclude List' -Member "$($DomainNetbiosName)\Domain Admins"
				Add-LocalGroupMember -Name 'Remote Desktop Users' -Member "$($DomainNetbiosName)\RDP-Users"
				} -ArgumentList ($DomainDnsName)
            While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarRDS.Value = $I } ) }
            If ( $CheckBoxRas ) {
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxRDS.AddText(" Downloading and Installing Parallels RAS version 18.3.22908 `n") } )
				$Job = Invoke-Command -Session $PsSession -AsJob -JobName 'Download and Install Parallels RAS version 18.3.22908' -ScriptBlock {
					# https://www.parallels.com/products/ras/download/links/
					[STRING]$UrlDownload =  'https://download.parallels.com/ras/v18/18.3.1.22908/RASInstaller-18.3.22908.msi'
					[STRING]$FileDownload = "$ENV:LOCALAPPDATA\$($UrlDownload.Split('/')[-1])"
					Invoke-WebRequest -Uri $UrlDownload -UseBasicParsing  -OutFile $FileDownload -PassThru | Out-Null
					Invoke-Expression -Command "CMD.exe /C 'MsiExec.exe /i $FileDownload /qn /norestart'"
					}
                While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarRDS.Value = $I } ) }
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxRDS.AddText(" Deploying Parallels RDS Farm `n") } )
				$Job = Invoke-Command -Session $PsSession -AsJob -JobName "Deploy Parallels RAS Farm" -ScriptBlock {
                    Param( $LocalAdminUserName , $LocalAdminPassword , $RasLicenseEmail , $RasLicensePassword , $RasKey )
                    If (-Not (Test-Path -Path 'C:\Program Files (x86)\Parallels\ApplicationServer\Modules\RASAdmin\RASAdmin.psd1')) { Start-Sleep -Seconds 5 }
                    Import-Module 'C:\Program Files (x86)\Parallels\ApplicationServer\Modules\RASAdmin\RASAdmin.psd1'
                    Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Parallels\Setup\ApplicationServer -Name ProductDir -Value "C:\Program Files (x86)\Parallels\ApplicationServer\"
                    New-RASSession -Username $LocalAdminUserName -Password $(ConvertTo-SecureString $LocalAdminPassword -AsPlainText -Force) -Server 'localhost'
                    Invoke-RASLicenseActivate -Email $RasLicenseEmail -Password $(ConvertTo-SecureString $RasLicensePassword -AsPlainText -Force) -Key $RasKey
                    # New-RASGW -Server "$env:COMPUTERNAME"
                    New-RASRDS -Server "$env:COMPUTERNAME" -NoRestart -NoTerminalServices 
                    New-RASPubRDSDesktop -Name "Desktop"
                    Invoke-RASApply
                    } -ArgumentList ( $LocalAdminUserName , $LocalAdminPassword , $RasLicenseEmail , $RasLicensePassword , $RasKey ) 
                While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarRDS.Value = $I } ) }
                }
            Get-Job | Select-Object -Property Name, State, Command, @{Name='Error';Expression={ $_.ChildJobs[0].JobStateInfo.Reason }} | Export-Csv -Path "$env:windir\Logs\PushTheButtonJobs.csv" -NoTypeInformation -Force
            If ((Get-Job).Where({$_.State -eq 'Failed'}).count -ne 0 ) {
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarRDS.Visibility = "Hidden" } )
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.LabelStatusRDS.Content = "Deployment Finished with ERRORS $(' .'*115)$(' '*30)Please consult PushTheButtonJobs.csv" } )
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployRdsStart.IsEnabled = $True } )
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployRdsStart.Visibility = "Visible" } )
                }
                Else {
				    New-ItemProperty -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'FSLogixFolderRootPath' -PropertyType 'String' -Value $FSLogixFolderRootPath -Force
				    New-ItemProperty -Path 'HKLM:\Software\ClearMedia\PushTheButton' -Name 'DataFolderRootPath' -PropertyType 'String' -Value $DataFolderRootPath -Force
                    $GpoName = 'StandardServerFSLogixPolicy'
                    If ( ( Get-GPRegistryValue -Server $env:COMPUTERNAME -Name $GpoName -Key 'HKLM\Software\FSLogix\Profiles' -ValueName 'VHDLocations' -ErrorAction SilentlyContinue ) ) {
                        Set-GPRegistryValue -Server $env:COMPUTERNAME -Name $GpoName -Key 'HKLM\Software\FSLogix\Profiles' -ValueName 'VHDLocations' -Type 'String' -Value $FSLogixFolderRootPath -ErrorAction Continue
                        }
                    $GpoName = 'StandardUserFolderRedirectionPolicy'
                    If ( ( Get-GPRegistryValue -Server $env:COMPUTERNAME -Name $GpoName -Key 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -ValueName 'Personal' -ErrorAction SilentlyContinue ) ) {
                        Set-GPRegistryValue -Server $env:COMPUTERNAME -Name $GpoName -Key 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -ValueName 'Personal' -Type 'ExpandString' -Value "$DataFolderRootPath\%USERNAME%\Documents" -ErrorAction Continue
                        }
                    If ( ( Get-GPRegistryValue -Server $env:COMPUTERNAME -Name $GpoName -Key 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -ValueName 'My Music' -ErrorAction SilentlyContinue ) ) {
                        Set-GPRegistryValue -Server $env:COMPUTERNAME -Name $GpoName -Key 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -ValueName 'My Music' -Type 'ExpandString' -Value "$DataFolderRootPath\%USERNAME%\Music" -ErrorAction Continue
                        }
                    If ( ( Get-GPRegistryValue -Server $env:COMPUTERNAME -Name $GpoName -Key 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -ValueName 'My Pictures' -ErrorAction SilentlyContinue ) ) {
                        Set-GPRegistryValue -Server $env:COMPUTERNAME -Name $GpoName -Key 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -ValueName 'My Pictures' -Type 'ExpandString' -Value "$DataFolderRootPath\%USERNAME%\Pictures" -ErrorAction Continue
                        }
                    If ( ( Get-GPRegistryValue -Server $env:COMPUTERNAME -Name $GpoName -Key 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -ValueName 'My Video' -ErrorAction SilentlyContinue ) ) {
                        Set-GPRegistryValue -Server $env:COMPUTERNAME -Name $GpoName -Key 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -ValueName 'My Video' -Type 'ExpandString' -Value "$DataFolderRootPath\%USERNAME%\Videos" -ErrorAction Continue
                        }
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBoxUSERDataFolderRootPath.Text = $DataFolderRootPath } )
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarRDS.Visibility = "Hidden" } )
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.LabelStatusRDS.Content = "Deployment Finished $(' .'*135)$(' '*30) Please  REBOOT" } )
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployRdsStart.Visibility = "Hidden" } )
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployRdsReboot.Visibility = "Visible"  } )
					}
            }
	$PSinstance = [powershell]::Create().AddScript($Code)
	$PSinstance.Runspace = $Runspace
	$job = $PSinstance.BeginInvoke()
    }
Function DeployRdsReboot {
	Param($SyncHash,$ServerIpAddress,$LocalAdminUserName,$LocalAdminPassword)
	$Runspace = [runspacefactory]::CreateRunspace()
	$Runspace.ApartmentState = "STA"
	$Runspace.ThreadOptions = "ReuseThread"
	$Runspace.Open()
	$Runspace.SessionStateProxy.SetVariable("SyncHash",$SyncHash)
	$Runspace.SessionStateProxy.SetVariable("ServerIpAddress",$ServerIpAddress)
	$Runspace.SessionStateProxy.SetVariable("LocalAdminUserName",$LocalAdminUserName)
	$Runspace.SessionStateProxy.SetVariable("LocalAdminPassword",$LocalAdminPassword)
	$code = {
			$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxRDS.AddText(" Rebooting $ServerIpAddress `n") } )
			$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ( "$ServerIpAddress\$LocalAdminUserName" , $( ConvertTo-SecureString -String $LocalAdminPassword -AsPlainText -Force ) )
			Set-Item WSMan:\localhost\Client\TrustedHosts -Value "$ServerIpAddress" -Force
			$Job = Invoke-Command -ComputerName $ServerIpAddress -Credential $Credential -AsJob -JobName "RebootRDS" -ScriptBlock { Restart-Computer -Force }
			Get-Job | Select-Object -Property Name, State, Command, @{Name='Error';Expression={ $_.ChildJobs[0].JobStateInfo.Reason }} | Export-Csv -Path "$env:windir\Logs\PushTheButtonJobs.csv" -NoTypeInformation -Force
			While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarRDS.Value = $I } ) }
			If ((Get-Job).Where({$_.State -eq 'Failed'}).count -ne 0 ) {
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarRDS.Visibility = "Hidden" } )
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.DeployRdsReboot.Visibility = "Hidden"  } )
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.LabelStatusRDS.Content = "REBOOT Finished with ERRORS $(' .'*115)$(' '*30)Please consult PushTheButtonJobs.csv" } )
                }
                Else {
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarRDS.Visibility = "Hidden" } )
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.DeployRdsReboot.Visibility = "Hidden"  } )    
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.LabelStatusRDS.Content = "Reboot Initiated $(' .'*140)" } )
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployRdsStart.IsEnabled = $True } )
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployRdsStart.Visibility = "Visible" } )
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployO365Start.IsEnabled = $True } )
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployWUStart.IsEnabled = $True } )
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployUserStart.IsEnabled = $True } )                    
					} 
			}
	$PSinstance = [powershell]::Create().AddScript($Code)
	$PSinstance.Runspace = $Runspace
	$job = $PSinstance.BeginInvoke()        
	}
Function DeployO365Start {
	Param($SyncHash,$ServerIpAddressList,$AdminUserName,$AdminPassword,$RadioButtonO365ProPlusRetail32Bit,$RadioButtonO365ProPlusRetail64Bit,$CheckBoxExcludeApp)
	$Runspace = [runspacefactory]::CreateRunspace()
	$Runspace.ApartmentState = "STA"
	$Runspace.ThreadOptions = "ReuseThread"
	$Runspace.Open()
	$Runspace.SessionStateProxy.SetVariable("SyncHash",$SyncHash)
	$Runspace.SessionStateProxy.SetVariable("ServerIpAddressList",$ServerIpAddressList)
	$Runspace.SessionStateProxy.SetVariable("AdminUserName",$AdminUserName)
	$Runspace.SessionStateProxy.SetVariable("AdminPassword",$AdminPassword)
	$Runspace.SessionStateProxy.SetVariable("RadioButtonO365ProPlusRetail32Bit",$RadioButtonO365ProPlusRetail32Bit)
	$Runspace.SessionStateProxy.SetVariable("RadioButtonO365ProPlusRetail64Bit",$RadioButtonO365ProPlusRetail64Bit)
	$Runspace.SessionStateProxy.SetVariable("CheckBoxExcludeApp",$CheckBoxExcludeApp)
	$code = {
            [INT]$I = 0
            ForEach ( $ServerIpAddress in $ServerIpAddressList.Split(',') ) {
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarO365.Value = $I } )
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxO365.AddText(" Connecting to $ServerIpAddress `n") } )
                $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ( "$ServerIpAddress\$AdminUserName" , $( ConvertTo-SecureString -String $AdminPassword -AsPlainText -Force ) )
                Set-Item WSMan:\localhost\Client\TrustedHosts -Value "$ServerIpAddress" -Force
                Try { $PsSession = New-PSSession -ComputerName $ServerIpAddress -Credential $Credential -ErrorAction Stop }
                    Catch {
                    $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarO365.Visibility = "Hidden" } )
                    $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.LabelStatusO365.Content = "Connection Failure $(' .'*130)$(' '*30)Please check Server - Username - Password" } )
                    $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployO365Start.IsEnabled = $True } )
                    $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployO365Start.Visibility = "Visible"  } )
                    Return
                    }
            $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxO365.AddText(" Testing Internet Connection `n") } )
            $Job = Invoke-Command -Session $PsSession -AsJob -JobName 'TestConnectionGoogle' -ScriptBlock { Test-Connection -ComputerName 'www.google.com' -Count 1 }
			While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarRDS.Value = $I } ) }
            If ( $Job.ChildJobs[0].Error ) {
                    $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarO365.Visibility = "Hidden" } )
                    $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.LabelStatusO365.Content = "Connection Failure $(' .'*130)$(' '*30)Please check Internet Connection" } )
                    $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployO365Start.IsEnabled = $True } )
                    $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployO365Start.Visibility = "Visible"  } )
                    Return
                    }
			If ( $RadioButtonO365ProPlusRetail32Bit ) { $ProductId = 'O365ProPlusRetail' ; $O365version = '32' }
			If ( $RadioButtonO365ProPlusRetail64Bit ) { $ProductId = 'O365ProPlusRetail' ; $O365version = '64'  }
			If ( $CheckBoxExcludeApp ) { $ExcludeApp = 'Teams' } Else  { $ExcludeApp = '' }
			$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxO365.AddText(" Downloading and Extracting Office Deployment Tool `n") } )
			$Job = Invoke-Command -Session $PsSession -AsJob -JobName 'Download and Extract Office Deployment Tool' -ScriptBlock {
				Param($O365version,$ProductId,$ExcludeApp)
				# $Url = 'https://www.microsoft.com/en-us/download/confirmation.aspx?id=49117'
				# DownloadInstall OfficeDeploymentTool Version 16.0.13426.20308
				$UrlDownload = 'https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_13426-20308.exe'
				$FileDownload = "$Env:LOCALAPPDATA\officedeploymenttool_13426-20308.exe"
				(New-Object System.Net.WebClient).DownloadFile($UrlDownload, $FileDownload)
				Do { Start-Sleep -Seconds 2 } Until ( Test-Path -Path $FileDownload ) 
				Invoke-Expression -Command "CMD.EXE /C '$FileDownload /quiet /extract:$FileDownload\..'"
				[STRING]$Config = @"
					<Configuration>
						<Add SourcePath="c:\install\O365" OfficeClientEdition="$O365version" Channel="SemiAnnual">
							<Product ID="$ProductId">
								<Language ID="en-us"/>
								<Language ID="nl-nl"/>
								<Language ID="fr-fr"/>
								<ExcludeApp ID="$ExcludeApp"/>
							</Product>
						</Add>
						<Updates Channel="SemiAnnual" Enabled="TRUE"/>
						<Display Level="Full" AcceptEULA="TRUE"/>
						<Logging Level="Standard" Path="c:\windows\logs\O365"/>
						<Property Name="FORCEAPPSHUTDOWN" Value="TRUE"/>
						<Property Name="SharedComputerLicensing" Value="1"/>
						<Property Name="PinIconsToTaskbar" Value="FALSE"/>
					</Configuration>
"@
				$Config | Out-File -FilePath "$Env:LOCALAPPDATA\configuration.xml"               
				} -ArgumentList ($O365version,$ProductId,$ExcludeApp) 
				While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarO365.Value = $I } ) }
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxO365.AddText(" Downloading $ProductId $O365version bit `n") } )
				$Job = Invoke-Command -Session $PsSession -AsJob -JobName "Download $ProductId $O365version bit" -ScriptBlock { Invoke-Expression -Command "$Env:LOCALAPPDATA\setup.exe /download  $Env:LOCALAPPDATA\configuration.xml" }
				While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarO365.Value = $I } ) }
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxO365.AddText(" Installing $ProductId $O365version bit `n") } )
				$Job = Invoke-Command -Session $PsSession -AsJob -JobName "Install $ProductId $O365version bit" -ScriptBlock { Invoke-Expression -Command "$Env:LOCALAPPDATA\setup.exe /configure  $Env:LOCALAPPDATA\configuration.xml" }
				While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarO365.Value = $I } ) }
				}   
            Get-Job | Select-Object -Property Name, State, Command, @{Name='Error';Expression={ $_.ChildJobs[0].JobStateInfo.Reason }} | Export-Csv -Path "$env:windir\Logs\PushTheButtonJobs.csv" -NoTypeInformation -Force
            If ((Get-Job).Where({$_.State -eq 'Failed'}).count -ne 0 ) {
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarO365.Visibility = "Hidden" } )
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.LabelStatusO365.Content = "Deployment Finished with ERRORS $(' .'*115)$(' '*30)Please consult PushTheButtonJobs.csv" } )
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployO365Start.IsEnabled = $True } )
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployO365Start.Visibility = "Visible" } )
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployUserStart.IsEnabled = $True } )
                }
                Else {
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarO365.Visibility = "Hidden" } )
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.LabelStatusO365.Content = "Deployment Finished$(' .'*135)$(' '*30)" } )
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployO365Start.IsEnabled = $True } )
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployWUStart.IsEnabled = $True } )
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployUserStart.IsEnabled = $True } )                    
					}
            }
	$PSinstance = [powershell]::Create().AddScript($Code)
	$PSinstance.Runspace = $Runspace
	$job = $PSinstance.BeginInvoke()
	}
Function DeployWuStart {
	Param($SyncHash,$ServerIpAddressList,$AdminUserName,$AdminPassword,$DayOfWeek,$TimeHour,$TimeMinutes)
	$Runspace = [runspacefactory]::CreateRunspace()
	$Runspace.ApartmentState = "STA"
	$Runspace.ThreadOptions = "ReuseThread"
	$Runspace.Open()
	$Runspace.SessionStateProxy.SetVariable("SyncHash",$SyncHash)
	$Runspace.SessionStateProxy.SetVariable("ServerIpAddressList",$ServerIpAddressList)
	$Runspace.SessionStateProxy.SetVariable("AdminUserName",$AdminUserName)
	$Runspace.SessionStateProxy.SetVariable("AdminPassword",$AdminPassword)
	$Runspace.SessionStateProxy.SetVariable("DayOfWeek",$DayOfWeek)
	$Runspace.SessionStateProxy.SetVariable("TimeHour",$TimeHour)
	$Runspace.SessionStateProxy.SetVariable("TimeMinutes",$TimeMinutes)
	$code = {
            [INT]$I = 0
            ForEach ( $ServerIpAddress in  $ServerIpAddressList.Split(',') ) {
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarWU.Value = $I } )
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxWU.AddText(" Connecting to $ServerIpAddress `n") } )
                $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ( "$ServerIpAddress\$AdminUserName" , $( ConvertTo-SecureString -String $AdminPassword -AsPlainText -Force ) )
                Set-Item WSMan:\localhost\Client\TrustedHosts -Value "$ServerIpAddress" -Force
                Try { $PsSession = New-PSSession -ComputerName $ServerIpAddress -Credential $Credential -ErrorAction Stop }
                    Catch {
                    $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarWU.Visibility = "Hidden" } )
                    $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.LabelStatusWU.Content = "Connection Failure $(' .'*130)$(' '*30)Please check Server - Username - Password" } )
                    $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployWUStart.IsEnabled = $True } )
                    $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployWUStart.Visibility = "Visible"  } )
                    Return
                    }
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxWU.AddText(" Assembling c:\windows\WindowsUpdate.ps1 `n") } )
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
Try { $WindowsUpdateList = $WindowsUpdateSearch.Search($Null).Updates }
 Catch { Write-Output 'WSUS not Reachable. No Internet Connection. Please Check DNS & Gateway Config.' }
If ( $WindowsUpdateList.Count -gt 0 )
  {
        $WindowsUpdateDownload.Updates = $WindowsUpdateList
  $WindowsUpdateDownload.Download()
  $WindowsUpdateInstall.Updates = $WindowsUpdateList
  $WindowsUpdateInstall.Install()
        }
# Report Windows Updates to CSV File 'c:\windows\logs\WindowsUpdate.csv'
[PSCustomObject[]]$Table = $Null
Foreach ( $Update in $WindowsUpdateList ) 
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
                While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 5 ; If ( $I -ge 100 ) { $I = 1 }; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarWU.Value = $I } ) }
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxWU.AddText(" Creating Scheduled Job CMscripts\WindowsUpdate `n") } )
                $Job = Invoke-Command -Session $PsSession -AsJob -JobName 'Creating Scheduled Job CMscripts\WindowsUpdate' -ScriptBlock {
                    Param([INT]$DayOfWeek,[INT]$TimeHour,[INT]$TimeMinutes)
                    [STRING]$DAY = ('MON','TUE','WED','THU','FRI','SAT','SUN')[$DayOfWeek]
                    [STRING]$HOUR = ('00','01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23')[$TimeHour]
                    [STRING]$MINUTES = ('00','10','20','30','40','50')[$TimeMinutes]
                    $TIME = "$($HOUR):$($MINUTES)"
                    schtasks.exe /CREATE /RU SYSTEM /SC Weekly /MO 1 /D $DAY /ST $TIME /TN CMscripts\WindowsUpdate /TR "Powershell.exe -File '$Env:Windir\WindowsUpdate.ps1'"
                    } -ArgumentList ($DayOfWeek,$TimeHour,$TimeMinutes)
                While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 5 ; If ( $I -ge 100 ) { $I = 1 }; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarWU.Value = $I } ) }
                }
            Get-Job | Select-Object -Property Name, State, Command, @{Name='Error';Expression={ $_.ChildJobs[0].JobStateInfo.Reason }} | Export-Csv -Path "$env:windir\Logs\PushTheButtonJobs.csv" -NoTypeInformation -Force
            If ((Get-Job).Where({$_.State -eq 'Failed'}).count -ne 0 ) {
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarWU.Visibility = "Hidden" } )
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.LabelStatusWU.Content = "Deployment Finished with ERRORS $(' .'*115)$(' '*30)Please consult PushTheButtonJobs.csv" } )
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.DeployWUtart.IsEnabled = $True } )
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployWUStart.Visibility = "Visible" } )
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployUserStart.IsEnabled = $True } )
                }
                Else {
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarWU.Visibility = "Hidden" } )
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.LabelStatusWU.Content = "Deployment Finished $(' .'*135)$(' '*30)" } )
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployO365Start.IsEnabled = $True } )
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployWUStart.IsEnabled = $True } )
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployUserStart.IsEnabled = $True } )                    
					}
			}
	$PSinstance = [powershell]::Create().AddScript($Code)
	$PSinstance.Runspace = $Runspace
	$job = $PSinstance.BeginInvoke()
    }
Function DeployUserStart {
	Param($SyncHash,$ServerIpAddress,$ServerName,$LocalAdminUserName,$LocalAdminPassword,$DomainAdminUserName,$DomainAdminPassword,$DomainDcServerName,$UserType,$DataFolderRootPath,$PrincipalName,$UserGivenName,$UserSurname,$UserEmailAddress,$UserPassword,$OuPath,$DomainDnsName,$DomainNetbiosName)
	$Runspace = [runspacefactory]::CreateRunspace()
	$Runspace.ApartmentState = "STA"
	$Runspace.ThreadOptions = "ReuseThread"
	$Runspace.Open()
	$Runspace.SessionStateProxy.SetVariable("SyncHash",$SyncHash)
	$Runspace.SessionStateProxy.SetVariable("ServerIpAddress",$ServerIpAddress)
	$Runspace.SessionStateProxy.SetVariable("ServerName",$ServerName)
	$Runspace.SessionStateProxy.SetVariable("LocalAdminUserName",$LocalAdminUserName)
	$Runspace.SessionStateProxy.SetVariable("LocalAdminPassword",$LocalAdminPassword)
	$Runspace.SessionStateProxy.SetVariable("DomainAdminUserName",$DomainAdminUserName)
	$Runspace.SessionStateProxy.SetVariable("DomainAdminPassword",$DomainAdminPassword)
	$Runspace.SessionStateProxy.SetVariable("DomainDcServerName",$DomainDcServerName)
	$Runspace.SessionStateProxy.SetVariable("UserType",$UserType)
	$Runspace.SessionStateProxy.SetVariable("DataFolderRootPath",$DataFolderRootPath)
	$Runspace.SessionStateProxy.SetVariable("PrincipalName",$PrincipalName)
	$Runspace.SessionStateProxy.SetVariable("UserGivenName",$UserGivenName)
	$Runspace.SessionStateProxy.SetVariable("UserSurname",$UserSurname)
	$Runspace.SessionStateProxy.SetVariable("UserEmailAddress",$UserEmailAddress)
	$Runspace.SessionStateProxy.SetVariable("UserPassword",$UserPassword)
	$Runspace.SessionStateProxy.SetVariable("OuPath",$OuPath)
	$Runspace.SessionStateProxy.SetVariable("DomainDnsName",$DomainDnsName)
	$Runspace.SessionStateProxy.SetVariable("DomainNetbiosName",$DomainNetbiosName)
	$code = {
            [INT]$I = 0
            $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarUser.Value = $I } )
            $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxUser.AddText(" Connecting to $ServerIpAddress `n") } )
	    $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ( "$ServerIpAddress\$LocalAdminUserName" , $(ConvertTo-SecureString -String $LocalAdminPassword -AsPlainText -Force ) )
            Set-Item WSMan:\localhost\Client\TrustedHosts -Value "$ServerIpAddress" -Force
            Try { $PsSession = New-PSSession -ComputerName $ServerIpAddress -Credential $Credential -ErrorAction Stop }
                    Catch {
                    $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarUser.Visibility = "Hidden" } )
                    $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.LabelStatusUser.Content = "Connection Failure $(' .'*130)$(' '*30)Please check Server - Username - Password" } )
                    $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployUserStart.IsEnabled = $True } )
                    $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployUserStart.Visibility = "Visible"  } )
                    Return
                    }
	    [STRING]$RandomPasswordPlainText = ((([char[]](65..90) | sort {get-random})[0..2] + ([char[]](33,35,36,37,42,43,45) | sort {get-random})[0] + ([char[]](97..122) | sort {get-random})[0..4] + ([char[]](48..57) | sort {get-random})[0]) | get-random -Count 10) -join ''
	    If ( $UserPassword -eq '' ) { $UserPassword = $RandomPasswordPlainText ; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBoxUSERUserPassword.Text = $UserPassword } ) }
	    [STRING]$OuPath = "OU=$(('Full Users','Light Users')[$UserType]),$OuPath"
            $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxUser.AddText(" Creating User $PrincipalName in $OuPath `n") } )
            $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxUser.AddText(" With Password $UserPassword `n") } )
            $Job = Start-Job -Name 'Active Directory Add User' -ScriptBlock {
				Param ($DomainAdminUserName,$DomainAdminPassword,$DomainDcServerName,$DataFolderRootPath,$PrincipalName,$UserGivenName,$UserSurname,$UserEmailAddress,$UserPassword,$OuPath,$DomainDnsName)
				$DomainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ("$($DomainAdminUserName)@$($DomainDnsName)", $(ConvertTo-SecureString -String $DomainAdminPassword -AsPlainText -Force))
				$NewUserParams = @{
					'Server' = $DomainDcServerName
					'Credential' = $DomainCredential
					'UserPrincipalName' = "$($PrincipalName)@$($DomainDnsName)"
					'DisplayName' = $PrincipalName
					'Name' = $PrincipalName
					'SamAccountName' = $PrincipalName
					'GivenName' = $UserGivenName
					'Surname' = $UserSurname
					'Enabled' = $TRUE
					'ChangePasswordAtLogon' = $FALSE
					'AccountPassword' =  ConvertTo-SecureString $UserPassword -AsPlainText -Force
					'Path' = $OuPath
					'HomeDirectory' = "$DataFolderRootPath\$PrincipalName"
                    			'EmailAddress' = $UserEmailAddress
					'Country' = 'Be'
					}
				New-ADUser @NewUserParams -ErrorAction Stop
				} -ArgumentList ($DomainAdminUserName,$DomainAdminPassword,$DomainDcServerName,$DataFolderRootPath,$PrincipalName,$UserGivenName,$UserSurname,$UserEmailAddress,$UserPassword,$OuPath,$DomainDnsName)
            While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarUser.Value = $I } ) }
            $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxUser.AddText(" Adding $PrincipalName to 'RDP-Users' Group `n") } )
            $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxUser.AddText(" Adding $PrincipalName to 'FSLogix-Users' Group `n") } )
            $Job = Start-Job -Name 'Active Directory Add User To Group' -ScriptBlock {
                    Param ($PrincipalName,$DomainDcServerName)
                    Add-ADGroupMember -Server "$DomainDcServerName" -Identity 'RDP-Users' -Members $PrincipalName -ErrorAction Stop
                    Add-ADGroupMember -Server "$DomainDcServerName" -Identity 'FSLogix-Users' -Members $PrincipalName -ErrorAction Stop
                    } -ArgumentList ($PrincipalName,$DomainDcServerName)
            While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarUser.Value = $I } ) }
            If ( $DataFolderRootPath -like '?:\*' ) {
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxUser.AddText(" Creating User DATA Folder `n") } )
                $Job = Invoke-Command -Session $PsSession -AsJob -JobName 'DataFolder' -ScriptBlock {
				    Param ($DataFolderRootPath,$PrincipalName,$DomainNetbiosName)
				    [STRING]$FolderPath = "$DataFolderRootPath\$PrincipalName"
				    New-Item -Path $FolderPath -type directory -Force
				    $ACL = Get-Acl  -Path  $FolderPath
				    $ACL.SetAccessRuleProtection($true,$true)
				    $AccessRule = New-Object system.security.AccessControl.FileSystemAccessRule("$DomainNetbiosName\$PrincipalName", 'Modify', 'ObjectInherit,ContainerInherit', 'None', 'Allow')
				    $ACL.AddAccessRule($AccessRule)
				    Set-Acl  -Path $FolderPath -AclObject $ACL
				    New-Item -Path "$FolderPath\Documents" -type directory -Force
				    } -ArgumentList ($DataFolderRootPath,$PrincipalName,$DomainNetbiosName)
                While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarUser.Value = $I } ) }
                }
            If ( $DataFolderRootPath -like '\\*' ) {
                $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBlockOutBoxUser.AddText(" Creating User DATA Share Folder `n") } )
                $Job = Invoke-Command -ComputerName 'localhost' -AsJob -JobName 'DataFolder' -ScriptBlock {
				    Param ($DataFolderRootPath,$PrincipalName,$DomainNetbiosName)
				    [STRING]$FolderPath = "$DataFolderRootPath\$PrincipalName"
				    New-Item -Path $FolderPath -type directory -Force
				    $ACL = Get-Acl  -Path  $FolderPath
				    $ACL.SetAccessRuleProtection($true,$true)
				    $AccessRule = New-Object system.security.AccessControl.FileSystemAccessRule("$DomainNetbiosName\$PrincipalName", 'Modify', 'ObjectInherit,ContainerInherit', 'None', 'Allow')
				    $ACL.AddAccessRule($AccessRule)
				    Set-Acl  -Path $FolderPath -AclObject $ACL
				    New-Item -Path "$FolderPath\Documents" -type directory -Force
				    } -ArgumentList ($DataFolderRootPath,$PrincipalName,$DomainNetbiosName)
                While ( $job.State -eq 'Running' ) { Start-Sleep -Milliseconds 1500 ; $I += 2 ; If ( $I -ge 100 ) { $I = 1 }; $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarUser.Value = $I } ) }
                }
            Get-Job | Select-Object -Property Name, State, Command, @{Name='Error';Expression={ $_.ChildJobs[0].JobStateInfo.Reason }} | Export-Csv -Path "$env:windir\Logs\PushTheButtonJobs.csv" -NoTypeInformation -Force
            If ((Get-Job).Where({$_.State -eq 'Failed'}).count -ne 0 ) {
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarUser.Visibility = "Hidden" } )
				$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.LabelStatusUser.Content = "User Added with ERRORS $(' .'*115)$(' '*30)Please consult PushTheButtonJobs.csv" } )
				}
                Else {
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.ProgressBarUser.Visibility = "Hidden" } )
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.LabelStatusUser.Content = "User Added $(' .'*135)$(' '*30)" } )
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.TextBoxUSERUserPassword.Text = "" } )
                    $SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployRdsStart.IsEnabled = $True } )
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployO365Start.IsEnabled = $True } )
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployWUStart.IsEnabled = $True } )
					$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployUserStart.IsEnabled = $True } )                                            
					}
			$SyncHash.Window.Dispatcher.invoke( [action]{ $SyncHash.BorderDeployUserStart.Visibility = "Visible"  } ) 
            }
	$PSinstance = [powershell]::Create().AddScript($Code)
	$PSinstance.Runspace = $Runspace
	$job = $PSinstance.BeginInvoke()   
    }

# Init ( WPF - Windows Presentation Framework ) Actions
$SyncHash.ButtonFireboxStart.Add_Click({
    $SyncHash.BorderDeployFireboxStart.IsEnabled = $False
    $SyncHash.LabelStatusFirebox.Content = "In Progress ...."
    $SyncHash.LabelStatusFirebox.Visibility = "Visible"
    $SyncHash.ProgressBarFirebox.Visibility = "Visible"
    $DeployFireboxStart= @{
        'SyncHash' = $SyncHash
	'FireboxIpAddress' = $SyncHash.TextBoxFireboxIpAddress.Text
        'FireboxAdminUserName' = $SyncHash.TextBoxFireboxAdminUserName.Text
        'FireboxAdminPassword' = $SyncHash.TextBoxFireboxAdminPassword.Text
        'FireboxExternalIp' = $SyncHash.TextBoxFireboxExternalIp.Text
        'FireboxExternalIpGatewayCIDR' = $SyncHash.TextBoxFireboxExternalIpGatewayCIDR.Text
        'FireboxExternalIpCIDR' = "$( $SyncHash.TextBoxFireboxExternalIp.Text )/$( $SyncHash.TextBoxFireboxExternalIpGatewayCIDR.Text.Split( '/' )[1] )"
        'FireboxExternalIpGateway' = "$( $SyncHash.TextBoxFireboxExternalIpGatewayCIDR.Text.Split( '/' )[0] )"
        }
	DeployFireboxStart @DeployFireboxStart
	})
$SyncHash.ButtonDeployDcStart.Add_Click({
    $SyncHash.BorderDeployDcStart.IsEnabled = $False
    $SyncHash.BorderDeployOUStart.IsEnabled = $False
    $SyncHash.BorderDeployStandardGpoStart.IsEnabled = $False
    $SyncHash.BorderDeployFolderRedirectionStart.IsEnabled = $False
    $SyncHash.BorderDeployRdsStart.IsEnabled = $False  
    $SyncHash.BorderDeployO365Start.IsEnabled = $False
    $SyncHash.BorderDeployWUStart.IsEnabled = $False
    $SyncHash.BorderDeployUserStart.IsEnabled = $False
    $SyncHash.LabelStatusDc.Visibility = "Visible"
    $SyncHash.ProgressBarDc.Visibility = "Visible"
    $DeployDcStart= @{
        'SyncHash' = $SyncHash
	'SafeModeAdministratorPassword' = $SyncHash.TextBoxSafeModeAdministratorPassword.Text
        'DnsServerForwarders' = $SyncHash.TextBoxDnsServerForwarders.Text
        'DomainNetbiosName' = $SyncHash.TextBoxDomainNetbiosName.Text
        'DomainDnsName' = $SyncHash.TextBoxDomainDnsName.Text
        'FireboxExternalIpGatewayCIDR' = $SyncHash.TextBoxFireboxExternalIpGatewayCIDR.Text
        'FireboxExternalIpCIDR' = "$( $SyncHash.TextBoxFireboxExternalIp.Text )/$( $SyncHash.TextBoxFireboxExternalIpGatewayCIDR.Text.Split( '/' )[1] )"
        'FireboxExternalIpGateway' = "$( $SyncHash.TextBoxFireboxExternalIpGatewayCIDR.Text.Split( '/' )[0] )"
        }
	DeployDcStart @DeployDcStart
    # $SyncHash.host.ui.WriteVerboseLine($SyncHash.TextBoxDomainNetbiosName.Text)
    })
$SyncHash.ButtonDeployDcReboot.Add_Click({ Restart-Computer })
$SyncHash.ButtonDeployOUStart.Add_Click({
    $SyncHash.BorderDeployOUStart.IsEnabled = $False
    $SyncHash.BorderDeployStandardGpoStart.IsEnabled = $False
    $SyncHash.BorderDeployFolderRedirectionStart.IsEnabled = $False
    $SyncHash.BorderDeployRdsStart.IsEnabled = $False  
    $SyncHash.BorderDeployO365Start.IsEnabled = $False
    $SyncHash.BorderDeployWUStart.IsEnabled = $False
    $SyncHash.BorderDeployUserStart.IsEnabled = $False
    $SyncHash.LabelStatusOU.Visibility = "Visible"
    $SyncHash.ProgressBarOU.Visibility = "Visible"
    $DeployOUStart= @{
        'SyncHash' = $SyncHash
	'ManagedOuName' = $SyncHash.TextBoxManagedOuName.Text
        'ClearmediaAdminUserName' = $SyncHash.TextBoxClearmediaAdminUserName.Text
        'ClearmediaAdminPassword' = $SyncHash.TextBoxClearmediaAdminPassword.Text
        }
	DeployOUStart @DeployOUStart
    # $SyncHash.host.ui.WriteVerboseLine($SyncHash.TextBoxDomainNetbiosName.Text)
    })
$SyncHash.ButtonDeployStandardGpoStart.Add_Click({
    $SyncHash.BorderDeployStandardGpoStart.IsEnabled = $False
    $SyncHash.BorderDeployFolderRedirectionStart.IsEnabled = $False
    $SyncHash.BorderDeployRdsStart.IsEnabled = $False  
    $SyncHash.BorderDeployO365Start.IsEnabled = $False
    $SyncHash.BorderDeployWUStart.IsEnabled = $False
    $SyncHash.BorderDeployUserStart.IsEnabled = $False
    $SyncHash.LabelStatusGPO.Visibility = "Visible"
    $SyncHash.ProgressBarGPO.Visibility = "Visible"
    $DeployStandardGpoStart= @{
        'SyncHash' = $SyncHash
	'TemplateSourcePath' = $SyncHash.TextBoxTemplateSourcePath.Text
        'RdsOuPath' = $SyncHash.TextBoxRdsOuPath.Text
        'UsersOuPath' = $SyncHash.TextBoxUsersOuPath.Text
        'CheckBoxCopyAdmFiles' = $SyncHash.CheckBoxCopyAdmFiles.IsChecked
        'CheckBoxStandardServerRDSPolicy' = $SyncHash.CheckBoxStandardServerRDSPolicy.IsChecked
        'CheckBoxStandardServerWindowsUpdatePolicy' = $SyncHash.CheckBoxStandardServerWindowsUpdatePolicy.IsChecked
        'CheckBoxStandardServerFSLogixPolicy' = $SyncHash.CheckBoxStandardServerFSLogixPolicy.IsChecked
        'CheckBoxStandardUserPolicy' = $SyncHash.CheckBoxStandardUserPolicy.IsChecked
        'CheckBoxStandardUserHardwareAccelerationPolicy' = $SyncHash.CheckBoxStandardUserHardwareAccelerationPolicy.IsChecked
        'CheckBoxStandardUserO365Policy' = $SyncHash.CheckBoxStandardUserO365Policy.IsChecked
        'CheckBoxStandardUserOutlookPolicy' = $SyncHash.CheckBoxCopyAdmFiles.IsChecked
        }
	DeployStandardGpoStart @DeployStandardGpoStart
    #$SyncHash.host.ui.WriteVerboseLine($SyncHash.CheckBoxStandardRdsServerPolicy.IsChecked)
    })
$SyncHash.ButtonDeployFolderRedirectionStart.Add_Click({
    $SyncHash.BorderDeployStandardGpoStart.IsEnabled = $False
    $SyncHash.BorderDeployFolderRedirectionStart.IsEnabled = $False
    $SyncHash.BorderDeployRdsStart.IsEnabled = $False  
    $SyncHash.BorderDeployO365Start.IsEnabled = $False
    $SyncHash.BorderDeployWUStart.IsEnabled = $False
    $SyncHash.BorderDeployUserStart.IsEnabled = $False
    $SyncHash.LabelStatusFolderRedirection.Visibility = "Visible"
    $SyncHash.ProgressBarFolderRedirection.Visibility = "Visible"
    $DeployFolderRedirectionStart= @{
        'SyncHash' = $SyncHash
        'CheckBoxDocuments' = $SyncHash.CheckBoxDocuments.IsChecked
	'DocumentsPath' = $SyncHash.TextBoxDocumentsPath.Text
        'CheckBoxMusic' = $SyncHash.CheckBoxMusic.IsChecked
	'MusicPath' = $SyncHash.TextBoxMusicPath.Text
        'CheckBoxPictures' = $SyncHash.CheckBoxPictures.IsChecked
	'PicturesPath' = $SyncHash.TextBoxPicturesPath.Text
        'CheckBoxVideos' = $SyncHash.CheckBoxVideos.IsChecked
	'VideosPath' = $SyncHash.TextBoxVideosPath.Text
	'UsersOuPath' = $SyncHash.TextBoxUsersOuPath.Text
        }
	DeployFolderRedirectionStart @DeployFolderRedirectionStart
    #$SyncHash.host.ui.WriteVerboseLine($SyncHash.CheckBoxStandardRdsServerPolicy.IsChecked)
    })
$SyncHash.ButtonDeployRdsStart.Add_Click({
    $SyncHash.BorderDeployRdsStart.IsEnabled = $False  
    $SyncHash.BorderDeployO365Start.IsEnabled = $False
    $SyncHash.BorderDeployWUStart.IsEnabled = $False
    $SyncHash.BorderDeployUserStart.IsEnabled = $False
    $SyncHash.LabelStatusRDS.Content = "In Progress ...."
    $SyncHash.LabelStatusRDS.Visibility = "Visible"
    $SyncHash.ProgressBarRDS.Visibility = "Visible"
    $DeployRdsStart= @{
        'SyncHash' = $SyncHash
	'ServerIpAddress' = $SyncHash.TextBoxRDSServerIpAddress.Text
        'LocalAdminUserName' = $SyncHash.TextBoxRDSLocalAdminUserName.Text
        'LocalAdminPassword' = $SyncHash.TextBoxRDSLocalAdminPassword.Text
        'DomainAdminUserName' = $SyncHash.TextBoxRDSDomainAdminUserName.Text
        'DomainAdminPassword' = $SyncHash.TextBoxRDSDomainAdminPassword.Text
        'DomainDcServerName' = $SyncHash.TextBoxRDSDomainDcServerName.Text
        'DomainDnsServerIpAddress' = $SyncHash.TextBoxRDSDomainDnsServerIpAddress.Text
        'FSLogixFolderRootPath' = $SyncHash.TextBoxRDSFSLogixFolderRootPath.Text
        'DataFolderRootPath' = $SyncHash.TextBoxRDSDataFolderRootPath.Text
        'OuPath' = $SyncHash.TextBoxRDSOuPath.Text
        'DomainDnsName' = $SyncHash.TextBoxDomainDnsName.Text
        'CheckBoxRas' = $SyncHash.CheckBoxRDSRas.IsChecked
        'RasLicenseEmail' = $SyncHash.TextBoxRDSRasLicenseEmail.Text
        'RasLicensePassword' = $SyncHash.TextBoxRDSRasLicensePassword.Text
        'RasKey' = $SyncHash.TextRDSBoxRasKey.Text
        'CheckBoxStandardServerFSLogixPolicy' = $SyncHash.CheckBoxStandardServerFSLogixPolicy.IsChecked
        'CheckBoxDocuments' = $SyncHash.CheckBoxDocuments.IsChecked
        }
    DeployRdsStart @DeployRdsStart
	# DeployRdsStart -SyncHash $SyncHash -ServerIpAddress  $SyncHash.TextBoxRDSServerIpAddress.Text -ServerName $SyncHash.TextBoxRDSServerName.Text -LocalAdminUserName $SyncHash.TextBoxRDSLocalAdminUserName.Text -LocalAdminPassword $SyncHash.TextBoxRDSLocalAdminPassword.Text -DomainAdminUserName $SyncHash.TextBoxRDSDomainAdminUserName.Text -DomainAdminPassword $SyncHash.TextBoxRDSDomainAdminPassword.Text -DomainDcServerName $SyncHash.TextBoxRDSDomainDcServerName.Text -DomainDnsServerIpAddress $SyncHash.TextBoxRDSDomainDnsServerIpAddress.Text -FSLogixFolderRootPath $SyncHash.TextBoxRDSFSLogixFolderRootPath.Text -DataFolderRootPath $SyncHash.TextBoxRDSDataFolderRootPath.Text -OuPath $SyncHash.TextBoxRDSOuPath.Text -DomainDnsName $SyncHash.TextBoxDomainDnsName.Text -CheckBoxRas $SyncHash.CheckBoxRDSRas.IsChecked  -RasLicenseEmail $SyncHash.TextBoxRDSRasLicenseEmail.Text -RasLicensePassword $SyncHash.TextBoxRDSRasLicensePassword.Text -CheckBoxRasKey $SyncHash.CheckBoxRDSRasKey.IsChecked -RasKey $SyncHash.TextBoxRDSRasKey.Text
    })
$SyncHash.ButtonDeployRdsReboot.Add_Click({
    $SyncHash.BorderDeployRdsReboot.Visibility = "Hidden"
    $SyncHash.ProgressBarRDS.Visibility = "Hidden"
    $SyncHash.BorderDeployO365Start.IsEnabled = $True
    $SyncHash.BorderDeployWUStart.IsEnabled = $True 
    $SyncHash.BorderDeployUserStart.IsEnabled = $True
    $DeployRdsReboot= @{
        'SyncHash' = $SyncHash
	'ServerIpAddress' = $SyncHash.TextBoxRDSServerIpAddress.Text
        'LocalAdminUserName' = $SyncHash.TextBoxRDSLocalAdminUserName.Text
        'LocalAdminPassword' = $SyncHash.TextBoxRDSLocalAdminPassword.Text
        }
    DeployRdsReboot @DeployRdsReboot
    })
$SyncHash.ButtonDeployO365Start.Add_Click({
    $SyncHash.BorderDeployRdsStart.IsEnabled = $False
    $SyncHash.BorderDeployO365Start.IsEnabled = $False
    $SyncHash.BorderDeployWUStart.IsEnabled = $False
    $SyncHash.BorderDeployUserStart.IsEnabled = $False
    $SyncHash.LabelStatusO365.Content = "In Progress ...."
    $SyncHash.LabelStatusO365.Visibility = "Visible"
    $SyncHash.ProgressBarO365.Visibility = "Visible"
    $DeployO365Start= @{
        'SyncHash' = $SyncHash
	'ServerIpAddressList' = $SyncHash.TextBoxO365ServerIpAddress.Text
        'AdminUserName' = $SyncHash.TextBoxO365AdminUserName.Text
        'AdminPassword' = $SyncHash.TextBoxO365AdminPassword.Text
        'CheckBoxExcludeApp' = $SyncHash.CheckBoxExcludeApp.IsChecked
        'RadioButtonO365ProPlusRetail32Bit' = $SyncHash.RadioButtonO365ProPlusRetail32Bit.IsChecked
        'RadioButtonO365ProPlusRetail64Bit' = $SyncHash.RadioButtonO365ProPlusRetail64Bit.IsChecked
        }
	DeployO365Start @DeployO365Start
    })
$SyncHash.ButtonDeployWUStart.Add_Click({
    $SyncHash.BorderDeployRdsStart.IsEnabled = $False  
    $SyncHash.BorderDeployO365Start.IsEnabled = $False
    $SyncHash.BorderDeployWUStart.IsEnabled = $False
    $SyncHash.BorderDeployUserStart.IsEnabled = $False
    $SyncHash.LabelStatusWU.Content = "In Progress ...."
    $SyncHash.LabelStatusWU.Visibility = "Visible"
    $SyncHash.ProgressBarWU.Visibility = "Visible"
    $DeployWUStart= @{
        'SyncHash' = $SyncHash
	'ServerIpAddressList' = $SyncHash.TextBoxWuServerIpAddress.Text
        'AdminUserName' = $SyncHash.TextBoxWuAdminUserName.Text
        'AdminPassword' = $SyncHash.TextBoxWuAdminPassword.Text
        'DayOfWeek' = $SyncHash.ComboBoxWuDayOfWeek.SelectedIndex
        'TimeHour' = $SyncHash.ComboBoxWuTimeHour.SelectedIndex
        'TimeMinutes' = $SyncHash.ComboBoxWuTimeMinutes.SelectedIndex
        }
	DeployWUStart @DeployWUStart
    })
$SyncHash.ButtonDeployUserStart.Add_Click({
    $SyncHash.BorderDeployRdsStart.IsEnabled = $False  
    $SyncHash.BorderDeployO365Start.IsEnabled = $False
    $SyncHash.BorderDeployWUStart.IsEnabled = $False
    $SyncHash.BorderDeployUserStart.IsEnabled = $False
    $SyncHash.LabelStatusUser.Content = "In Progress ...."
    $SyncHash.LabelStatusUser.Visibility = "Visible"
    $SyncHash.ProgressBarUser.Visibility = "Visible"
    $DeployUserStart= @{
        'SyncHash' = $SyncHash
	'ServerIpAddress'= $SyncHash.TextBoxUSERServerIpAddress.Text
        'LocalAdminUserName' = $SyncHash.TextBoxUSERLocalAdminUserName.Text
        'LocalAdminPassword' = $SyncHash.TextBoxUSERLocalAdminPassword.Text
        'DomainAdminUserName' = $SyncHash.TextBoxUSERDomainAdminUserName.Text
        'DomainAdminPassword' = $SyncHash.TextBoxUSERDomainAdminPassword.Text
        'DomainDcServerName' = $SyncHash.TextBoxUSERDomainDcServerName.Text
        'UserType' = $SyncHash.ComboBoxUSERUserType.SelectedIndex
        'DataFolderRootPath' = $SyncHash.TextBoxUSERDataFolderRootPath.Text
        'PrincipalName' = $SyncHash.TextBoxUSERUserAccountName.Text
        'UserGivenName' = $SyncHash.TextBoxUSERUserGivenName.Text
        'UserSurname' = $SyncHash.TextBoxUSERUserSurname.Text
        'UserEmailAddress' = $SyncHash.TextBoxUSERUserEmailAddress.Text
        'UserPassword' = $SyncHash.TextBoxUSERUserPassword.Text
        'OuPath' = $SyncHash.TextBoxUsersOuPath.Text
        'DomainDnsName' = $SyncHash.TextBoxDomainDnsName.Text
        'DomainNetbiosName' = $SyncHash.TextBoxDomainNetbiosName.Text
        }
	DeployUserStart @DeployUserStart
    #$SyncHash.host.ui.WriteVerboseLine($SyncHash.CheckBoxStandardRdsServerPolicy.IsChecked)
    })

# Start ( WPF - Windows Presentation Framework ) Process 
$SyncHash.Window.ShowDialog()

# End ( WPF - Windows Presentation Framework ) Process on Exit
$SyncHash.Window.Add_Closing( { [System.Windows.Forms.Application]::Exit() ; Stop-Process $PID } )
