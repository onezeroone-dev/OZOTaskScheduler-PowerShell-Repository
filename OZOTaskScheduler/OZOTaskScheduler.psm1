#Requires -RunAsAdministrator

# CLASSES
# OZOOnceDateTime class
Class OZOOnceDateTime {
    # PROPERTIES: Booleans
    [Boolean] $Valid = $false
    # PROPERTIES: Int32s
    [Int32] $RandomDelay    = 0
    [Int32] $RandomDelayMax = 3600
    # PROPERTIES: Strings
    [String] $DateTime = $null
    # METHODS: Constructor method
    OZOOnceDateTime($OnceDateTime) {
        # Set properties
        $this.RandomDelay = $OnceDateTime.RandomDelay
        $this.DateTime    = $OnceDateTime.DateTime
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
        # Determine if DateTime cannot be expressed as a DateTime
        If ([Boolean]($this.DateTime -As [DateTime]) -eq $false) {
            # DateTime cannot be expressed as a DateTime
            $Return = $false
        } Else {
            # DateTime can be expressed as a DateTime; determine if DateTime is in the past
            If ([DateTime]$this.DateTime -lt (Get-Date)) {
                # DateTime is in the past
                $Return = $false
            }
        }
        # Return
        return $Return
    }
}
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
    [Boolean] $Once      = $false
    [Boolean] $AtReboot  = $false
    [Boolean] $AtLogon   = $false
    # PROPERTIES: OZOOnceDateTimes
    Hidden [OZOOnceDateTime] $OnceDateTime = $null
    # PROPERTIES: PSCustomObjects
    Hidden [PSCustomObject] $ozoLogger = $null
    Hidden [PSCustomObject] $Settings  = $null
    # PROPERTIES: OZOSchedule Lists
    [System.Collections.Generic.List[OZOSchedule]] $OZOSchedules = @()
    # PROPERTIES: Strings
    [String] $Name       = $null
    [String] $Script     = $null
    [String] $Parameters = $null
    [String] $Directory  = $null
    [String] $User       = $null
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
    OZOTask([String]$Name,[String]$Script,[String]$Parameters,[String]$Directory,[Boolean]$Disabled,[PSCustomObject]$Settings,[String]$User,[Boolean]$AtLogon,[Boolean]$AtReboot,[Boolean]$Once,[PSCustomObject]$OnceDateTime,[Boolean]$Scheduled,[System.Collections.Generic.List[System.Collections.IEnumerable]]$Schedules) {
        # Set Properties
        $this.Name       = $Name
        $this.Script     = $Script
        $this.Parameters = $Parameters
        $this.Directory  = $Directory
        $this.Disabled   = $Disabled
        $this.Settings   = $Settings
        $this.User       = $User
        $this.AtLogon    = $AtLogon
        $this.AtReboot   = $AtReboot
        $this.Once       = $Once
        $this.Scheduled  = $Scheduled       
        # Create a logger object
        $this.ozoLogger = (New-OZOLogger)
        # Iterate over schedules
        ForEach ($Schedule in $Schedules) {
            # Instantiate an OZOSchedule object and add it to the schedules list
            $this.OZOSchedules.Add(([OZOSchedule]::new($Schedule)))
        }
        # Iterate over once date times
        If ($this.Once -eq $true) {
            # Set OnceDateTime
            $this.OnceDateTime = [OZOOnceDateTime]::new($OnceDateTime)
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
            # Determine if Scheduled is set and there are no valid schedules
            If ($this.Scheduled -eq $true -And ($this.OZOSchedules | Where-Object {$_.Valid -eq $true}).Count -eq 0) {
                # Scheduled is set and there are no valid schedules
                $this.ozoLogger.Write(($this.Name + "Scheduled is enabled but no valid schedules were found."),"Error")
                $Return = $false
            }
            # Determine if Once is true and OnceDateTime is null
            If ($this.Once -eq $true -And $null -eq $this.OnceDateTime) {
                # Once is true and OnceDateTime is null
                $this.ozoLogger.Write(($this.Name + "Once is enabled but OnceDateTime is null."),"Error")
                $Return = $false
            }
            # Determine if Once is true and OnceDateTime is not null and OnceDateTime is not valid
            If ($this.Once -eq $true -And $null -ne $this.OnceDateTime -And $this.OnceDateTime.Valid -eq $false) {
                # Once is true and OnceDateTime not null and OnceDateTime is not valid
                $this.ozoLogger.Write(($this.Name + "Once is enabled but OnceDateTime is not valid."),"Error")
                $Return = $false
            }
            # Determine if no triggers are set
            If ($this.AtLogon -eq $false -And $this.Scheduled -eq $false -And $this.Once -eq $false -And $this.AtReboot -eq $false) {
                # No triggers are set
                $this.ozoLogger.Write(($this.Name + "No triggers are set."),"Error")
                $Return = $false
            }
            # Determine if AtLogon is set and any other trigger is set
            If ($this.AtLogon -eq $true -And ($this.Scheduled -eq $true -Or $this.Once -eq $true -Or $this.AtReboot -eq $true)) {
                # AtLogon is set and any other trigger is set
                $this.ozoLogger.Write(($this.Name + "AtLogon is enabled but other triggers are also set. AtLogon will be ignored."),"Warning")
            }
            # Determine if Settings is null
            If ($null -eq $this.Settings) {
                # Settings is null; set to default
                $this.Settings = [PSCustomObject]@{
                    Compatibility = "Win8"
                }
            }
            # Determine if Compatibility is not found in Compatibilities
            If ($this.Compatibilities -NotContains $this.Settings.Compatibility) {
                # Compatibility is not found in Compatibilities
                $this.Settings.Compatibility = "Win8"
            }
            # Determine if Directory is null or empty
            If ([String]::IsNullOrEmpty($this.Directory)) {
                # Directory is null or empty
                $this.Directory = (Split-Path -Path $this.Script -Parent)
            }
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
        # Get the existing task definition
        Try {
            $ScheduledTask = Get-ScheduledTask -TaskName $this.Name -ErrorAction Stop
            # Success
        } Catch {
            # Failure
            $this.ozoLogger.Write(("Failed to get the " + $this.Name + " task with error " + $_ + "."), "Error")
            return
        }
        # Populate Disabled
        $this.Disabled = -Not [Boolean]$ScheduledTask.Settings.Enabled
        # Populate Settings
        $this.Settings = [PSCustomObject]@{
            Compatibility = [String]$ScheduledTask.Settings.Compatibility
        }
        # Populate User
        #$this.User = [String]$ScheduledTask.Principal.UserId
        # Populate Actions (including Directory, Script, and Parameters)
        $Action = $ScheduledTask.Actions | Select-Object -First 1
        If ($null -ne $Action) {
            $this.Directory = [String]$Action.WorkingDirectory
            If ($Action.Execute -match 'powershell\.exe$') {
                $ActionMatch = [Regex]::Match([String]$Action.Arguments, '-File\s+"(?<Script>[^"]+)"\s*(?<Parameters>.*)$')
                If ($ActionMatch.Success) {
                    $this.Script = $ActionMatch.Groups['Script'].Value
                    $this.Parameters = $ActionMatch.Groups['Parameters'].Value
                } Else {
                    $this.ozoLogger.Write(($this.Name + " uses an unsupported PowerShell action format."), "Warning")
                }
            } ElseIf ($Action.Execute -match 'cmd\.exe$') {
                $ActionMatch = [Regex]::Match([String]$Action.Arguments, '/Q\s+/C\s+"(?<Script>[^"]+)"\s*(?<Parameters>.*)$')
                If ($ActionMatch.Success) {
                    $this.Script = $ActionMatch.Groups['Script'].Value
                    $this.Parameters = $ActionMatch.Groups['Parameters'].Value
                } Else {
                    $this.ozoLogger.Write(($this.Name + " uses an unsupported CMD action format."), "Warning")
                }
            } Else {
                $this.ozoLogger.Write(($this.Name + " uses an unsupported action executable."), "Warning")
            }
        }
        # Reset trigger state before mapping supported Task Scheduler triggers
        $this.AtLogon = $false
        $this.AtReboot = $false
        $this.Once = $false
        $this.OnceDateTime = $null
        $this.Scheduled = $false
        $this.OZOSchedules.Clear()
        # Iterate over the triggers and map to properties
        ForEach ($Trigger in $ScheduledTask.Triggers) {
            # Set default RandomDelay to 0
            $RandomDelay = 0
            # Determine if the trigger has a RandomDelay property and it is not null or empty
            If ([String]::IsNullOrEmpty([String]$Trigger.RandomDelay) -eq $false) {
                # Trigger has a RandomDelay property and it is not null or empty; convert to seconds
                $RandomDelay = [Int32][System.Xml.XmlConvert]::ToTimeSpan([String]$Trigger.RandomDelay).TotalSeconds
            }
            # Switch on the trigger's CimClassName to map to properties
            Switch ($Trigger.CimClass.CimClassName) {
                'MSFT_TaskWeeklyTrigger' {
                    # Trigger is MSFT_TaskWeeklyTrigger; set Scheduled to true
                    $this.Scheduled = $true
                    # Determine the StartTime for the trigger
                    $StartTime = ([DateTime]$Trigger.StartBoundary).ToString("h:mm tt")
                    # Define a list of weekdays with their corresponding values for bitwise comparison
                    $Weekdays = @(
                        [PSCustomObject]@{ Name = "Sunday"; Value = 1 },
                        [PSCustomObject]@{ Name = "Monday"; Value = 2 },
                        [PSCustomObject]@{ Name = "Tuesday"; Value = 4 },
                        [PSCustomObject]@{ Name = "Wednesday"; Value = 8 },
                        [PSCustomObject]@{ Name = "Thursday"; Value = 16 },
                        [PSCustomObject]@{ Name = "Friday"; Value = 32 },
                        [PSCustomObject]@{ Name = "Saturday"; Value = 64 }
                    )
                    # Iterate on Weekdays
                    ForEach ($Weekday in $Weekdays) {
                        # Determine if the current weekday is included in the trigger's DaysOfWeek using bitwise AND
                        If (([Int32]$Trigger.DaysOfWeek -band $Weekday.Value) -ne 0) {
                            # Current weekday is included in the trigger's DaysOfWeek; create an OZOSchedule object and add it to the OZOSchedules list
                            $this.OZOSchedules.Add([OZOSchedule]::new([PSCustomObject]@{
                                WeekDay = $Weekday.Name
                                StartTime = $StartTime
                                RandomDelay = $RandomDelay
                            }))
                        }
                    }
                    # Break
                    break
                }
                'MSFT_TaskTimeTrigger' {
                    # Trigger is MSFT_TaskTimeTrigger; set Once to true
                    $this.Once = $true
                    # Create an OZOOnceDateTime object and set it to OnceDateTime
                    $this.OnceDateTime = [OZOOnceDateTime]::new([PSCustomObject]@{
                        DateTime = ([DateTime]$Trigger.StartBoundary).ToString("o")
                        RandomDelay = $RandomDelay
                    })
                    # Break
                    break
                }
                'MSFT_TaskBootTrigger' {
                    # Trigger is MSFT_TaskBootTrigger; set AtReboot to true
                    $this.AtReboot = $true
                    # Break
                    break
                }
                'MSFT_TaskLogonTrigger' {
                    # Trigger is MSFT_TaskLogonTrigger; set AtLogon to true
                    $this.AtLogon = $true
                    # Break
                    break
                }
                Default {
                    $this.ozoLogger.Write(($this.Name + " uses an unsupported trigger type: " + $Trigger.CimClass.CimClassName + "."), "Warning")
                    # Break
                    break
                }
            }
        }
    }
    # METHODS: AddTask method
    [Void] AddTask() {
        # Local variables
        [System.Collections.Generic.List[Microsoft.Management.Infrastructure.CimInstance]] $Triggers = @()
        $actionParameters = @{}
        $settingsParameters = @{}
        $scheduledTaskParameters = @{}
        # Determine if the task does not exist and is valid
        If ($this.Exists() -eq $false -And $this.Validates() -eq $true) {
            ## ACTION PARAMETERS
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
            ## SETTINGS PARAMETERS
            # Determine if Disabled is set
            If ($this.Disabled -eq $true) {
                # Disabled is set; set parameters for New-ScheduledTaskSettingsSet with the Disabled parameter
                $settingsParameters = @{
                    RunOnlyIfNetworkAvailable = $true
                    Compatibility             = $this.Settings.Compatibility
                    StartWhenAvailable        = $true
                    Disable                   = $true
                }
            } Else {
                # Disabled is not set; set parameters for New-ScheduledTaskSettingsSet without the Disabled parameter
                $settingsParameters = @{
                    RunOnlyIfNetworkAvailable = $true
                    Compatibility             = $this.Settings.Compatibility
                    StartWhenAvailable        = $true
                }
            }
            ## TRIGGERS AND SCHEDULED TASK PARAMETERS
            # Determine if at least one of Scheduled, Once, or AtReboot is true
            If ($this.Scheduled -eq $true -Or $this.Once -eq $true -Or $this.AtReboot -eq $true) {
                # AtLogon is false and one of Scheduled, Once, or AtReboot is true; determine if scheduled is true and at least one schedule is valid
                If ($this.Scheduled -eq $true -And ($this.OZOSchedules | Where-Object {$_.Valid -eq $true}).Count -gt 0) {
                    # Schedules is not null and there is at least one valid schedule; iterate over the valid schedules and create triggers
                    ForEach ($Schedule in ($this.OZOSchedules | Where-Object {$_.Valid -eq $true})) {
                        # Create a weekly trigger for each schedule and add the trigger to the list of triggers
                        $Triggers.Add((New-ScheduledTaskTrigger -Weekly -DaysOfWeek $Schedule.Weekday -At $Schedule.StartTime -RandomDelay (New-TimeSpan -Start [DateTime]$Schedule.StartTime -End ([DateTime]($Schedule.StartTime).AddSeconds($Schedule.RandomDelay)))))
                    }
                }
                # Determine Once is true and OnceDateTime is not null and is valid
                If ($this.Once -eq $true -And $null -ne $this.OnceDateTime -And $this.OnceDateTime.Valid -eq $true) {
                    # Once is true, and OnceDateTime is not null and is valid; create a one-time trigger and add it to the list of triggers
                    $Triggers.Add((New-ScheduledTaskTrigger -Once -At $this.OnceDateTime.DateTime -RandomDelay (New-TimeSpan -Start [DateTime]$this.OnceDateTime.DateTime -End ([DateTime]($this.OnceDateTime.DateTime).AddSeconds($this.OnceDateTime.RandomDelay)))))
                }
                # Determine AtReboot is true
                If ($this.AtLogon -eq $false -And $this.AtReboot -eq $true) {
                    # AtLogon is false and AtReboot is true; create a boot trigger and it to the list of triggers
                    $Triggers.Add((New-ScheduledTaskTrigger -AtStartup))
                }
                # Set scheduled task parameters for Register-ScheduledTask with User parameter
                $scheduledTaskParameters = @{
                    TaskName = $this.Name
                    User     = $this.User
                    Action   = (New-ScheduledTaskAction @actionParameters)
                    Trigger  = $Triggers
                    Settings = (New-ScheduledTaskSettingsSet @settingsParameters)
                }
            # ElseIf determine if AtLogon is true and all of Scheduled, Once, and AtReboot are false
            } ElseIf ($this.AtLogon -eq $true -And $this.Scheduled -eq $false -And $this.Once -eq $false -And $this.AtReboot -eq $false) {
                # AtLogon is true, Scheduled is false, and AtReboot is false; create a logon trigger and a it to the list of triggers
                $Triggers.Add((New-ScheduledTaskTrigger -AtLogOn))
                # Set scheduled task parameters for Register-ScheduledTask without User parameter
                $scheduledTaskParameters = @{
                    TaskName = $this.Name
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
                    $this.Json.Directory,
                    $this.Json.Disabled,
                    $this.Json.Settings,
                    "SYSTEM",
                    $this.Json.AtLogon,
                    $this.Json.AtReboot,
                    $this.Json.Once,
                    $this.Json.OnceDateTime,
                    $this.Json.Scheduled,
                    $this.Json.Schedules
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
        $ozoGetScheduledTask | Select-Object -Property Name,Script,Parameters,Directory,Disabled,Settings,AtLogon,AtReboot,Once,OnceDateTime,Scheduled,@{Name="Schedules";Expression={$_.OZOSchedules | Select-Object -Property Weekday,StartTime,RandomDelay}} | ConvertTo-Json | Out-File -Path $OutFile
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
        New-OZOScheduledTask -JsonFile "C:\Temp\OZOTaskScheduler-ScheduledTask-Example.json"
        .EXAMPLE
        New-OZOScheduledTask -JsonString '{"Name":"Example Scheduled Task","Script":"C:\\Temp\\OZOTaskScheduler-ScheduledTask-Example.json","Parameters":"","Directory":"C:\\Temp","Disabled":true,"Settings":{"Compatibility":"Win8"},"AtLogon":false,"AtReboot":true,"Once":true,"OnceDateTime":{"DateTime":"2026-09-01T09:00:00","RandomDelay":0},"Scheduled":true,"Schedules":[{"WeekDay":"Monday","StartTime":"8:00 AM","RandomDelay":0},{"WeekDay":"Wednesday","StartTime":"8:00 AM","RandomDelay":0},{"WeekDay":"Friday","StartTime":"8:00 AM","RandomDelay":0}]}'
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
    If ($null -ne $ozoJsonTask -And $null -ne $ozoJsonTask.Task -And $ozoJsonTask.Task.Exists() -eq $false -And $ozoJsonTask.Task.Validates() -eq $true) {
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
        Set-OZOScheduledTask -JsonFile "C:\Temp\OZOTaskScheduler-ScheduledTask-Example.json"
        .EXAMPLE
        Set-OZOScheduledTask -JsonString '{"Name":"Example Scheduled Task","Script":"C:\\Temp\\OZOTaskScheduler-ScheduledTask-Example.json","Parameters":"","Directory":"C:\\Temp","Disabled":true,"Settings":{"Compatibility":"Win8"},"AtLogon":false,"AtReboot":true,"Once":true,"OnceDateTime":{"DateTime":"2026-09-01T09:00:00","RandomDelay":0},"Scheduled":true,"Schedules":[{"WeekDay":"Monday","StartTime":"8:00 AM","RandomDelay":0},{"WeekDay":"Wednesday","StartTime":"8:00 AM","RandomDelay":0},{"WeekDay":"Friday","StartTime":"8:00 AM","RandomDelay":0}]}'
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
    If ($null -ne $ozoJsonTask -And $null -ne $ozoJsonTask.Task -And $ozoJsonTask.Task.Exists() -eq $true -And $ozoJsonTask.Task.Validates() -eq $true) {
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

