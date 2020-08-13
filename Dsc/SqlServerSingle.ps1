configuration SQLServerSingle
{
    param
    (
        [Parameter(Mandatory)]
        [String]$DomainName,
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$Admincreds,
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$SQLServicecreds,
        #[Parameter(Mandatory)]
        #[System.Management.Automation.PSCredential]$SQLAdmincreds,
        [string]$imageoffer,
        [string]$SQLFeatures = 'SQLENGINE,Replication',
        [string]$SQLInstanceName = 'MSSQLSERVER',
        [string]$datadriveLetter = 'G',
        [string]$logdriveLetter= 'F',
        [string]$tempdbdriveLetter= 'G',
        [string]$SQLSysAdmins = 'dba@demolab.local',
        [string]$SourcePath = "c:\SQLServerFull",
        [string]$SQLPort=1433,
        [string]$TimeZone = "Eastern Standard Time",

        [Int]$RetryCount = 20,
        [Int]$RetryIntervalSec = 30
    )

    Import-DscResource -ModuleName SecurityPolicydsc -ModuleVersion 2.10.0.0
    Import-DscResource -ModuleName StorageDsc -ModuleVersion 5.0.0
    Import-DscResource -ModuleName sqlserverdsc -ModuleVersion 14.0.0
    Import-DscResource -ModuleName ComputerManagementdsc -ModuleVersion 8.2.0

    $SQLVersion = $imageoffer.Substring(5,2)
    $SQLLocation = "MSSQL$(switch ($SQLVersion){19 {15} 17 {14} 16 {13}})"
    #$sqlDataPath ="${datadriveletter}:\Program Files\Microsoft SQL Server\$SQLLocation.$SQLInstanceName\MSSQL\Data"
    #$sqlLogPath = "${logdriveletter}:\Program Files\Microsoft SQL Server\$SQLLocation.$SQLInstanceName\MSSQL\Log"
    
    WaitForSqlSetup

    Node localhost
    {
        LocalConfigurationManager 
        {
            RebootNodeIfNeeded = $True
            RefreshMode = "Push"
            ConfigurationMode = "ApplyOnly"
            ActionAfterReboot = 'ContinueConfiguration'
        }
        
        PowerShellExecutionPolicy 'ExecutionPolicy'
        {
            ExecutionPolicyScope = 'LocalMachine'
            ExecutionPolicy      = 'Unrestricted'
        }

        WaitForDisk DataVolume{
            DiskId = 2
            RetryIntervalSec = 60
            RetryCount =60
        }

        Disk DataVolume{
            DiskId =  2
            DriveLetter = $datadriveLetter
            FSFormat = 'NTFS'
            AllocationUnitSize = 64kb
            DependsOn = '[WaitForDisk]DataVolume'
        }

        WaitForDisk LogVolume{
            DiskId = 3
            RetryIntervalSec = 60
            RetryCount =60
        }

        Disk LogVolume{
            DiskId =  3
            DriveLetter = $logdriveLetter
            FSFormat = 'NTFS'
            AllocationUnitSize = 64kb
            DependsOn = '[WaitForDisk]LogVolume'
        }

        PowerPlan 'HighPerf'
        {
          IsSingleInstance = 'Yes'
          Name             = 'High performance'
        }

        TimeZone 'SetTimeZone'
        {
            IsSingleInstance = 'Yes'
            TimeZone         = $TimeZone
        }

        Computer DomainJoin
        {
            Name       = $env:COMPUTERNAME
            DomainName = $DomainName
            Credential = $AdminCreds
        }

        Script CleanSQL
        {
            SetScript  = 'C:\SQLServerFull\Setup.exe /Action=Uninstall /FEATURES=SQL,AS,RS,IS /INSTANCENAME=MSSQLSERVER /Q'
            TestScript = "(test-path -Path `"C:\Program Files\Microsoft SQL Server\$SQLLocation.MSSQLSERVER\MSSQL\DATA\master.mdf`") -eq `$false"
            GetScript  = "@{Ensure = if ((test-path -Path `"C:\Program Files\Microsoft SQL Server\$SQLLocation.MSSQLSERVER\MSSQL\DATA\master.mdf`") -eq `$false) {'Present'} Else {'Absent'}}"
            DependsON = '[Computer]DomainJoin'
        }

        PendingReboot Reboot1
        {
            Name = 'Reboot1'
            dependson = '[Script]CleanSQL'
        }

        SqlSetup 'InstallNamedInstance'
        {
            InstanceName          = $SQLInstanceName
            Features              = $SQLFeatures
            SQLCollation          = 'SQL_Latin1_General_CP1_CI_AS'
            SQLSvcAccount         = $SQLServicecreds
            SQLSysAdminAccounts   = $SQLSysAdmins
            InstallSharedDir      = 'C:\Program Files\Microsoft SQL Server'
            InstallSharedWOWDir   = 'C:\Program Files (x86)\Microsoft SQL Server'
            InstanceDir           = "${datadriveletter}:\Program Files\Microsoft SQL Server"
            InstallSQLDataDir     = "${datadriveletter}:\Program Files\Microsoft SQL Server\$SQLLocation.$SQLInstanceName\MSSQL\"
            SQLUserDBDir          = "${datadriveletter}:\Program Files\Microsoft SQL Server\$SQLLocation.$SQLInstanceName\MSSQL\Data"
            SQLUserDBLogDir       = "${logdriveletter}:\Program Files\Microsoft SQL Server\$SQLLocation.$SQLInstanceName\MSSQL\Log"
            SQLTempDBDir          = "${tempdbdriveLetter}:\Program Files\Microsoft SQL Server\$SQLLocation.$SQLInstanceName\MSSQL\Data"
            SQLTempDBLogDir       = "${logdriveletter}:\Program Files\Microsoft SQL Server\$SQLLocation.$SQLInstanceName\MSSQL\Log"
            SQLBackupDir          = "${datadriveletter}:\Program Files\Microsoft SQL Server\$SQLLocation.$SQLInstanceName\MSSQL\Backup"
            SourcePath            = $SourcePath
            UpdateEnabled         = 'False'
            ForceReboot           = $false
            BrowserSvcStartupType = 'Automatic'

            PsDscRunAsCredential  = $Admincreds

            DependsOn             = '[PendingReboot]Reboot1'
        }

        UserRightsAssignment PerformVolumeMaintenanceTasks
        {
            Policy = "Perform_volume_maintenance_tasks"
            Identity = $SQLServicecreds.UserName
        }

        UserRightsAssignment LockPagesInMemory
        {
            Policy = "Lock_pages_in_memory"
            Identity = $SQLServicecreds.UserName
        }

        SqlServerNetwork 'ChangeTcpIpOnDefaultInstance'
        {
            InstanceName         = $SQLInstanceName
            ProtocolName         = 'Tcp'
            IsEnabled            = $true
            TCPDynamicPort       = $false
            TCPPort              = $SQLPort
            RestartService       = $true
            DependsOn = '[SqlSetup]InstallNamedInstance'
            
            PsDscRunAsCredential = $AdminCreds
        }

        SqlMaxDop Set_SQLServerMaxDop_ToAuto
        {
            Ensure                  = 'Present'
            DynamicAlloc            = $true
            InstanceName            = $SQLInstanceName
            PsDscRunAsCredential    = $Admincreds

            DependsOn = '[SqlSetup]InstallNamedInstance'
        }

        SqlMemory Set_SQLServerMaxMemory_ToAuto
        {
            Ensure                  = 'Present'
            DynamicAlloc            = $true
            InstanceName            = $SQLInstanceName
            PsDscRunAsCredential    = $Admincreds

            DependsOn = '[SqlSetup]InstallNamedInstance'
        }

        SqlWindowsFirewall Create_FirewallRules
        {
            Ensure           = 'Present'
            Features         = $SQLFeatures
            InstanceName     = $SQLInstanceName
            SourcePath       = 'C:\SQLServerFull'

            DependsOn = '[SqlSetup]InstallNamedInstance'
        }

        #Script  'RestoreDatabase'
        #{
        #    getscript = {Invoke-Sqlcmd -query "select * from sys.databases where name ='$using:SubscriberDatabase'" -ServerInstance $serverInstance -Database master}
        #    setscript ={Invoke-Sqlcmd -query "RESTORE DATABASE [$using:SubscriberDatabase] FROM  DISK = N'$using:PubBackupShare\$using:ReplicatedDatabase.bak' WITH  FILE = 1, MOVE N'$($using:ReplicatedDatabase)_Data' TO N'$using:sqlDataPath\$($using:SubscriberDatabase)_Data.mdf', MOVE N'$($using:ReplicatedDatabase)_Log' TO N'$($using:sqlLogPath)\$($using:SubscriberDatabase)_Log.ldf',  NOUNLOAD" -ServerInstance $serverInstance -Database master}
        #    testscript ={if ($(Invoke-Sqlcmd -query "select count(1) as count from sys.databases where name = '$using:SubscriberDatabase'" -ServerInstance $serverInstance -Database master).count -eq 1)
        #                    {return $true}
        #                else {return $false}
        #    }
        #
        #    PsDscRunAsCredential = $SQLAdmincreds
        #    DependsOn = '[SqlSetup]InstallNamedInstance', '[xCluster]CreateCluster'
        #}

        Script  'SetSPNforServer'
        {
            getscript = {Get-DbaSpn -ComputerName $env:COMPUTERNAME -Credential $AdminCreds}
            setscript ={Test-DbaSpn -ComputerName $env:COMPUTERNAME | Where-Object { $_.isSet -eq $false } | Set-DbaSpn -Credential $AdminCreds}
            testscript ={if ($(Test-DbaSpn -ComputerName $env:COMPUTERNAME -Credential $AdminCreds).isset -eq $True)
                            {return $true}
                        else {return $false}
                        }
            DependsOn = '[SqlSetup]InstallNamedInstance'
            
            PsDscRunAsCredential = $AdminCreds
        }
    }
}

function WaitForSqlSetup
{
    # Wait for SQL Server Setup to finish before proceeding.
    while ($true)
    {
        try
        {
            Get-ScheduledTaskInfo "\ConfigureSqlImageTasks\RunConfigureImage" -ErrorAction Stop
            Start-Sleep -Seconds 5
        }
        catch
        {
            break
        }
    }
}

$ConfigData = @{
    AllNodes = @(
    @{
        NodeName = 'localhost'
        PSDscAllowPlainTextPassword = $true
    }
    )
}

# $AdminCreds = Get-Credential

# $SQLServicecreds = Get-Credential
# SQLServerSingle -DomainName demolab.local -imageoffer "sql2019-ws2019" -Admincreds $AdminCreds -SQLServicecreds $SQLServicecreds -Verbose -ConfigurationData $ConfigData -OutputPath C:\Packages\Plugins\Microsoft.Powershell.DSC\2.80.0.0\DSCWork\SqlServerSingle.0\SQLServerSingle

# Start-DscConfiguration -wait -Force -Verbose -Path C:\Packages\Plugins\Microsoft.Powershell.DSC\2.80.0.0\DSCWork\SqlServerSingle.0\SQLServerSingle


 
 
