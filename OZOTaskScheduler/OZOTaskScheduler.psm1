#Requires -RunAsAdministrator

# CLASSES
# OZOSchedule class
Class OZOSchedule {
    # PROPERTIES: Booleans
    [Boolean] $Valid = $false
    # PROPERTIES: Int32s
    [Int32] $RandomDelay    = 0
    [Int32] $RandomDelayMax = 3600
    # PROPERTIES: Strings
    [String] $StartTime = $null
    [String] $WeekDay   = $null
    # PROPERTIES: String Lists
    Hidden [System.Collections.Generic.List[String]] $Weekdays = @("Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday")
    # METHODS: Constructor method
    OZOSchedule($Schedule) {
        # Set properties
        $this.RandomDelay = $Schedule.RandomDelay
        $this.WeekDay     = $Schedule.WeekDay
        $this.StartTime   = $Schedule.StartTime
        # Call validates to set valid
        $this.Valid = $this.Validates()
    }
    # METHODS: Validates method
    [Boolean] Validates() {
        # Control variable
        [Boolean] $Return = $true
        # Determine if RandomDelay is outside of range
        If ($this.RandomDelay -lt 0 -Or $this.RandomDelay -gt $this.RandomDelayMax) {
            # RandomDelay is outside of range
            $Return = $false
        }
        # Determine if StartTime cannot be expressed as a DateTime
        If ([Boolean]($this.StartTime -As [DateTime]) -eq $false) {
            # StartTime cannot be expressed as a DateTime
            $Return = $false
        }
        # Determine if WeekDay is not found in WeekDays
        If ($this.WeekDays -NotContains $this.WeekDay) {
            # WeekDay is not found in WeekDays
            $Return = $false
        }
        # Return
        return $Return
    }
}
# OZOTask class
Class OZOTask {
    # PROPERTIES: Booleans
    [Boolean] $Disabled  = $false
    [Boolean] $Scheduled = $false
    [Boolean] $AtReboot  = $false
    [Boolean] $AtLogon   = $false
    # PROPERTIES: PSCustomObjects
    Hidden [PSCustomObject] $ozoLogger = $null
    # PROPERTIES: PSCustomObject Lists
    [System.Collections.Generic.List[PSCustomObject]] $Schedules = @()
    # PROPERTIES: Strings
    [String] $Name          = $null
    [String] $Script        = $null
    [String] $Parameters    = $null
    [String] $Compatibility = $null
    [String] $Directory     = $null
    [String] $User          = $null
    # PROPERTIES: String Lists
    Hidden [System.Collections.Generic.List[String]] $Compatibilities = @("At","V1","Vista","Win7","Win8")
    # METHODS: Constructor method - Disable, Enable, Export, Get, Remove
    OZOTask([String]$Name) {
        # Set Properties
        $this.Name = $Name
        # Create a logger object
        $this.ozoLogger = (New-OZOLogger)
        # Determine if task exists
        If ($this.Exists() -eq $true) {
            # Task exists; populate from existing task
            $this.GetExistingTask()
        }
    }
    # METHODS: Constructor method - full
    OZOTask([String]$Name,[String]$Script,[String]$Parameters,[String]$Compatibility,[String]$Directory,[String]$User,[Boolean]$Disabled,[Boolean]$Scheduled,[System.Collections.Generic.List[PSCustomObject]]$Schedules,[Boolean]$AtReboot,[Boolean]$AtLogon) {
        # Set Properties
        $this.Name          = $Name
        $this.Script        = $Script
        $this.Parameters    = $Parameters
        $this.Compatibility = $Compatibility
        $this.Directory     = $Directory
        $this.User          = $User
        $this.Disabled      = $Disabled
        $this.Scheduled     = $Scheduled
        $this.Schedules     = $Schedules
        $this.AtReboot      = $AtReboot
        $this.AtLogon       = $AtLogon
        # Create a logger object
        $this.ozoLogger = (New-OZOLogger)
        # Iterate over schedules
        ForEach ($Schedule in $Schedules) {
            # Instantiate an OZOSchedule object and add it to the schedules list
            $this.Schedules.Add(([OZOSchedule]::new($Schedule)))
        }
    }
    # METHODS: Validation method
    [Boolean] Validates() {
        # Control variable
        [Boolean] $Return = $true
        # Determine if the Name property is null or empty
        If ([String]::IsNullOrEmpty($this.Name) -eq $true) {
            # Name is null or empty
            $this.ozoLogger.Write("Missing value for Name.","Error")
            $Return = $false
        } Else {
            # Determine if the Script property is null or empty
            If ([String]::IsNullOrEmpty($this.Script) -eq $true) {
                # Compatibility is null or empty
                $this.ozoLogger.Write(($this.Name + " Script value is missing."),"Error")
                $Return = $false
            } Else {
                # Determine if script exists
                If ([Boolean](Test-Path -Path $this.Script) -eq $true) {
                    # Determine if Directory is null or empty
                    If ([String]::IsNullOrEmpty($this.Directory)) {
                        # Directory is null or empty; set to parent of script
                        $this.Directory = (Split-Path -Path $this.Script -Parent)
                    }
                } Else {
                    # Script does not exist
                    $this.ozoLogger.Write(($this.Name + " script does not exist."),"Error")
                    $Return = $false
                }
            }
            # Determine if Compatibility is not found in Compatibilities
            If ($this.Compatibilities -NotContains $this.Compatibility) {
                # Compatibility is not found in Compatibilities
                $this.Compatibility = "Win8"
            }
            # Determine if Directory is null or empty
            If ([String]::IsNullOrEmpty($this.Directory)) {
                # Directory is null or empty
                $this.Directory = (Split-Path -Path $this.Script -Parent)
            }
        }
        # Determine if Scheduled is set and there are no schedules
        If ($this.Scheduled -eq $true -And ($this.Schedules | Where-Object {$_.Valid -eq $true}).Count -eq 0) {
            # Scheduled is set and there are no schedules
            $this.ozoLogger.Write(($this.Name + "Scheduled is enabled but no valid schedules were found."),"Error")
            $Return = $false
        }
        # Return
        return $Return
    }
    # METHODS: TaskExists method
    [Boolean] Exists() {
        # Control variable
        [Boolean] $Return = $true
        # Determine if the task exists
        If ([Boolean](Get-ScheduledTask -TaskName $this.Name -ErrorAction SilentlyContinue) -eq $false) {
            # Task does not exist; set return
            $Return = $false
        }
        # Return
        Return $Return
    }
    # METHODS: Populate from existing task method
    Hidden [Void] GetExistingTask() {

    }
    # METHODS: AddTask method
    [Void] AddTask() {
        # Local variables
        [System.Collections.Generic.List[Microsoft.Management.Infrastructure.CimInstance]] $Triggers = @()
        # Determine if the task does not exist and is valid
        If ($this.Exists() -eq $false -And $this.Validates() -eq $true) {
            # Determine if AtLogon is false and Scheduled is true and at least one schedule is valid
            If ($this.AtLogon -eq $false -And $this.Scheduled -eq $true -And ($this.Schedules | Where-Object {$_.Valid -eq $true}).Count -gt 0) {
                # AtLogon is false, Schedules is not null, and there is at least one valid schedule; iterate over the valid schedules and create triggers
                ForEach ($Schedule in ($this.Schedules | Where-Object {$_.Valid -eq $true})) {
                    # Create a weekly trigger for each schedule and add the trigger to the list of triggers
                    $Triggers.Add((New-ScheduledTaskTrigger -Weekly -DaysOfWeek $Schedule.Weekday -At $Schedule.StartTime -RandomDelay $Schedule.RandomDelay))
                }
            }
            # Determine if AtLogon is false and AtReboot is true
            If ($this.AtLogon -eq $false -And $this.AtReboot -eq $true) {
                # AtLogon is false and AtReboot is true; create a boot trigger and it to the list of triggers
                $Triggers.Add((New-ScheduledTaskTrigger -AtStartup))
            }
            # Determine if AtLogon is set true Scheduled is false and AtReboot is false
            If ($this.AtLogon -eq $true -And $this.Scheduled -eq $false -And $this.AtReboot -eq $false) {
                # AtLogon is true, Scheduled is false, and AtReboot is false; create a logon trigger and a it to the list of triggers
                $Triggers.Add((New-ScheduledTaskTrigger -AtLogOn))
            }
            # Determine if Disabled is set
            If ($this.Disabled -eq $true) {
                # Disabled is set; set parameters for New-ScheduledTaskSettingsSet with the Disabled parameter
                $settingsParameters = @{
                    RunOnlyIfNetworkAvailable = $true
                    Compatibility             = $this.Compatibility
                    StartWhenAvailable        = $true
                    Disable                   = $true
                }
            } Else {
                # Disabled is not set; set parameters for New-ScheduledTaskSettingsSet without the Disabled parameter
                $settingsParameters = @{
                    RunOnlyIfNetworkAvailable = $true
                    Compatibility             = $this.Compatibility
                    StartWhenAvailable        = $true
                }
            }
            # Determine if this script is a PowerShell script
            If ((Get-Item -Path $this.Script).Extension -eq ".ps1") {
                # Script is PowerShell; set paramters for New-ScheduledTaskAction with PowerShell executable and arguments
                $actionParameters = @{
                    Execute = 'powershell.exe'
                    Argument = ('-NoProfile -NonInteractive -WindowStyle Hidden -ExecutionPolicy RemoteSigned  -File "' + $this.Script + '" ' + $this.Parameters)
                    WorkingDirectory = $this.Directory
                }
            } Else {
                # Script is not PowerShell; set executable and argument for CMD
                $actionParameters = @{
                    Execute = "cmd.exe"
                    Argument = ('/Q /C "' + $this.Script + '" ' + $this.Parameters)
                    WorkingDirectory = $this.Directory
                }
            }
            # Determine if AtLogon is set
            If ($this.AtLogon -eq $true) {
                # AtLogon is set; set parameters for Register-ScheduledTask without User parameter
                $scheduledTaskParameters = @{
                    TaskName = $this.Name
                    Action   = (New-ScheduledTaskAction @actionParameters)
                    Trigger  = $Triggers
                    Settings = (New-ScheduledTaskSettingsSet @settingsParameters)
                }
            } Else {
                # AtLogon is not set; set parameters for Register-ScheduledTask with User parameter
                $scheduledTaskParameters = @{
                    TaskName = $this.Name
                    User     = $this.User
                    Action   = (New-ScheduledTaskAction @actionParameters)
                    Trigger  = $Triggers
                    Settings = (New-ScheduledTaskSettingsSet @settingsParameters)
                }
            }
            # Determine that at least one trigger is defined
            If ($Triggers.Count -gt 0) {
                # At least one trigger is defined; try to register the task
                Try {
                    Register-ScheduledTask @scheduledTaskParameters -ErrorAction Stop
                    # Success
                } Catch {
                    # Failure
                    $this.ozoLogger.Write(("Failed to register the " + $this.Name + " task with error " + $_ + "."), "Error")
                }
            } Else {
                # Task exists or no triggers defined
                $this.ozoLogger.Write("No triggers were defined.", "Error")
            }
        }
    }
    # METHODS: EnableTask method
    [Void] EnableTask() {
        # Determine if task exists
        If ($this.Exists() -eq $true) {
            # Task exists; try to enable it
            Try {
                Enable-ScheduledTask -TaskName $this.Name -ErrorAction Stop
                # Success
            } Catch {
                # Failure
                $this.ozoLogger.Write(("Failed to enable the " + $this.Name + " task with error " + $_ + "."),"Error")
            }
        }
    }
    # METHODS: DisableTask method
    [Void] DisableTask() {
        # Detemrine if the task exists
        If ($this.Exists() -eq $true) {
            # Task exists; try to disable
            Try {
                Disable-ScheduledTask -TaskName $this.Name -ErrorAction Stop
                # Success
            } Catch {
                # Failure
                $this.ozoLogger.Write(("Failed to disable the " + $this.Name + " task with error " + $_ + "."), "Error")
            }
        }
    }
    # METHODS: RemoveTask method
    [Void] RemoveTask() {
        # Detemrine if the task exists
        If ($this.Exists() -eq $true) {
            # Task exists; call disable task to disable
            $this.DisableTask()
            # Try to unregister
            Try {
                Unregister-ScheduledTask -TaskName $this.Name -Confirm:$false -ErrorAction Stop
                # Success
            } Catch {
                # Failure
                $this.ozoLogger.Write(("Failed to remove the " + $this.Name + " task with error " + $_ + "."), "Error")
            }
        }
    }
    # METHODS: UpdateTask method
    [Void] UpdateTask() {
        # Call RemoveTask to disable and remove the task
        $this.RemoveTask()
        # Detemine if the task does not exist
        If ($this.Exists() -eq $false) {
            # Call AddTask to add the task
            $this.AddTask()
        }
    }

}
# OZOScheduledTask class
Class OZOJsonTask {
    # PROPERTIES: Hidden PSCustomObjects
    Hidden [PSCustomObject] $Json      = $null
    Hidden [PSCustomObject] $ozoLogger = $null
    # PROPERTIES: PSCustomObjects
    [OZOTask] $Task = $null
    # METHODS: Constructor method
    OZOJsonTask([String]$JsonFile,[String]$JsonString) {
        # Create an OZOLogger object
        $this.ozoLogger = (New-OZOLogger)
        # Determine if the configuration and environment validate
        If (($this.ValidateConfiguration($JsonFile,$JsonString) -And $this.ValidateEnvironment()) -eq $true) {
            # Determine if JSON is not null
            If ($null -ne $this.Json) {
                # Instantiate an OZOTask object for this Task
                $this.Task = [OZOTask]::new(
                    $this.Json.Name,
                    $this.Json.Script,
                    $this.Json.Parameters,
                    $this.Json.Compatibility,
                    $this.Json.Directory,
                    "SYSTEM",
                    $this.Json.Disabled,
                    $this.Json.Scheduled,
                    $this.Json.Schedules,
                    $this.Json.AtReboot,
                    $this.Json.AtLogon
                )
            }
        }
    }
    # METHODS: Configuration validation method
    Hidden [Boolean] ValidateConfiguration($JsonFile,$JsonString) {
        # Control variable
        [Boolean] $Return = $true
        # Determine if both JsonFile and JsonString are provided
        If ([String]::IsNullOrEmpty($JsonFile) -eq $false -And [String]::IsNullOrEmpty($JsonString) -eq $false) {
            # Both JsonFile and JsonString are provided; log error and return false
            $this.ozoLogger.Write("Specify either JsonFile or JsonString, not both.", "Error")
            return $false
        }

        If ([String]::IsNullOrEmpty($JsonFile) -eq $true -And [String]::IsNullOrEmpty($JsonString) -eq $true) {
            $this.ozoLogger.Write("Either JsonFile or JsonString is required.", "Error")
            return $false
        }
        # Try to get the JSON content from the provided file or string
        Try {
            # Determine if JsonFile is not null or empty
            If ([String]::IsNullOrEmpty($JsonFile) -eq $false) {
                $this.Json = (Get-Content -Path $JsonFile -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop)
            # Elseif determine if JsonString is not null or empty
            } ElseIf ([String]::IsNullOrEmpty($JsonString) -eq $false) {
                $this.Json = ($JsonString | ConvertFrom-Json -ErrorAction Stop)
            }
            # Success
        } Catch {
            # Failure
            $this.ozoLogger.Write(("Failed to import JSON."), "Error")
            $this.Json = $null
            return $false
        }
        # Determine if JSON is null
        If ($null -eq $this.Json) {
            $this.ozoLogger.Write("JSON content is null or empty.", "Error")
            return $false
        }
        # Return
        Return $Return
    }
    # METHODS: Environment validation method
    Hidden [Boolean] ValidateEnvironment() {
        # Control variable
        [Boolean] $Return = $true
        # Return
        Return $Return
    }
}
# FUNCTIONS
# Disable-OZOScheduledTask function
Function Disable-OZOScheduledTask {
    <#
        .SYNOPSIS
        See description.
        .DESCRIPTION
        Disables a task, if found.
        .PARAMETER TaskName
        The name of the task to disable.
        .EXAMPLE
        Disable-OZOScheduledTask -TaskName "Update OZO PowerShell Module"
        .LINK
        https://github.com/onezeroone-dev/OZOTaskScheduler-PowerShell-Repository/blob/main/Documentation/Disable-OZOScheduledTask.md
    #>
    # Parameters
    [CmdLetBinding()] Param (
        [Parameter(Mandatory=$true,HelpMessage="The task to disable")][String]$TaskName
    )
    # Get the task
    [PSCustomObject] $ozoGetScheduledTask = (Get-OZOScheduledTask -TaskName $TaskName)
    # Determine if the task is not null
    if ($null -ne $ozoGetScheduledTask -And $null -ne $ozoGetScheduledTask.Task) {
        # Task is not null; call DisableTask to disable the task
        $ozoGetScheduledTask.DisableTask()
    }    
}
# Enable-OZOScheduledTask function
Function Enable-OZOScheduledTask {
    <#
        .SYNOPSIS
        See description.
        .DESCRIPTION
        Enable a task, if found.
        .PARAMETER TaskName
        The name of the task to enable.
        .EXAMPLE
        Enable-OZOScheduledTask -TaskName "Update OZO PowerShell Module"
        .LINK
        https://github.com/onezeroone-dev/OZOTaskScheduler-PowerShell-Repository/blob/main/Documentation/Enable-OZOScheduledTask.md
    #>
    # Parameters
    [CmdLetBinding()] Param (
        [Parameter(Mandatory=$true,HelpMessage="The task to enable")][String] $TaskName
    )
    # Get the task
    [PSCustomObject] $ozoGetScheduledTask = (Get-OZOScheduledTask -TaskName $TaskName)
    # Determine if the task is not null
    If ($null -ne $ozoGetScheduledTask -And $null -ne $ozoGetScheduledTask.Task) {
        # Task is not null; call EnableTask to enable the task
        $ozoGetScheduledTask.EnableTask()
    }
}
# Export-OZOScheduledTask function
Function Export-OZOScheduledTask {
    <#
        .SYNOPSIS
        See description.
        .DESCRIPTION
        Exports a task to JSON, if found.
        .PARAMETER OutFile
        The path for the output JSON file.
        .PARAMETER TaskName
        The name of the task to export.
        .EXAMPLE
        Export-OZOScheduledTask -TaskName "Update OZO PowerShell Module"
        .LINK
        https://github.com/onezeroone-dev/OZOTaskScheduler-PowerShell-Repository/blob/main/Documentation/Export-OZOScheduledTask.md
    #>
    # Parameters
    [CmdLetBinding()] Param (
        [Parameter(Mandatory=$true,HelpMessage="The path for the output JSON file")][String]$OutFile,
        [Parameter(Mandatory=$true,HelpMessage="The task to export")][String]$TaskName
    )
    # Get the task
    [PSCustomObject] $ozoGetScheduledTask = (Get-OZOScheduledTask -TaskName $TaskName)
    # Determine if the task is not null
    If ($null -ne $ozoGetScheduledTask -And $null -ne $ozoGetScheduledTask.Task) {
        # Task is not null; export all properties except Compatibilities as Json to a file
        $ozoGetScheduledTask | Select-Object -ExcludeProperty Compatibilities | ConvertTo-Json | Out-File -Path $OutFile
    }
}
# Get-OZOScheduledTask function
Function Get-OZOScheduledTask {
    <#
        .SYNOPSIS
        See description.
        .DESCRIPTION
        Get an object representing an existing task, if found.
        .PARAMETER TaskName
        The name of the task to get.
        .EXAMPLE
        $ozoGetScheduledTask = (Get-OZOScheduledTask -TaskName "Update OZO PowerShell Module")
        .LINK
        https://github.com/onezeroone-dev/OZOTaskScheduler-PowerShell-Repository/blob/main/Documentation/Get-OZOScheduledTask.md
    #>
    # Parameters
    [CmdLetBinding()] Param (
        [Parameter(Mandatory=$true,HelpMessage="The task to get")][String] $TaskName
    )
    # Return an OZOTask object
    $PSCmdlet.WriteObject(([OZOTask]::New($TaskName)))
}
# New-OZOScheduledTask function
Function New-OZOScheduledTask {
    <#
        .SYNOPSIS
        See description.
        .DESCRIPTION
        Creates a scheduled task. Uses powershell.exe to run .ps1 scripts and cmd.exe to run everything else.
        .PARAMETER JsonFile
        A JSON file that defines a task to schedule.
        .PARAMETER JsonString
        A compressed JSON string that defines a task to schedule.
        .EXAMPLE
        New-OZOScheduledTask -JsonFile "C:\Temp\scheduledTasks-example.json"
        .EXAMPLE
        New-OZOScheduledTask -JsonString '[{"Name":"Example Scheduled Task","Script":"C:\\Temp\\example.ps1","Parameters":"","Compatibility":"Win8","Directory":"C:\\Temp","Disabled":true,"Scheduled":true,"Schedules":["@{WeekDay=Monday; StartTime=8:00 AM; RandomDelay=0}","@{WeekDay=Wednesday; StartTime=8:00 AM; RandomDelay=0}","@{WeekDay=Friday; StartTime=8:00 AM; RandomDelay=0}"],"AtReboot":false,"AtLogon":false},{"Name":"Example Logon Task","Script":"C:\\Temp\\logonScript.ps1","Parameters":"","Compatibility":"Win8","Directory":"C:\\Temp","Disabled":true,"Scheduled":false,"Schedules":[],"AtReboot":false,"AtLogon":false}]'
        .LINK
        https://github.com/onezeroone-dev/OZOTaskScheduler-PowerShell-Repository/blob/main/Documentation/New-OZOScheduledTask.md
    #>
    [CmdLetBinding()]Param (
        [Parameter(Mandatory=$true,HelpMessage="A JSON file that defines a task to schedule",ParameterSetName="JsonFile")][String]$JsonFile,
        [Parameter(Mandatory=$true,HelpMessage="A compressed JSON string that defines a task to schedule",ParameterSetName="JsonString")][String]$JsonString

    )
    # Instantiate an OZOJsonTask object
    [PSCustomObject] $ozoJsonTask = ([OZOJsonTask]::new($JsonFile,$JsonString))
    # Determine if the task does not exist and validates
    If ($ozoJsonTask.Task.Exists() -eq $false -And $ozoJsonTask.Task.Validates() -eq $true) {
        # Task does not exiust and validates; add it
        $ozoJsonTask.Task.AddTask()
    }
}
# Set-OZOScheduledTask function
Function Set-OZOScheduledTask {
    <#
        .SYNOPSIS
        See description.
        .DESCRIPTION
        Updates a scheduled task. Uses PowerShell to run .ps1 scripts and CMD to run everything else.
        .PARAMETER JsonFile
        A JSON file that defines a task to schedule
        .PARAMETER JsonString
        A compressed JSON string that defines a task to schedule
        .EXAMPLE
        Set-OZOScheduledTask -JsonFile "C:\Temp\scheduledTasks-example.json"
        .EXAMPLE
        Set-OZOScheduledTask -JsonString '[{"Name":"Example Scheduled Task","Script":"C:\\Temp\\example.ps1","Parameters":"","Compatibility":"Win8","Directory":"C:\\Temp","Disabled":true,"Scheduled":true,"Schedules":["@{WeekDay=Monday; StartTime=8:00 AM; RandomDelay=0}","@{WeekDay=Wednesday; StartTime=8:00 AM; RandomDelay=0}","@{WeekDay=Friday; StartTime=8:00 AM; RandomDelay=0}"],"AtReboot":false,"AtLogon":false},{"Name":"Example Logon Task","Script":"C:\\Temp\\logonScript.ps1","Parameters":"","Compatibility":"Win8","Directory":"C:\\Temp","Disabled":true,"Scheduled":false,"Schedules":[],"AtReboot":false,"AtLogon":false}]'
        .LINK
        https://github.com/onezeroone-dev/OZOTaskScheduler-PowerShell-Repository/blob/main/Documentation/Set-OZOScheduledTask.md
    #>
    [CmdLetBinding()]Param (
        [Parameter(Mandatory=$true,HelpMessage="A JSON file that defines a task to schedule",ParameterSetName="JsonFile")][String]$JsonFile,
        [Parameter(Mandatory=$true,HelpMessage="A compressed JSON string that defines a task to schedule",ParameterSetName="JsonString")][String]$JsonString

    )
    # Instantiate an OZOJsonTask object
    [PSCustomObject] $ozoJsonTask = ([OZOJsonTask]::new($JsonFile,$JsonString))
    # Determine if the task exists and validates
    If ($ozoJsonTask.Task.Exists() -eq $true -And $ozoJsonTask.Task.Validates() -eq $true) {
        # Task exists and validates; update it
        $ozoJsonTask.Task.UpdateTask()
    }
}
# Remove-OZOScheduledTask function
Function Remove-OZOScheduledTask {
    <#
        .SYNOPSIS
        See description.
        .DESCRIPTION
        Disables and removes a scheduled task, if found.
        .PARAMETER TaskName
        The name of the task to remove.
        .EXAMPLE
        Remove-OZOScheduledTask -TaskName "Update OZO PowerShell Module"
        .LINK
        https://github.com/onezeroone-dev/OZOTaskScheduler-PowerShell-Repository/blob/main/Documentation/Remove-OZOScheduledTask.md
    #>
    # Parameters
    [CmdLetBinding()]Param (
        [Parameter(Mandatory=$true,HelpMessage="The name of the task to remove")][String]$TaskName
    )
    # Get the task
    [PSCustomObject] $ozoGetScheduledTask = (Get-OZOScheduledTask -TaskName $TaskName)
    # Determine if the task is not null
    If ($null -ne $ozoGetScheduledTask -And $null -ne $ozoGetScheduledTask.Task) {
        # Task is not null; call RemoveTask to disable and remove the task
        $ozoGetScheduledTask.RemoveTask()
    }
}

Export-ModuleMember -Function `
    Disable-OZOScheduledTask,
    Enable-OZOScheduledTask,
    Export-OZOScheduledTask,
    Get-OZOScheduledTask,
    New-OZOScheduledTask,
    Set-OZOScheduledTask,
    Remove-OZOScheduledTask

