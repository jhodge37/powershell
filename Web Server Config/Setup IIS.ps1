#This script creates app pools and websites for the listed applications, across the listed servers



#variables
$env = 'int.' #Follow with "." e.g. "int." leave blank for Prod
$ApplicationName = "atlas"
$servers = ('WIN-0G4HO9015HG') #list all servers requiring install, comma-separated.
$URL = ($ApplicationName+"."+$env+"ert.com")

foreach ($server in $servers) {
    $time = get-date -format "yyyyMMdd"
    $logpath = "C:\Logs\"
    $logfile = ($logpath+$server+'_'+$time+'.txt')
    $createdirs = {
        mkdir $using:logpath -force
        mkdir C:\inetpub\wwwroot\Atlas\V2\AdministrationAPI -force
        mkdir C:\inetpub\wwwroot\Atlas\V2\Administrator -force
        mkdir C:\inetpub\wwwroot\Atlas\V2\MessagingAPI -force
        mkdir C:\inetpub\wwwroot\Atlas\V2\Webinterface -force
    }
    Invoke-Command –ComputerName $server –ScriptBlock $createdirs

    #Installs DFS and IIS Roles.
    Install-WindowsFeature -computername $server –Name FS-DFS-Replication, Web-Server, NET-Framework-Features, Web-Net-Ext, Web-Net-Ext45, Web-Asp-Net, Web-Asp-Net45 -includeManagementTools | out-file $logfile -Append
    if($?) {
        $time = get-date
        Write-Output "Features Installed - $time" | out-file $logfile -append
        }
    $scriptBlock = {
        #ImportModules
        Import-Module WebAdministration
          
        #Get App Pool Identity User
        $cred = Get-credential -Credential "Enter Username for $using:applicationname"
        $cleartextpassword = $cred.getnetworkcredential().Password

        #AppPools
        #AtlasV2 - Remove the app pool if it already exists       
        $time = get-date
        $AppPoolName = 'AtlasV2'
        if(Test-Path IIS:\AppPools\$AppPoolName) {
            Write-Output "$AppPoolName App Pool exists - removing - $time" | out-file $using:logfile -append
            Remove-WebAppPool $AppPoolName
            if($?) {
        $time = get-date
        Write-Output "$AppPoolName App Pool removed - $time" | out-file $using:logfile -append
        }
            Get-ChildItem IIS:\AppPools
            }
            
        #AtlasV2 - Create the app pool
        New-WebAppPool -Name $AppPoolName
        if($?) {
        $time = get-date
        Write-Output "$AppPoolName App Pool created - $time" | out-file $using:logfile -append
        }
        $appPool = Get-Item IIS:\AppPools\$AppPoolName
        $appPool.processModel.identityType = 3
        $appPool.processModel.username = $cred.username
        $appPool.processModel.password = $cleartextpassword
        $appPool.managedRuntimeVersion = "v4.0"
        $appPool.managedPipeLineMode = 1
        $appPool | Set-Item
        if($?) {
        $time = get-date
        Write-Output "$AppPoolName App Pool parameters set - $time" | out-file $using:logfile -append
        }

        #AtlasV2AdministrationAPI - Remove the app pool if it already exists       
        $time = Get-Date
        $AppPoolName = 'AtlasV2AdministrationAPI'
        if(Test-Path IIS:\AppPools\$AppPoolName) {
            Write-Output "$AppPoolName App Pool exists - removing - $time" | out-file $using:logfile -append
            Remove-WebAppPool $AppPoolName
            if($?) {
        $time = get-date
        Write-Output "$AppPoolName App Pool removed - $time" | out-file $using:logfile -append
        }
            Get-ChildItem IIS:\AppPools
            }
            
        #AtlasV2AdministrationAPI - Create the app pool
        New-WebAppPool -Name $AppPoolName
        if($?) {
        $time = get-date
        Write-Output "$AppPoolName App Pool created - $time" | out-file $using:logfile -append
        }
        $appPool = Get-Item IIS:\AppPools\$AppPoolName
        $appPool.processModel.identityType = 3
        $appPool.processModel.username = $cred.username
        $appPool.processModel.password = $cleartextpassword
        $appPool.managedRuntimeVersion = "v4.0"
        #$appPool.managedPipeLineMode = 1
        $appPool | Set-Item
        if($?) {
        $time = get-date
        Write-Output "$AppPoolName App Pool parameters set - $time" | out-file $using:logfile -append
        }
           
        #AtlasV2MessagingAPI - Remove the app pool if it already exists       
        $time = Get-Date
        $AppPoolName = 'AtlasV2MessagingAPI'
        if(Test-Path IIS:\AppPools\$AppPoolName) {
            Write-Output "$AppPoolName App Pool exists - removing - $time" | out-file $using:logfile -append
            Remove-WebAppPool $AppPoolName
            if($?) {
        $time = get-date
        Write-Output "$AppPoolName App Pool removed - $time" | out-file $using:logfile -append
        }
            Get-ChildItem IIS:\AppPools
            }
            
        #AtlasV2AdministrationAPI - Create the app pool
        New-WebAppPool -Name $AppPoolName
        if($?) {
        $time = get-date
        Write-Output "$AppPoolName App Pool created - $time" | out-file $using:logfile -append
        }
        $appPool = Get-Item IIS:\AppPools\$AppPoolName
        $appPool.processModel.identityType = 3
        $appPool.processModel.username = $cred.username
        $appPool.processModel.password = $cleartextpassword
        $appPool.managedRuntimeVersion = "v4.0"
        #$appPool.managedPipeLineMode = 1
        $appPool | Set-Item
        if($?) {
        $time = get-date
        Write-Output "$AppPoolName parameters set - $time" | out-file $using:logfile -append
        }

        Get-ChildItem IIS:\AppPools  | out-file $using:logfile -append

        #Websites
        #Stop Default Website
        Stop-Website -Name "Default Web Site"
        if($?) {
        $time = get-date
        Write-Output "Default Web Site stopped - $time" | out-file $using:logfile -append
        }
        #Remove the website if it already exists       
        $time = Get-Date
        if(Test-Path IIS:\sites\$usingurl) {
            Write-Output "$using:url Website exists - removing - $time" | out-file $using:logfile -append
            Remove-Website $using:url
            if($?) {
        $time = get-date
        Write-Output "$using:url Website removed - $time" | out-file $using:logfile -append
        }
            Get-ChildItem IIS:\Sites  | out-file $using:logfile -append
            }

        #Create websites
        New-Item "iis:\Sites\$using:url" -bindings @{protocol="http";bindingInformation=":80:$using:url"} -physicalPath C:\inetpub\wwwroot\Atlas -ApplicationPool "AtlasV2"
        New-Item "IIS:\Sites\$using:url\V2" -type VirtualDirectory -physicalPath C:\inetpub\wwwroot\Atlas\V2
        New-Item "IIS:\Sites\$using:url\V2\AdministrationAPI" -type Application -physicalpath C:\inetpub\wwwroot\Atlas\V2\AdministrationAPI -ApplicationPool "AtlasV2AdministrationAPI"
        New-Item "IIS:\Sites\$using:url\V2\Administrator" -type Application -physicalpath C:\inetpub\wwwroot\Atlas\V2\Administrator -ApplicationPool "AtlasV2"
        New-Item "IIS:\Sites\$using:url\V2\MessagingAPI" -type Application -physicalpath C:\inetpub\wwwroot\Atlas\V2\MessagingAPI -ApplicationPool "AtlasV2MessagingAPI"
        New-Item "IIS:\Sites\$using:url\V2\Webinterface" -type Application -physicalpath C:\inetpub\wwwroot\Atlas\V2\Webinterface -ApplicationPool "AtlasV2"
        if($?) {
        $time = get-date
        Write-Output "$using:url Websites created - $time" | out-file $using:logfile -append
        }
        }   

Invoke-Command –ComputerName $server –ScriptBlock $scriptBlock

    }