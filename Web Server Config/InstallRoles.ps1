#Installs DFS and IIS Roles - Add servers (comma-seperated).

$servers = ('c1sgtrvap01','c1dgtrvap01','c1dgtrvap02')
foreach ($server in $servers)
{
    Install-WindowsFeature -computername $server –Name FS-DFS-Replication, Web-Server, NET-Framework-Features, Web-Net-Ext, Web-Net-Ext45, Web-Asp-Net, Web-Asp-Net45 -includeManagementTools
}