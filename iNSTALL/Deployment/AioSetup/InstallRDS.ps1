# Installation of RDS Session Host will restart the System
Install-windowsfeature RDS-RD-Server, RDS-Licensing, RDS-Licensing-UI, RSAT-RDS-Licensing-Diagnosis-UI, RSAT-Print-Services, RSAT-File-Services, RSAT-FSRM-Mgmt, Server-Media-Foundation, Windows-TIFF-IFilter -restart
