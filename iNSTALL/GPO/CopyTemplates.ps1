﻿Copy-Item -Path 'C:\iNSTALL\GPO\Templates\admx\*' -Destination 'C:\Windows\PolicyDefinitions' -Force
Copy-Item -Path 'C:\iNSTALL\GPO\Templates\admx\en-US\*' -Destination 'C:\Windows\PolicyDefinitions\en-US' -Force
Copy-Item -Path 'C:\iNSTALL\GPO\Templates\admx\fr-FR\*' -Destination 'C:\Windows\PolicyDefinitions\fr-FR' -Force
New-Item -Path 'C:\Windows\SYSVOL\domain\Policies\PolicyDefinitions' -ItemType Directory -Force
Copy-Item -Path 'C:\Windows\PolicyDefinitions\*' -Destination 'C:\Windows\SYSVOL\domain\Policies\PolicyDefinitions' -Force
New-Item -Path 'C:\Windows\SYSVOL\domain\Policies\PolicyDefinitions\en-US' -ItemType Directory -Force
New-Item -Path 'C:\Windows\SYSVOL\domain\Policies\PolicyDefinitions\fr-FR' -ItemType Directory -Force
Copy-Item -Path 'C:\Windows\PolicyDefinitions\en-US\*' -Destination 'C:\Windows\SYSVOL\domain\Policies\PolicyDefinitions\en-US' -Force
Copy-Item -Path 'C:\Windows\PolicyDefinitions\fr-FR\*' -Destination 'C:\Windows\SYSVOL\domain\Policies\PolicyDefinitions\fr-FR' -Force