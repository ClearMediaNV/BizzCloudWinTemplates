Get-CimInstance -Namespace 'root/cimv2/TerminalServices' -ClassName Win32_TerminalServiceSetting | Set-CimInstance -argument  @{EnableDFSS=1;EnableDiskFSS=1;EnableNetworkFSS=1}
