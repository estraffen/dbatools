#
# Module manifest for module 'dbatools'
#
# Generated by: Chrissy LeMaire
#
# Generated on: 9/8/2015
#
@{
	
	# Script module or binary module file associated with this manifest.
	RootModule = 'dbatools.psm1'
	
	# Version number of this module.
	ModuleVersion = '0.8.0.5'
	
	# ID used to uniquely identify this module
	GUID = '9d139310-ce45-41ce-8e8b-d76335aa1789'
	
	# Author of this module
	Author = 'Chrissy LeMaire'
	
	# Company or vendor of this module
	CompanyName = 'netnerds.net'
	
	# Copyright statement for this module
	Copyright = '2016 Chrissy LeMaire'
	
	# Description of the functionality provided by this module
	Description = 'Provides extra functionality for SQL Server Database admins and enables SQL Server instance migrations.'
	
	# Minimum version of the Windows PowerShell engine required by this module
	PowerShellVersion = '3.0'
	
	# Name of the Windows PowerShell host required by this module
	PowerShellHostName = ''
	
	# Minimum version of the Windows PowerShell host required by this module
	PowerShellHostVersion = ''
	
	# Minimum version of the .NET Framework required by this module
	DotNetFrameworkVersion = ''
	
	# Minimum version of the common language runtime (CLR) required by this module
	CLRVersion = ''
	
	# Processor architecture (None, X86, Amd64, IA64) required by this module
	ProcessorArchitecture = ''
	
	# Modules that must be imported into the global environment prior to importing this module
	RequiredModules = @()
	
	# Assemblies that must be loaded prior to importing this module
	RequiredAssemblies = @('Microsoft.SqlServer.Smo', 'Microsoft.SqlServer.SmoExtended',
	'Microsoft.SqlServer.Management.XEvent', 'Microsoft.SQlServer.Management.Sdk.Sfc',
	'Microsoft.SqlServer.Rmo', 'Microsoft.SqlServer.Dmf', 'Microsoft.SqlServer.SqlEnum'
	'Microsoft.SqlServer.Management.RegisteredServers','Microsoft.SqlServer.Management.Collector')
	
	# Script files () that are run in the caller's environment prior to importing this module
	ScriptsToProcess = @()
	
	# Type files (xml) to be loaded when importing this module
	TypesToProcess = @()
	
	# Format files (xml) to be loaded when importing this module
	FormatsToProcess = @()
	
	# Modules to import as nested modules of the module specified in ModuleToProcess
	NestedModules = @()
	
	# Functions to export from this module
	FunctionsToExport = @('Start-SqlMigration','Copy-SqlDatabase', 'Copy-SqlLogin', 'Copy-SqlServerAgent', 'Copy-SqlSpConfigure',
	'Copy-SqlLinkedServer','Copy-SqlDatabaseMail', 'Get-SqlServerKey', 'Set-SqlMaxMemory', 'Reset-SqlAdmin',
	'Copy-SqlCustomError','Copy-SqlAuditSpecification','Copy-SqlEndpoint', 'Copy-SqlAudit', 'Copy-SqlServerRole', 
	'Copy-SqlResourceGovernor','Copy-SqlExtendedEvent', 'Copy-SqlBackupDevice', 'Copy-SqlServerTrigger', 
	'Copy-SqlCredential','Copy-SqlCentralManagementServer', 'Copy-SqlSysDbUserObjects', 'Copy-SqlProxyAccount',
	'Import-SqlSpConfigure', 'Export-SqlSpConfigure', 'Watch-SqlDbLogin', 'Get-SqlMaxMemory', 'Copy-SqlAlert',
	'Get-DetachedDBInfo', 'Restore-HallengrenBackup', 'Test-SqlConnection', 'Import-CsvToSql', 'Copy-SqlAgentCategory',
	'Update-dbatools', 'Test-SqlPath', 'Copy-SqlDatabaseAssembly', 'Copy-SqlPolicyManagement','Copy-SqlSharedSchedule',
	'Copy-SqlOperator','Copy-SqlJob','Copy-SqlDataCollector','Sync-SqlLoginPermissions')
	
	# 'Copy-SqlDataCollector',
	
	# Cmdlets to export from this module
	CmdletsToExport = '*'
	
	# Variables to export from this module
	VariablesToExport = '*'
	
	# Aliases to export from this module
	AliasesToExport = 'Reset-SqlSaPassword','Copy-SqlUserDefinedMessage','Copy-SqlJobServer'
	
	# List of all modules packaged with this module
	ModuleList = @()
	
	# List of all files packaged with this module
	FileList = ''
	
	PrivateData = @{
    # PSData is module packaging and gallery metadata embedded in PrivateData
    # It's for rebuilding PowerShellGet (and PoshCode) NuGet-style packages
    # We had to do this because it's the only place we're allowed to extend the manifest
    # https://connect.microsoft.com/PowerShell/feedback/details/421837
    PSData = @{
        # The primary categorization of this module (from the TechNet Gallery tech tree).
        Category = "Databases"

        # Keyword tags to help users find this module via navigations and search.
        Tags = @('sqlserver','migrations','sql','dba','databases')

        # The web address of an icon which can be used in galleries to represent this module
        IconUri = "https://dbatools.io/logo.png"

        # The web address of this module's project or support homepage.
        ProjectUri = "https://dbatools.io"

        # The web address of this module's license. Points to a page that's embeddable and linkable.
        LicenseUri = "http://www.gnu.org/licenses/gpl-3.0.en.html"

        # Release notes for this particular version of the module
        # ReleaseNotes = False

        # If true, the LicenseUrl points to an end-user license (not just a source license) which requires the user agreement before use.
        # RequireLicenseAcceptance = ""

        # Indicates this is a pre-release/testing version of the module.
        IsPrerelease = 'True'
		}
	}
}