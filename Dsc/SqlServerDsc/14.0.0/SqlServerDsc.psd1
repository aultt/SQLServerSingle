@{
    # Version number of this module.
    moduleVersion      = '14.0.0'

    # ID used to uniquely identify this module
    GUID               = '693ee082-ed36-45a7-b490-88b07c86b42f'

    # Author of this module
    Author             = 'DSC Community'

    # Company or vendor of this module
    CompanyName        = 'DSC Community'

    # Copyright statement for this module
    Copyright          = 'Copyright the DSC Community contributors. All rights reserved.'

    # Description of the functionality provided by this module
    Description        = 'Module with DSC resources for deployment and configuration of Microsoft SQL Server.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion  = '5.0'

    # Minimum version of the common language runtime (CLR) required by this module
    CLRVersion         = '4.0'

    # Functions to export from this module
    FunctionsToExport  = @()

    # Cmdlets to export from this module
    CmdletsToExport    = @()

    # Variables to export from this module
    VariablesToExport  = @()

    # Aliases to export from this module
    AliasesToExport    = @()

    DscResourcesToExport = @(
        'SqlAG'
        'SqlAGDatabase'
        'SqlAgentAlert'
        'SqlAgentFailsafe'
        'SqlAgentOperator'
        'SqlAGListener'
        'SqlAGReplica'
        'SqlAlias'
        'SqlAlwaysOnService'
        'SqlDatabase'
        'SqlDatabaseDefaultLocation'
        'SqlDatabaseOwner'
        'SqlDatabaseObjectPermission'
        'SqlDatabasePermission'
        'SqlDatabaseRecoveryModel'
        'SqlDatabaseRole'
        'SqlDatabaseUser'
        'SqlRS'
        'SqlRSSetup'
        'SqlScript'
        'SqlScriptQuery'
        'SqlConfiguration'
        'SqlDatabaseMail'
        'SqlEndpoint'
        'SqlEndpointPermission'
        'SqlServerEndpointState'
        'SqlLogin'
        'SqlMaxDop'
        'SqlMemory'
        'SqlServerNetwork'
        'SqlPermission'
        'SqlProtocol'
        'SqlProtocolTcpIp'
        'SqlReplication'
        'SqlRole'
        'SqlSecureConnection'
        'SqlServiceAccount'
        'SqlSetup'
        'SqlWaitForAG'
        'SqlWindowsFirewall'
    )

    RequiredAssemblies = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData        = @{

        PSData = @{
            # Set to a prerelease string value if the release should be a prerelease.
            Prerelease   = ''

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags         = @('DesiredStateConfiguration', 'DSC', 'DSCResourceKit', 'DSCResource')

            # A URL to the license for this module.
            LicenseUri   = 'https://github.com/dsccommunity/SqlServerDsc/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri   = 'https://github.com/dsccommunity/SqlServerDsc'

            # A URL to an icon representing this module.
            IconUri      = 'https://dsccommunity.org/images/DSC_Logo_300p.png'

            # ReleaseNotes of this module
            ReleaseNotes = '## [14.0.0] - 2020-06-12

### Remove

- SqlServerDsc
  - BREAKING CHANGE: Since the operating system Windows Server 2008 R2 and
    the product SQL Server 2008 R2 has gone end-of-life the DSC resources
    will no longer try to maintain compatibility with them. Moving forward,
    and including this release, there may be code changes that will break
    the resource on Windows Server 2008 R2 or with SQL Server 2008 R2
    ([issue #1514](https://github.com/dsccommunity/SqlServerDsc/issues/1514)).

### Deprecated

The documentation, examples, unit test, and integration tests have been
removed for these deprecated resources. These resources will be removed
in a future release.

- SqlDatabaseOwner
  - This resource is now deprecated. The functionality is now covered by
    a property in the resource _SqlDatabase_ ([issue #966](https://github.com/dsccommunity/SqlServerDsc/issues/966)).
- SqlDatabaseRecoveryModel
  - This resource is now deprecated. The functionality is now covered by
    a property in the resource _SqlDatabase_ ([issue #967](https://github.com/dsccommunity/SqlServerDsc/issues/967)).
- SqlServerEndpointState
  - This resource is now deprecated. The functionality is covered by a
    property in the resource _SqlEndpoint_ ([issue #968](https://github.com/dsccommunity/SqlServerDsc/issues/968)).
- SqlServerNetwork
  - This resource is now deprecated. The functionality is now covered by
    the resources _SqlProtocol_ and _SqlProtocolTcpIp_.

### Added

- SqlSetup
  - Added support for major version upgrade ([issue #1561](https://github.com/dsccommunity/SqlServerDsc/issues/1561)).
- SqlServerDsc
  - Added new resource SqlProtocol ([issue #1377](https://github.com/dsccommunity/SqlServerDsc/issues/1377)).
  - Added new resource SqlProtocolTcpIp ([issue #1378](https://github.com/dsccommunity/SqlServerDsc/issues/1378)).
  - Added new resource SqlDatabaseObjectPermission ([issue #1119](https://github.com/dsccommunity/SqlServerDsc/issues/1119)).
  - Fixing a problem with the latest ModuleBuild 1.7.0 that breaks the CI
    pipeline.
  - Prepare repository for auto-documentation by adding README.md to each
    resource folder with the content from the root README.md.
- SqlServerDsc.Common
  - Added function `Import-Assembly` that can help import an assembly
    into the PowerShell session.
  - Prepared unit tests to support Pester 5 so a minimal conversation
    is only needed later.
  - Updated `Import-SQLPSModule` to better support unit tests.
- CommonTestHelper
  - Added the functions `Get-InvalidOperationRecord` and `Get-InvalidResultRecord`
    that is needed for evaluate localized error message strings for unit tests.
- SqlEndpoint
  - BREAKING CHANGE: A new required property `EndpointType` was added to
    support different types of endpoints in the future. For now the only
    endpoint type that is supported is the database mirror endpoint type
    (`DatabaseMirroring`).
  - Added the property `State` to be able to specify if the endpoint should
    be running, stopped, or disabled. _This property was moved from the now_
    _deprecated DSC resource `SqlServerEndpointState`_.
- SqlSetup
  - A read only property `IsClustered` was added that can be used to determine
    if the instance is clustered.
  - Added the properties `NpEnabled` and `TcpEnabled` ([issue #1161](https://github.com/dsccommunity/SqlServerDsc/issues/1161)).
  - Added the property `UseEnglish` ([issue #1473](https://github.com/dsccommunity/SqlServerDsc/issues/1473)).
- SqlReplication
  - Add integration tests ([issue #755](https://github.com/dsccommunity/SqlServerDsc/issues/755).
- SqlDatabase
  - The property `OwnerName` was added.
- SqlDatabasePermission
  - Now possible to change permissions for database user-defined roles
    (e.g. public) and database application roles ([issue #1498](https://github.com/dsccommunity/SqlServerDsc/issues/1498).
- SqlServerDsc.Common
  - The helper function `Restart-SqlService` was improved to handle Failover
    Clusters better. Now the SQL Server service will only be taken offline
    and back online again if the service is online to begin with.
  - The helper function `Restart-SqlServer` learned the new parameter
    `OwnerNode`. The parameter `OwnerNode` takes an array of Cluster node
    names. Using this parameter the cluster group will only be taken
    offline and back online if the cluster group owner is one specified
    in this parameter.
  - The helper function `Compare-ResourcePropertyState` was improved to
    handle embedded instances by adding a parameter `CimInstanceKeyProperties`
    that can be used to identify the unique parameter for each embedded
    instance in a collection.
  - The helper function `Test-DscPropertyState` was improved to evaluate
    the properties in a single CIM instance or a collection of CIM instances
    by recursively call itself.
  - When the helper function `Test-DscPropertyState` evaluated an array
    the verbose messages was not very descriptive. Instead of outputting
    the side indicator from the compare it now outputs a descriptive
    message.

### Changed

- SqlServerDsc
  - BREAKING CHANGE: Some DSC resources have been renamed ([issue #1540](https://github.com/dsccommunity/SqlServerDsc/issues/1540)).
    - `SqlServerConfiguration` was renamed to `SqlConfiguration`.
    - `SqlServerDatabaseMail` was renamed to `SqlDatabaseMail`.
    - `SqlServerEndpoint` was renamed to `SqlEndpoint`.
    - `SqlServerEndpointPermission` was renamed to `SqlEndpointPermission`.
    - `SqlServerLogin` was renamed to `SqlLogin`.
    - `SqlServerMaxDop` was renamed to `SqlMaxDop`.
    - `SqlServerMemory` was renamed to `SqlMemory`.
    - `SqlServerPermission` was renamed to `SqlPermission`.
    - `SqlServerProtocol` was renamed to `SqlProtocol`.
    - `SqlServerProtocolTcpIp` was renamed to `SqlProtocolTcpIp`.
    - `SqlServerReplication` was renamed to `SqlReplication`.
    - `SqlServerRole` was renamed to `SqlRole`.
    - `SqlServerSecureConnection` was renamed to `SqlSecureConnection`.
  - Changed all resource prefixes from `MSFT_` to `DSC_` ([issue #1496](https://github.com/dsccommunity/SqlServerDsc/issues/1496)).
    _Deprecated resource has not changed prefix._
  - All resources are now using the common module DscResource.Common.
  - When a PR is labelled with ''ready for merge'' it is no longer being
    marked as stale if the PR is not merged for 30 days (for example it is
    dependent on something else) ([issue #1504](https://github.com/dsccommunity/SqlServerDsc/issues/1504)).
  - Updated the CI pipeline to use latest version of the module ModuleBuilder.
  - Changed to use the property `NuGetVersionV2` from GitVersion in the
    CI pipeline.
  - The unit tests now run on PowerShell 7 to optimize the total run time.
- SqlServerDsc.Common
  - The helper function `Invoke-InstallationMediaCopy` was changed to
    handle a breaking change in PowerShell 7 ([issue #1530](https://github.com/dsccommunity/SqlServerDsc/issues/1530)).
  - Removed the local helper function `Set-PSModulePath` as it was
    implemented in the module DscResource.Common.
- CommonTestHelper
  - The test helper function `New-SQLSelfSignedCertificate` was changed
    to install the dependent module `PSPKI` through `RequiredModules.psd1`.
- SqlAlwaysOnService
  - BREAKING CHANGE: The parameter `ServerName` is now non-mandatory and
    defaults to `$env:COMPUTERNAME` ([issue #319](https://github.com/dsccommunity/SqlServerDsc/issues/319)).
  - Normalize parameter descriptive text for default values.
- SqlDatabase
  - BREAKING CHANGE: The parameter `ServerName` is now non-mandatory and
    defaults to `$env:COMPUTERNAME` ([issue #319](https://github.com/dsccommunity/SqlServerDsc/issues/319)).
  - BREAKING CHANGE: The non-mandatory parameters was removed from the
    function `Get-TargetResource` since they were not needed.
  - BREAKING CHANGE: The properties `CompatibilityLevel` and `Collation`
    are now only enforced if the are specified in the configuration.
  - Normalize parameter descriptive text for default values.
- SqlDatabaseDefaultLocation
  - BREAKING CHANGE: The parameter `ServerName` is now non-mandatory and
    defaults to `$env:COMPUTERNAME` ([issue #319](https://github.com/dsccommunity/SqlServerDsc/issues/319)).
  - Normalize parameter descriptive text for default values.
- SqlDatabaseOwner
  - BREAKING CHANGE: Database changed to DatabaseName for consistency with
    other modules ([issue #1484](https://github.com/dsccommunity/SqlServerDsc/issues/1484)).
- SqlDatabasePermission
  - BREAKING CHANGE: The parameter `ServerName` is now non-mandatory and
    defaults to `$env:COMPUTERNAME` ([issue #319](https://github.com/dsccommunity/SqlServerDsc/issues/319)).
  - Normalize parameter descriptive text for default values.
  - BREAKING CHANGE: Database changed to DatabaseName for consistency with
    other modules ([issue #1484](https://github.com/dsccommunity/SqlServerDsc/issues/1484)).
  - BREAKING CHANGE: The resource no longer create the database user if
    it does not exist. Use the resource _SqlDatabaseUser_ to enforce that
    the database user exist in the database prior to setting permissions
    using this resource ([issue #848](https://github.com/dsccommunity/SqlServerDsc/issues/848)).
  - BREAKING CHANGE: The resource no longer checks if a login exist so that
    it is possible to set permissions for database users that does not
    have a login, e.g. the database user ''guest'' ([issue #1134](https://github.com/dsccommunity/SqlServerDsc/issues/1134)).
  - Updated examples.
  - Added integration tests ([issue #741](https://github.com/dsccommunity/SqlServerDsc/issues/741)).
  - Get-TargetResource will no longer throw an exception if the database
    does not exist.
- SqlDatabaseRecoveryModel
  - BREAKING CHANGE: The para'

        } # End of PSData hashtable

    } # End of PrivateData hashtable
}



