
$servers = ('c1sgtrvap01','c1dgtrvap01','c1dgtrvap02')
foreach ($server in $servers) 
{
$apps = ('Testapp1', 'Testapp2', 'Testapp3')
foreach ($app in $apps)
$scriptBlock = {

#ImportModules
Import-Module WebAdministration

#create app pools 
$ID = "ERT\gth_atlas_test"
$cred = Get-Credential -Credential $ID
$appPoolName = "TestAppPool2"
if(Test-Path IIS:\AppPools\$appPoolName)  
{
    Write-Output "App pool exists - removing"
    Remove-WebAppPool $appPoolName
    Get-ChildItem IIS:\AppPools
}
New-WebAppPool -Name $appPoolName
$appPool = Get-Item "IIS:\AppPools\$appPoolName"
$appPool.processModel.identityType = 3
$appPool.processModel.username = $ID
$appPool.processModel.password = $cred.GetNetworkCredential().Password
$appPool.managedRuntimeVersion = "v4.0"
$appPool.managedPipeLineMode = "Classic"
$appPool | Set-Item


#create websites
New-Item iis:\Sites\Atlas -bindings @{protocol="http";bindingInformation=":80:atlas.int.ert.com"} -physicalPath C:\inetpub\wwwroot\



}
Invoke-Command –ComputerName $server –ScriptBlock $scriptBlock