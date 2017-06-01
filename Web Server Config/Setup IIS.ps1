#This script creates app pools and websites for the listed applications, across the listed servers



#Gather variables
$env = 'int'
$apps = ('Testapp1','Testapp2','Testapp3')
$servers = ('WIN-0G4HO9015HG')

foreach ($server in $servers) {
    #Installs DFS and IIS Roles - Add servers (comma-seperated).
    Install-WindowsFeature -computername $server –Name FS-DFS-Replication, Web-Server, NET-Framework-Features, Web-Net-Ext, Web-Net-Ext45, Web-Asp-Net, Web-Asp-Net45 -includeManagementTools
    
    #Scriptblock for creating App pools and Sites, per app.
    foreach ($app in $apps) {
        $scriptBlock = {
            #ImportModules
            Import-Module WebAdministration
          
            #Get App Pool Identity User
            $cred = Get-credential -Credential ('Enter Username for '+$using:app)
            $cleartextpassword = $cred.getnetworkcredential().Password

            #Remove the app pool if it already exists       
            if(Test-Path IIS:\AppPools\$using:app) {
               Write-Output "App pool exists - removing"
              Remove-WebAppPool $using:app
             Get-ChildItem IIS:\AppPools
            }
            
            #Create the app pool
            New-WebAppPool -Name $using:app
            $appPool = Get-Item IIS:\AppPools\$using:app
            $appPool.processModel.identityType = 3
            $appPool.processModel.username = $cred.username
            $appPool.processModel.password = $cleartextpassword
            $appPool.managedRuntimeVersion = "v4.0"
            $appPool.managedPipeLineMode = 1
            $appPool | Set-Item
            Get-ChildItem IIS:\AppPools

            
            #Remove the website if it already exists       
            if(Test-Path IIS:\sites\$using:app) {
               Write-Output "Website exists - removing"
              Remove-Website $using:app
             Get-ChildItem IIS:\Sites
            }
            #Create websites
            $binding = (':80:'+$using:app+'.'+$using:env+'.ert.com')
            New-Item iis:\Sites\$using:app -bindings @{protocol="http";bindingInformation=$binding} -physicalPath C:\inetpub\wwwroot\

            }

        Invoke-Command –ComputerName $server –ScriptBlock $scriptBlock
                            }
                               }