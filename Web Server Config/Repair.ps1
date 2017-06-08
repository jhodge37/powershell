Import-Module WebAdministration

$AppPools = gci -Path IIS:\AppPools
$Sites = gci -Path IIS:\Sites | Where-Object {$_.Name -notmatch "Default Web Site"}
foreach ($AppPools) {
    Start-WebAppPool $_.Name;
}


foreach ($Sites) {
    Start-WebSite $_.Name; 
}

$StoppedSites = GCI -Path IIS:\Sites | Where-Object {$_.Name -notmatch "Default Web Site" -and $_.State -match "Stopped"}
if ($StoppedSites) {Write-host "Still some stopped stuff"}