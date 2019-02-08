$json = Invoke-WebRequest -Uri https://api.github.com/repos/guyjochmans/cmscripts -Method Get -ErrorAction Stop
Invoke-WebRequest -Body $RequestBody -Uri https://api.github.com/repos/guyjochmans/cmscripts/pulls -Method Get -Headers @{"Authorization"="Basic $BasicCreds"} -ErrorAction Stop
