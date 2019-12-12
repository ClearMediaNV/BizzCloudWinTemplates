Get-CimInstance -Namespace 'root/cimv2/TerminalServices' -ClassName Win32_TerminalServiceSetting | Set-CimInstance -argument  @{EnableDFSS=1;EnableDiskFSS=1;EnableNetworkFSS=1}

Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Quota System]
"EnableCpuQuota"=dword:0
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TSFairShare\Disk]
"EnableFairShare"=dword:0
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TSFairShare\NetFS]
"EnableFairShare"=dword:0
