#This script creates app pools and websites for the listed applications, across the listed servers



#Gather variables
#$env = 'int'
##$apps = ('Testapp1','Testapp2','Testapp3')
$servers = ('WIN-0G4HO9015HG')

foreach ($server in $servers) {
    #Installs DFS and IIS Roles - Add servers (comma-seperated).
    Install-WindowsFeature -computername $server –Name FS-DFS-Replication, Web-Server, NET-Framework-Features, Web-Net-Ext, Web-Net-Ext45, Web-Asp-Net, Web-Asp-Net45 -includeManagementTools
    
    #Scriptblock for creating App pools and Sites, per app.
    ##foreach ($app in $apps) {
        $scriptBlock = {
            #ImportModules
            Import-Module WebAdministration
          
            #Get App Pool Identity User
            $cred = Get-credential -Credential 'Enter Username for Atlas'
            $cleartextpassword = $cred.getnetworkcredential().Password


        #AppPools
            #AtlasV2 - Remove the app pool if it already exists       
            if(Test-Path IIS:\AppPools\AtlasV2) {
               Write-Output "App pool exists - removing"
              Remove-WebAppPool AtlasV2
             Get-ChildItem IIS:\AppPools
            }
            
            #AtlasV2 - Create the app pool
            New-WebAppPool -Name AtlasV2
            $appPool = Get-Item IIS:\AppPools\AtlasV2
            $appPool.processModel.identityType = 3
            $appPool.processModel.username = $cred.username
            $appPool.processModel.password = $cleartextpassword
            $appPool.managedRuntimeVersion = "v4.0"
            $appPool.managedPipeLineMode = 1
            $appPool | Set-Item

            #AtlasV2AdministrationAPI - Remove the app pool if it already exists       
            if(Test-Path IIS:\AppPools\AtlasV2AdministrationAPI) {
               Write-Output "App pool exists - removing"
              Remove-WebAppPool AtlasV2AdministrationAPI
             Get-ChildItem IIS:\AppPools
            }
            
            #AtlasV2AdministrationAPI - Create the app pool
            New-WebAppPool -Name AtlasV2AdministrationAPI
            $appPool = Get-Item IIS:\AppPools\AtlasV2AdministrationAPI
            $appPool.processModel.identityType = 3
            $appPool.processModel.username = $cred.username
            $appPool.processModel.password = $cleartextpassword
            $appPool.managedRuntimeVersion = "v4.0"
            #$appPool.managedPipeLineMode = 1
            $appPool | Set-Item
           
           #AtlasV2MessagingAPI - Remove the app pool if it already exists       
            if(Test-Path IIS:\AppPools\AtlasV2MessagingAPI) {
               Write-Output "App pool exists - removing"
              Remove-WebAppPool AtlasV2MessagingAPI
             Get-ChildItem IIS:\AppPools
            }
            
            #AtlasV2AdministrationAPI - Create the app pool
            New-WebAppPool -Name AtlasV2MessagingAPI
            $appPool = Get-Item IIS:\AppPools\AtlasV2MessagingAPI
            $appPool.processModel.identityType = 3
            $appPool.processModel.username = $cred.username
            $appPool.processModel.password = $cleartextpassword
            $appPool.managedRuntimeVersion = "v4.0"
            #$appPool.managedPipeLineMode = 1
            $appPool | Set-Item

            Get-ChildItem IIS:\AppPools

        #Websites
            #Remove the website if it already exists       
            if(Test-Path IIS:\sites\atlas.int.ert.com) {
               Write-Output "Website exists - removing"
              Remove-Website atlas.int.ert.com
             Get-ChildItem IIS:\Sites
            }

            #Create websites
            $binding = (:80:atlas.int.ert.com)
            New-Item 'iis:\Sites\atlas.int.ert.com' -bindings @{protocol="http";bindingInformation=$binding} -physicalPath C:\inetpub\wwwroot\Atlas -ApplicationPool "AtlasV2"
            New-Item 'IIS:\Sites\atlas.int.ert.com\V2' -type VirtualDirectory -physicalPath C:\inetpub\wwwroot\Atlas\V2
            New-Item 'IIS:\Sites\atlas.int.ert.com\V2\AdministrationAPI' -type Application -physicalpath C:\inetpub\wwwroot\Atlas\V2\AdministrationAPI -ApplicationPool "AtlasV2AdministrationAPI"
            New-Item 'IIS:\Sites\atlas.int.ert.com\V2\Administrator' -type Application -physicalpath C:\inetpub\wwwroot\Atlas\V2\Administrator -ApplicationPool "AtlasV2"
            New-Item 'IIS:\Sites\atlas.int.ert.com\V2\MessagingAPI' -type Application -physicalpath C:\inetpub\wwwroot\Atlas\V2\MessagingAPI -ApplicationPool "AtlasV2MessagingAPI"
            New-Item 'IIS:\Sites\atlas.int.ert.com\V2\Webinterface' -type Application -physicalpath C:\inetpub\wwwroot\Atlas\V2\Webinterface -ApplicationPool "AtlasV2"
            
            }

        Invoke-Command –ComputerName $server –ScriptBlock $scriptBlock
                            }
                               }