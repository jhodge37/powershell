$env = 'int'
$apps = ('Testapp1','Testapp2','Testapp3')
$servers = ('c1sgtrvap01','c1dgtrvap01','c1dgtrvap02')
foreach ($server in $servers) {
    foreach ($app in $apps) {
        $scriptBlock = {
            #ImportModules
            Import-Module WebAdministration
            

            $cred = Get-credential
                        
            if(Test-Path IIS:\AppPools\$app) {
                Write-Output "App pool exists - removing"
                Remove-WebAppPool $app
                Get-ChildItem IIS:\AppPools
            }
            New-WebAppPool -Name $app
            $appPool = Get-Item "IIS:\AppPools\$app"
            $appPool.processModel.identityType = 3
            $appPool.processModel.username = ($cred.domain+'\'+$cred.username)
            $appPool.processModel.password = $cred.Password
            $appPool.managedRuntimeVersion = "v4.0"
            $appPool.managedPipeLineMode = "Classic"
            $appPool | Set-Item
            
            #create websites
            New-Item iis:\Sites\$app -bindings @{protocol="http";bindingInformation="(':80:'+$app+'.'+$env+'.ert.com')"} -physicalPath C:\inetpub\wwwroot\

            }

        }
        Invoke-Command –ComputerName $server –ScriptBlock $scriptBlock
    }
