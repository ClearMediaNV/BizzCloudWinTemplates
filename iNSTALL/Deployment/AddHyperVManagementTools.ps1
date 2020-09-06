# Install only the PowerShell module
Install-WindowsFeature -Name Hyper-V-PowerShell
# Install Hyper-V Manager and the PowerShell module
Install-WindowsFeature -Name RSAT-Hyper-V-Tools
