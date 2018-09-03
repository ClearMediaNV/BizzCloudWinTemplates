Install-Module SpeculationControl
# Save the current execution policy so it can be reset
$SaveExecutionPolicy = Get-ExecutionPolicy
Set-ExecutionPolicy RemoteSigned -Scope Currentuser
Import-Module SpeculationControl
Get-SpeculationControlSettings
# Reset the execution policy to the original state
Set-ExecutionPolicy $SaveExecutionPolicy -Scope Currentuser
