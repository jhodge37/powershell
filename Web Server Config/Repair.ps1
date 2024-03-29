$Server = $args[0]

$Scriptblock = {
    Import-Module WebAdministration
    $AppPools = gci -Path IIS:\AppPools
    $Sites = gci -Path IIS:\Sites | Where-Object {$_.Name -notmatch "Default Web Site"}
    foreach ($AppPool IN $AppPools) {
        Start-WebAppPool $AppPool.name
    }


    foreach ($Site IN $Sites) {
        Start-WebSite $Site.name 
    }

    $StoppedSites = GCI -Path IIS:\Sites | Where-Object {
        $_.Name -notmatch "Default Web Site" -and $_.State -match "Stopped"
        }
    if ($StoppedSites) {
        iisreset /rebootonerror
    }
}
Invoke-Command –ComputerName $server –ScriptBlock $scriptBlock