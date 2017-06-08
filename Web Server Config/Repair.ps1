Import-Module WebAdministration

Get-ChildItem -Path IIS:\AppPools | foreach {
    Start-WebAppPool $_.Name;
}

Get-ChildItem -Path IIS:\Sites | Where-Object {$_.Name -notmatch "Default Web Site"} | foreach {
    Start-WebSite $_.Name; 
}