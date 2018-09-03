$DomainName = Read-Host -Prompt 'Enter DomainName '
Try
{
    $TenantId = (Invoke-RestMethod -Uri "https://login.windows.net/$DomainName/.well-known/openid-configuration").token_endpoint.Split(‘/’)[3]
    Write-Host -ForegroundColor 10 "The Tenant ID for $DomainName : $TenantId"
}
Catch
{
    Write-Host -ForegroundColor 12 "$DomainName not found!"
}

Start-Sleep -Seconds 30