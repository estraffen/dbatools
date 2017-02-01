﻿Function Install-OlaIndexOptimize
{
<#
.SYNOPSIS
Automatically installs or updates Ola Hallengren's Maintenance Solution. Wrapper for Install-SqlDatabaseBackup, Install-SqlDatabaseIntegrityCheck and Install-SqlIndexOptimize.

.DESCRIPTION
This command downloads and installs Maintenance Solution, with Ola's permission.
	
To read more about Maintenance Solution, please visit https://ola.hallengren.com
	
.PARAMETER SqlServer
The SQL Server instance.You must have sysadmin access and server version must be SQL Server version 2000 or higher.

.PARAMETER SqlCredential
Allows you to login to servers using SQL Logins as opposed to Windows Auth/Integrated/Trusted. To use:

$scred = Get-Credential, then pass $scred object to the -SqlCredential parameter. 

Windows Authentication will be used if SqlCredential is not specified. SQL Server does not accept Windows credentials being passed as credentials. To connect as a different Windows user, run PowerShell as that user.

.PARAMETER OutputDatabaseName
Outputs just the database name instead of the success message

.LINK
https://dbatools.io/Install-SqlWhoIsActive

.EXAMPLE
Install-SqlWhoIsActive -SqlServer sqlserver2014a -Database master

Installs sp_WhoIsActive to sqlserver2014a's master database. Logs in using Windows Authentication.
	
.EXAMPLE   
Install-SqlWhoIsActive -SqlServer sqlserver2014a -SqlCredential $cred

Pops up a dialog box asking which database on sqlserver2014a you want to install the proc to. Logs into SQL Server using SQL Authentication.

#>
	
	[CmdletBinding(DefaultParameterSetName = "Default", SupportsShouldProcess = $true)]
	Param (
		[parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[Alias("ServerInstance", "SqlInstance")]
		[object]$SqlServer,
		[object]$SqlCredential,
		[string]$Path,
		[string]$Databases,
		[ValidateSet('RebuildOnline', 'RebuildOffline', 'Reorganize')]
		[string[]]$FragmentationLow,
		[ValidateSet('RebuildOnline', 'RebuildOffline', 'Reorganize')]
		[string[]]$FragmentationMedium = @('Reorganize','RebuildOnline','RebuildOffline'),
		[ValidateSet('RebuildOnline', 'RebuildOffline', 'Reorganize')]
		[string[]]$FragmentationHigh = @('RebuildOnline', 'RebuildOffline'),
		[int]$FragmentationLevel1 = 5,
		[int]$FragmentationLevel2 = 30,
		[int]$PageCountLevel = 1000,
		[switch]$SortInTempdb,
		[int]$MaxDOP,
		[ValidateLength(0, 100)]
		[int]$FillFactor,
		[string]$PadIndex,
		[switch]$NoLOBCompaction,
		[string]$UpdateStatistics,
		[switch]$OnlyModifiedStatistics,
		[int]$StatisticsSample,
		[switch]$StatisticsResample,
		[string]$NoPartitionLevel,
		[switch]$MSShippedObjects,
		[string]$Indexes,
		[int]$TimeLimit,
		[int]$Delay,
		[int]$WaitAtLowPriorityMaxDuration,
		[string]$WaitAtLowPriorityAbortAfterWait,
		[int]$LockTimeout,
		[switch]$LogToTable,
		[switch]$OutputOnly
	)
	
	DynamicParam
	{
		if ($sqlserver)
		{
			return Get-ParamInstallDatabase -SqlServer $sqlserver -SqlCredential $SqlCredential 
		}
	}
	
	BEGIN
	{
		
		if ($FragmentationLow.Length -gt 0) {
			$FragmentationLow = $FragmentationLow -join ','
			$FragmentationLow = $FragmentationLow.Replace('RebuildOnline', 'INDEX_REBUILD_ONLINE')
			$FragmentationLow = $FragmentationLow.Replace('RebuildOffline', 'INDEX_REBUILD_OFFLINE')
			$FragmentationLow = $FragmentationLow.Replace('Reorganize', 'INDEX_REORGANIZE')
		}
		
		if ($FragmentationMedium.Length -gt 0)
		{
			$FragmentationMedium = $FragmentationMedium -join ','
			$FragmentationMedium = $FragmentationMedium.Replace('RebuildOnline', 'INDEX_REBUILD_ONLINE')
			$FragmentationMedium = $FragmentationMedium.Replace('RebuildOffline', 'INDEX_REBUILD_OFFLINE')
			$FragmentationMedium = $FragmentationMedium.Replace('Reorganize', 'INDEX_REORGANIZE')
		}
		
		if ($FragmentationHigh.Length -gt 0)
		{
			$FragmentationHigh = $FragmentationHigh -join ','
			$FragmentationHigh = $FragmentationHigh.Replace('RebuildOnline', 'INDEX_REBUILD_ONLINE')
			$FragmentationHigh = $FragmentationHigh.Replace('RebuildOffline', 'INDEX_REBUILD_OFFLINE')
			$FragmentationHigh = $FragmentationHigh.Replace('Reorganize', 'INDEX_REORGANIZE')
		}
		
		switch ($OutputOnly)
		{
			$true { $Execute = $false }
			$false { $Execute = $true }
		}
		
		switch ($NoLOBCompaction)
		{
			$true { $LOBCompaction = $false }
			$false { $LOBCompaction = $true }
		}
		
		switch ($NoPartitionLevel)
		{
			$true { $PartitionLevel = $false }
			$false { $PartitionLevel = $true }
		}
		
		$switches = 'SortInTempdb', 'LOBCompaction', 'OnlyModifiedStatistics', 'StatisticsResample', 'MSShippedObjects', 'LogToTable', 'Execute', 'PartitionLevel'
		
		foreach ($switch in $switches)
		{
			$paramvalue = Get-Variable -Name $switch -ValueOnly
			
			if ($paramvalue -eq $true)
			{
				Set-Variable -Name $switch -Value 'Y'
			}
			else
			{
				Set-Variable -Name $switch -Value 'N'
			}
			
		}
		
		$CheckCommands = $CheckCommands -join  ","
		
		$sourceserver = Connect-SqlServer -SqlServer $sqlserver -SqlCredential $SqlCredential -RegularUser
		$source = $sourceserver.DomainInstanceName
		
		Function Get-IndexOptimize
		{
			
			$url = 'https://ola.hallengren.com/scripts/IndexOptimize.sql'
			$temp = ([System.IO.Path]::GetTempPath()).TrimEnd("\")
			$sqlfile = "$temp\IndexOptimize.sql"
			
			try
			{
				Invoke-WebRequest $url -OutFile $sqlfile
			}
			catch
			{
				#try with default proxy and usersettings
				(New-Object System.Net.WebClient).Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
				Invoke-WebRequest $url -OutFile $sqlfile
			}
			
			# Unblock if there's a block
			Unblock-File $sqlfile -ErrorAction SilentlyContinue
		}
		
		$InstallDatabase = $psboundparameters.InstallDatabase
		
		if ($Header -like '*update*')
		{
			$action = "update"
		}
		else
		{
			$action = "install"
		}
		
		$textinfo = (Get-Culture).TextInfo
		$actiontitle = $textinfo.ToTitleCase($action)
		
		if ($action -eq "install")
		{
			$actioning = "installing"
		}
		else
		{
			$actioning = "updating"
		}
	}
	
	PROCESS
	{ 
		if ($InstallDatabase.length -eq 0)
		{
			$InstallDatabase = Show-SqlDatabaseList -SqlServer $sourceserver -Title "$actiontitle sp_WhoisActive" -Header $header -DefaultDb "master"
			
			if ($InstallDatabase.length -eq 0)
			{
				throw "You must select a database to $action the procedure"
			}
			
			if ($InstallDatabase -ne 'master')
			{
				Write-Warning "You have selected a database other than master. When you run Show-SqlWhoIsActive in the future, you must specify -Database $InstallDatabase"
			}
		}
		
		if ($Path.Length -eq 0)
		{
			$temp = ([System.IO.Path]::GetTempPath()).TrimEnd("\")
			$file = Get-ChildItem "$temp\IndexOptimize.sql" | Select -First 1
			$path = $file.FullName
			
			if ($path.Length -eq 0 -or $force -eq $true)
			{
				try
				{
					Write-Output "Downloading IndexOptimize.sql and $actioning."
					Get-IndexOptimize
				}
				catch
				{
					throw "Couldn't download IndexOptimize.sql. Please download and $action manually from https://ola.hallengren.com/scripts/IndexOptimize.sql."
				}
			}
			
			$path = (Get-ChildItem "$temp\IndexOptimize.sql" | Select -First 1).Name
			$path = "$temp\$path"
		}
		
		if ((Test-Path $Path) -eq $false)
		{
			throw "Invalid path at $path"
		}
		
		$sql = [IO.File]::ReadAllText($path)
		$sql = $sql -replace 'USE master', ''
		$batches = $sql -split "GO\r\n"
		
		foreach ($batch in $batches)
		{
			try
			{
				$null = $sourceserver.databases[$InstallDatabase].ExecuteNonQuery($batch)
				
			}
			catch
			{
				Write-Exception $_
				throw "Can't $action stored procedure. See exception text for details."
			}
		}
	}
	
	END
	{
		$sourceserver.ConnectionContext.Disconnect()
		
		if ($OutputDatabaseName -eq $true)
		{
			return $InstallDatabase
		}
		else
		{
			Write-Output "Finished $actioning IndexOptimize in $InstallDatabase on $SqlServer "
		}
	}
}