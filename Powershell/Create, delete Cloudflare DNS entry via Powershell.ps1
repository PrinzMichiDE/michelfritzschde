Write-Host "###################" -ForegroundColor Green
Write-Host "Hallo" $env:UserName "on" $env:ComputerName
Write-Host " "
Set auth and subdomain information
$token = "";
$email = ""
$domain = ""
$zoneid = ""
#external IP
$ipaddr = ""

#Subdomain
$record =

if($domain -eq $null)
{$domain= Read-Host "Which domain is it about? e.g. michelfritzsch.de"}
if($token -eq $null)
{
Start-Process "https://dash.cloudflare.com/profile/api-tokens"
$domain= Read-Host "Specify the API token from Cloudflare - https://dash.cloudflare.com/profile/api-tokens"
}
if($email -eq $null)
{$email= Read-Host "Enter the email account of the Cloudflare account"}

if($zoneid -eq $null)
{$zoneid= Read-Host "Enter the ZoneID for Domain"}

if($zoneid -eq $null)
{$zoneid= Read-Host "Enter the ZoneID for Domain"}

if($ipaddr -eq $null)
{
$ifconfig = curl ifconfig.me/ip
$ipaddr = $ifconfig.Content
}
Write-Host "-----"
Write_host "Domain, E-Mail, ZoneID, External-IP"
Write-Host "$domain, $email, $zoneid, $ipaddr"


Write-Host "-----"

$record = Read-Host "Enter the subdomain without .$domain - e.g. michelfritzsch for michelfritzsch.$domain"
$record = $record -replace ".$domain"
$ticketnumber = "Test"
$connectorUri = ""
$baseurl = "https://api.cloudflare.com/client/v4/zones"
$zoneurl = "$baseurl/?name=$domain"

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Bearer $token")
$recordurl = "$baseurl/$zoneid/dns_records/?name=$record.$domain"
Get current DNS record
$dnsrecord = Invoke-RestMethod -Uri $recordurl -Method Get -Headers $headers
If it exists, update, if not, add
if ($dnsrecord.result.count -gt 0) {
$recordid = $dnsrecord.result.id $dnsrecord.result | Add-Member "content" $ipaddr -Force $body = $dnsrecord.result | ConvertTo-Json $updateurl = "$baseurl/$zoneid/dns_records/$recordid/" $result = Invoke-RestMethod -Uri $updateurl -Method Put -Headers $headers -Body $body
try
{
Write-Output "Record $record.$domain has been updated to the IP $($result.result.content)"
Write-Host "$record.$domain was successfully updated" -ForegroundColor Green
}
catch
{
$error[0]
Write-Host "New record $record.$domain FAIL" -ForegroundColor red
}
}
else {
$newrecord = @{
"type" = "A"
"name" = "$record.$domain"
"content" = $ipaddr
}
$body = $newrecord | ConvertTo-Json $newrecordurl = "https://api.cloudflare.com/client/v4/zones/$zoneid/dns_records"
try
{
$request = Invoke-RestMethod -Uri $newrecordurl -Method Post -Headers $headers -Body $body -ContentType "application/json"
Write-Host "New record $record.$domain has been created with the ID $($request.result.id)" -ForegroundColor Green
Write-Host "$record.$domain was created" -ForegroundColor Green
}
catch
{
$error[0]
Write-Host "New record $record.$domain FAIL" -ForegroundColor red
}
}
Start-Process "https://sh.michelfritzsch.de/amazon"
Read-Host -Prompt “Press Enter to exit”
