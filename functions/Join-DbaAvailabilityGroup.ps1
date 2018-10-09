﻿#ValidationTags#Messaging,FlowControl,Pipeline,CodeStyle#
function Join-DbaAvailabilityGroup {
<#
    .SYNOPSIS
        Joins a secondary replica to an availability group on a SQL Server instance.
        
    .DESCRIPTION
        Joins a secondary replica to an availability group on a SQL Server instance.
    
    .PARAMETER SqlInstance
        SQL Server name or SMO object representing the SqlInstance SQL Server.
        
    .PARAMETER SqlCredential
        Login to the SqlInstance instance using alternative credentials. Windows and SQL Authentication supported. Accepts credential objects (Get-Credential)
        
    .PARAMETER Secondary
        SQL Server name or SMO object representing the secpondary SQL Server instance or instances.
        
    .PARAMETER SecondarySqlCredential
        Login to the target instance using alternative credentials. Windows and SQL Authentication supported. Accepts credential objects (Get-Credential)
        
    .PARAMETER AvailabilityGroup
        Only add specific availability groups.
        
    .PARAMETER InputObject
        Internal parameter to support piping from Get-DbaDatabase, Get-DbaDbSharePoint and more.
        
    .PARAMETER WhatIf
        Shows what would happen if the command were to run. No actions are actually performed.
        
    .PARAMETER Confirm
        Prompts you for confirmation before executing any changing operations within the command.
    
    .PARAMETER EnableException
        By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
        This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
        Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.
        
    .NOTES
        Tags: AvailabilityGroup, HA, AG
        Author: Chrissy LeMaire (@cl), netnerds.net
        Website: https://dbatools.io
        Copyright: (c) 2018 by dbatools, licensed under MIT
        License: MIT https://opensource.org/licenses/MIT
        
    .LINK
        https://dbatools.io/Join-DbaAvailabilityGroup
        
    .EXAMPLE
        PS C:\> Join-DbaAvailabilityGroup -SqlInstance sqlserver2012 -AllAvailabilityGroup
        
        Adds all availability groups on the sqlserver2014 instance. Does not prompt for confirmation.
        
    .EXAMPLE
        PS C:\> Join-DbaAvailabilityGroup -SqlInstance sqlserver2012 -AvailabilityGroup ag1, ag2 -Confirm
        
        Adds the ag1 and ag2 availability groups on sqlserver2012. Prompts for confirmation.
        
    .EXAMPLE
        PS C:\> Get-DbaDatabase -SqlInstance sqlserver2012 | Out-GridView -Passthru | Join-DbaAvailabilityGroup -AvailabilityGroup ag1
        
        Adds selected databases from sqlserver2012 to ag1
  
    .EXAMPLE
        PS C:\> Get-DbaDbSharePoint -SqlInstance sqlcluster | Join-DbaAvailabilityGroup -AvailabilityGroup SharePoint
        
        Adds SharePoint databases as found in SharePoint_Config on sqlcluster to ag1 on sqlcluster
    
    .EXAMPLE
        PS C:\> Get-DbaDbSharePoint -SqlInstance sqlcluster -ConfigDatabase SharePoint_Config_2019 | Join-DbaAvailabilityGroup -AvailabilityGroup SharePoint
        
        Adds SharePoint databases as found in SharePoint_Config_2019 on sqlcluster to ag1 on sqlcluster
#>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    param (
        [parameter(Mandatory)]
        [DbaInstanceParameter[]]$SqlInstance,
        [PSCredential]$SqlCredential,
        [parameter(Mandatory)]
        [string[]]$AvailabilityGroup,
        [parameter(ValueFromPipeline)]
        [Microsoft.SqlServer.Management.Smo.AvailabilityReplica[]]$InputObject,
        [switch]$EnableException
    )
    process {
        $ags = Get-DbaAvailabilityGroup -SqlInstance $SqlInstance -SqlCredential $SqlCredential -AvailabilityGroup $AvailabilityGroup
        
        foreach ($replica in $InputObject) {
            foreach ($ag in $ags) {
                if ($Pscmdlet.ShouldProcess("$instance", "Adding replica to $ag")) {
                    try {
                        $ag.AvailabilityReplicas.Add($replica)
                    }
                    catch {
                        Stop-Function -Message "Failure" -ErrorRecord $_ -Continue
                    }
                }
            }
        }
    }
}