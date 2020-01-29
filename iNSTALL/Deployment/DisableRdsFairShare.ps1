Get-CimInstance -Namespace 'root/cimv2/TerminalServices' -ClassName Win32_TerminalServiceSetting | Set-CimInstance -argument  @{EnableDFSS=0;EnableDiskFSS=0;EnableNetworkFSS=0}
