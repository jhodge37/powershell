#This script creates app pools and websites for the listed applications, across the listed servers

#Gather variables
$env = 'int'
$apps = ('Testapp1','Testapp2','Testapp3')
$servers = ('c1sgtrvap01','c1dgtrvap01','c1dgtrvap02')

foreach ($server in $servers) {
    foreach ($app in $apps) {
        $scriptBlock = {
            #ImportModules
            Import-Module WebAdministration
            
            #Set log path
            mkdir C:\Logs -Force
            $Logfile = ('C:\Logs\'+$app)

            #Get App Pool Identity User
            $cred = Get-credential

            #Remove the app pool if it already exists       
            if(Test-Path IIS:\AppPools\$app) {
                Write-Output "App pool exists - removing" | Out-File $Logfile -Append
                Remove-WebAppPool $app | Out-File $Logfile -Append
                Get-ChildItem IIS:\AppPools | Out-File $Logfile -Append
            }
            
            #Create the app pool
            New-WebAppPool -Name $app | Out-File $Logfile -Append
            $appPool = Get-Item "IIS:\AppPools\$app" | Out-File $Logfile -Append
            $appPool.processModel.identityType = 3 | Out-File $Logfile -Append
            $appPool.processModel.username = ($cred.domain+'\'+$cred.username) | Out-File $Logfile -Append
            $appPool.processModel.password = $cred.Password | Out-File $Logfile -Append
            $appPool.managedRuntimeVersion = "v4.0" | Out-File $Logfile -Append
            $appPool.managedPipeLineMode = "Classic" | Out-File $Logfile -Append
            $appPool | Set-Item | Out-File $Logfile -Append
            Get-ChildItem IIS:\AppPools  | Out-File $Logfile -Append

            #Create websites
            New-Item iis:\Sites\$app -bindings @{protocol="http";bindingInformation="(':80:'+$app+'.'+$env+'.ert.com')"} -physicalPath C:\inetpub\wwwroot\  | Out-File $Logfile -Append

            }

        }
        Invoke-Command –ComputerName $server –ScriptBlock $scriptBlock
    }
