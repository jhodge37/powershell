Import-Module WebAdministration

Get-ChildItem -Path IIS:\AppPools | foreach {
    Start-WebAppPool $_.Name;
}

Get-ChildItem -Path IIS:\Sites | foreach {
    Start-WebSite $_.Name; 
}