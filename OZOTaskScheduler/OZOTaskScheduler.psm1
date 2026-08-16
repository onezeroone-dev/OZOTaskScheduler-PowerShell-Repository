Class OZOScheduledTask {
    # PROPERTIES: Booleans
    Hidden [Boolean]$taskScheduled = $false
    Hidden [Boolean]$taskAtReboot  = $false
    Hidden [Boolean]$taskAtLogon   = $false
    # PROPERTIES: Int32s
    Hidden [Int32]$taskRandomDelayMax = 0
    # PROPERTIES: Microsoft.Management.Infrastructure.CimInstance Lists
    Hidden [System.Collections.Generic.List[Microsoft.Management.Infrastructure.CimInstance]]$taskTriggers = @()
    # PROPERTIES: String Lists
    Hidden [System.Collections.Generic.List[String]]$taskWeekdays = @()
    # PROPERTIES: PSCustomObjects
    Hidden [PSCustomObject]$taskSchedules = @()
    # PROPERTIES: Strings
    Hidden [String]$taskName         = $null
    Hidden [String]$taskScript       = $null
    Hidden [String]$taskScriptParams = $null
    Hidden [String]$taskDir          = $null
    Hidden [String]$taskUser         = $null
    # METHODS: Constructor method - New and Update overload
    OZOScheduledTask($TaskName,$TaskScript,$TaskScriptParams,$TaskDir,$TaskScheduled,$TaskSchedules,$TaskUser,$TaskAtReboot,$TaskAtLogon) {
        # Set properties
        $this.taskName           = $TaskName
        $this.taskScript         = $TaskScript
        $this.taskScriptParams   = $TaskScriptParams
        $this.taskDir            = $TaskDir
        $this.taskScheduled      = $TaskScheduled
        $this.taskAtReboot       = $TaskAtReboot
        $this.taskAtLogon        = $TaskAtLogon
        $this.taskUser           = $TaskUser
        $this.taskWeekdays       = @("Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday")
        $this.taskRandomDelayMax = 3600
        # Determine if the configuration and environment validate
        If (($this.ValidateConfiguration($TaskSchedules) -And $this.ValidateEnvironment()) -eq $true) {
            # Determine if the task exists
            If ($this.TaskExists() -eq $true) {
                # Task exists; remove and recreate
                $this.RemoveTask()
                $this.AddTask()
            } Else {
                # Task does not exist; create
                $this.AddTask()
            }
        } Else {
            # Configuration or environment does not validate
            Write-OZOProvider -Message "The configuration or environment for the scheduled task does not validate. Please check the configuration and environment and try again." -Level "Error"
        }
    }
    # METHODS: Constructor method - Remove overload
    OZOScheduledTask($TaskName) {
        # Set properties
        $this.taskName = $TaskName
        # Determine if the operator is a local administrator
        If (Test-OZOLocalAdministrator -eq $true) {
            # Call RemoveTask to remove the task
            $this.RemoveTask()
        } Else {
            Write-OZOProvider -Message "Only local administrators can remove scheduled tasks." -Level "Error"
        }
    }
    # METHODS: Configuration validation method
    Hidden [Boolean] ValidateConfiguration($TaskSchedules) {
        # Control variable
        [Boolean] $Return = $true
        # Determine if at least one trigger has been defined
        If (($this.taskScheduled -And $this.taskAtReboot -And $this.taskAtLogon) -eq $false) {
            # No triggers defined
            Write-OZOProvider -Message "At least one trigger must be defined for the scheduled task. Please specify a trigger and try again." -Level "Error"
            $Return = $false
        }
        # Determine if TaskStartTime is not null and can be converted to a DateTime
        If ($null -ne $this.taskStartTime -And [Boolean]($this.taskStartTime -As [DateTime]) -eq $false) {
            # TaskStartTime is not null and cannot be converted to a DateTime
            Write-OZOProvider -Message "The TaskStartTime parameter must be a valid time in the HH:MM AM/PM format. Please specify a valid time and try again." -Level "Error"
            $Return = $false
        }
        # Determine if TaskSchedules can be converted from JSON
        If ($null -ne $TaskSchedules -And [Boolean]($TaskSchedules | ConvertFrom-Json -ErrorAction SilentlyContinue) -eq $true) {
            # TaskSchedules can be converted from JSON
            $this.taskSchedules = $TaskSchedules | ConvertFrom-Json | Select-Object -Unique
            # Determine if each schedule has a valid Weekday, StartTime, and RandomDelay
            ForEach ($taskSchedule in $this.taskSchedules) {
                # Determine if Weekday is valid
                If ($this.taskWeekdays -NotContains $taskSchedule.Weekday) {
                    # Weekday is not valid
                    Write-OZOProvider -Message ("The Weekday parameter for the scheduled task must be one of the following: " + ($this.taskWeekdays -join ", ") + ". Please specify a valid weekday and try again.") -Level "Error"
                    $Return = $false
                }
                # Determine if StartTime can be converted to a DateTime
                If ([Boolean]($taskSchedule.StartTime -As [DateTime]) -eq $false) {
                    # StartTime cannot be converted to a DateTime
                    Write-OZOProvider -Message ("The StartTime parameter for the scheduled task must be a valid time in the HH:MM AM/PM format. Please specify a valid time and try again.") -Level "Error"
                    $Return = $false
                }
                # Determine if RandomDelay is within the valid range
                If ($taskSchedule.RandomDelay -lt 0 -Or $taskSchedule.RandomDelay -gt $this.taskRandomDelayMax) {
                    # RandomDelay is not within the valid range
                    Write-OZOProvider -Message ("The RandomDelay parameter for the scheduled task must be between 0 and " + $this.taskRandomDelayMax + " seconds. Please specify a valid random delay and try again.") -Level "Error"
                    $Return = $false
                }
            }
        } Else {
            # TaskSchedules cannot be converted from JSON
            Write-OZOProvider -Message "The TaskSchedules parameter must be a valid JSON string. Please specify a valid JSON string and try again." -Level "Error"
            $Return = $false
        }
        # Return
        Return $Return
    }
    # METHODS: Environment validation method
    Hidden [Boolean] ValidateEnvironment() {
        # Control variable
        [Boolean] $Return = $true
        # Determine if the operator is a local administrator
        If (Test-OZOLocalAdministrator -eq $false) {
            # Operator is not a local administrator; set return
            $Return = $false
        }
        # Determine if TaskDir is null; if so, set to the directory containing TaskScript
        If ($null -eq $this.taskDir) {
            # TaskDir is null; set to the directory containing TaskScript
            $this.taskDir = Split-Path -Parent $this.taskScript
        }
        # Determine if TaskDir exists
        If ([Boolean](Test-Path -Path $this.taskDir -PathType Container) -eq $false) {
            # TaskDir does not exist; set return
            Write-OZOProvider -Message ("The specified TaskDir " + $this.taskDir + " does not exist. Please specify a valid directory and try again.") -Level "Error"
            $Return = $false
        }
        # Determine if TaskScript exists
        If ([Boolean](Test-Path -Path $this.taskScript -PathType Leaf) -eq $false) {
            # TaskScript does not exist; set return
            Write-OZOProvider -Message ("The specified TaskScript " + $this.taskScript + " does not exist. Please specify a valid script and try again.") -Level "Error"
            $Return = $false
        }
        # Return
        Return $Return
    }
    # METHODS: TaskExists method
    Hidden [Boolean] TaskExists() {
        # Control variable
        [Boolean] $Return = $true
        # Determine if the task exists
        If ([Boolean](Get-ScheduledTask -TaskName $this.taskName -ErrorAction SilentlyContinue) -eq $false) {
            # Task does not exist; set return
            $Return = $false
        }
        # Return
        Return $Return
    }
    # METHODS: AddTask method
    Hidden [Void] AddTask() {
        # Ensure the task is removed
        $this.RemoveTask()
        # Determine if TaskAtLogon is false and TaskSchedule is not null
        If ($this.taskAtLogon -eq $false -And $null -ne $this.taskSchedules) {
            # TaskSchedule is not null; iterate over the task schedules and create triggers
            ForEach ($taskSchedule in $this.taskSchedules) {
                # Create a weekly trigger for each schedule
                [Microsoft.Management.Infrastructure.CimInstance]$TaskTrigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek $taskSchedule.Weekday -At $taskSchedule.StartTime -RandomDelay $taskSchedule.RandomDelay
                # Add the trigger to the list of triggers
                $this.taskTriggers.Add($TaskTrigger)
            }
        }
        # Determine if TaskAtLogon is false and TaskAtReboot is set
        If ($this.taskAtLogon -eq $false -And $this.taskAtReboot -eq $true) {
            # TaskAtReboot is set; create a boot trigger
            [Microsoft.Management.Infrastructure.CimInstance]$TaskTrigger = New-ScheduledTaskTrigger -AtStartup
            # Add the trigger to the list of triggers
            $this.taskTriggers.Add($TaskTrigger)
        }
        # Determine if TaskAtLogon is set and TaskScheduled and TaskAtReboot are false
        If ($this.taskAtLogon -eq $true -And $this.taskScheduled -eq $false -And $this.taskAtReboot -eq $false) {
            # TaskAtLogon is set; create a logon trigger
            [Microsoft.Management.Infrastructure.CimInstance]$TaskTrigger = New-ScheduledTaskTrigger -AtLogOn
            # Add the trigger to the list of triggers
            $this.taskTriggers.Add($TaskTrigger)
        }
        # Define task settings
        [Microsoft.Management.Infrastructure.CimInstance]$TaskSettings = New-ScheduledTaskSettingsSet -RunOnlyIfNetworkAvailable -Compatibility Win8 -StartWhenAvailable
        # Determine if this script is a PowerShell script
        If ((Get-Item -Path $this.taskScript).Extension -eq ".ps1") {
            # Script is PowerShell; set executable and argument for PowerShell
            [Microsoft.Management.Infrastructure.CimInstance]$TaskAction = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument ('-ExecutionPolicy RemoteSigned -File "' + $this.taskScript + '" ' + $this.taskScriptParams) -WorkingDirectory $this.taskDir
        } Else {
            # Script is not PowerShell; set executable and argument for CMD
            [Microsoft.Management.Infrastructure.CimInstance]$TaskAction = New-ScheduledTaskAction -Execute "cmd.exe" -Argument ('/Q /C "' + $this.taskScript + '" ' + $this.taskScriptParams) -WorkingDirectory $this.taskDir
        }
        # Determine if TaskAtLogon is set
        If ($this.taskAtLogon -eq $true) {
            # TaskAtLogon is set; set parameters for Register-ScheduledTask without User parameter
            $taskParameters = @{
                TaskName = $this.taskName
                Trigger  = $this.taskTriggers
                Action   = $TaskAction
                Settings = $TaskSettings
            }
        } Else {
            # TaskAtLogon is not set; set parameters for Register-ScheduledTask with User parameter
            $taskParameters = @{
                TaskName = $this.taskName
                Trigger  = $this.taskTriggers
                User     = $this.taskUser
                Action   = $TaskAction
                Settings = $TaskSettings
            }
        }
        # Determine that the task does not exist and at least one trigger is defined
        If ($this.TaskExists() -eq $false -And $this.taskTriggers.Count -gt 0) {
            # The task does not exist and at least one trigger is defined; try to register the task
            Try {
                Register-ScheduledTask @taskParameters -ErrorAction Stop
                # Success
            } Catch {
                # Failure
                Write-OZOProvider -Message ("Failed to register the " + $this.taskName + " scheduled task with error " + $_ + ".") -Level "Error"
            }
        } Else {
            # Task exists or no triggers defined
            Write-OZOProvider -Message "The task exists or no triggers were defined." -Level "Error"
        }
    }
    # METHODS: RemoveTask method
    Hidden [Void] RemoveTask() {
        # Detemrine if the task exists
        If ($this.TaskExists() -eq $true) {
            # Task exists; try to disable and unregister
            Try {
                Disable-ScheduledTask -TaskName $this.taskName -ErrorAction Stop
                Unregister-ScheduledTask -TaskName $this.taskName -Confirm:$false -ErrorAction Stop
                # Success
            } Catch {
                # Failure
                Write-OZOProvider -Message ("Failed to remove the " + $this.taskName + "scheduled task with error " + $_ + ".") -Level "Error"
            }
        }
    }
}

Function Set-OZOScheduledTask {
    <#
        .SYNOPSIS
        See description.
        .DESCRIPTION
        Updates scheduled tasks for running scripts. Uses PowerShell to run .ps1 scripts and CMD to run everything else.
        .PARAMETER TaskName
        The name of the scheduled task.
        .PARAMETER TaskScript
        The absolute path to the script to run.
        .PARAMETER TaskScriptParams
        Parameters for the script.
        .PARAMETER TaskDir
        The directory where the task should be run. Defaults to the directory containing "TaskScript".
        .PARAMETER TaskScheduled
        Run the task on a scheduled day of the week. When this parameter is specified, "TaskSchedules" is required and "TaskAtReboot" is optional. Exclusive with "TaskAtLogon".
        .PARAMETER TaskSchedules
        A string containing a compressed JSON list of the schedules for the task. See https://github.com/onezeroone-dev/OZOTaskScheduler-PowerShell-Repository/blob/main/Documentation/Set-OZOScheduledTask.md for more information.
        .PARAMETER TaskAtReboot
        Run the task at system startup.
        .PARAMETER TaskAtLogon
        Run the task at user logon. Exclustive with "TaskScheduled".
        .EXAMPLE
        Set-OZOScheduledTask -TaskName "Update OZO PowerShell Module" -TaskScript "C:\Windows\Program Files\WindowsPowerShell\Scripts\ozo-update-ozo-powershell-module.ps1" -TaskSchedules '[{"Weekday":"Monday","StartTime":"8:00 AM","RandomDelay":0},{"Weekday":"Wednesday","StartTime":"8:00 AM","RandomDelay":0},{"Weekday":"Friday","StartTime":"8:00 AM","RandomDelay":0}]' -TaskAtReboot
        .EXAMPLE
        Set-OZOScheduledTask -TaskName "Update OZO PowerShell Module" -TaskScript "C:\Windows\Program Files\WindowsPowerShell\Scripts\ozo-register-ozo-powershell-repository.ps1" -TaskAtLogon
        .LINK
        https://github.com/onezeroone-dev/OZOTaskScheduler-PowerShell-Repository/blob/main/Documentation/Set-OZOScheduledTask.md
    #>
    [CmdLetBinding()]Param (
        [Parameter(Mandatory=$true,HelpMessage="The name of the scheduled task")][String]$TaskName,
        [Parameter(Mandatory=$true,HelpMessage="The absolute path to the script to run")][String]$TaskScript,
        [Parameter(Mandatory=$false,HelpMessage="Parameters for the script")][String]$TaskScriptParams = $null,
        [Parameter(Mandatory=$false,HelpMessage="The directory where the task should be run")][String]$TaskDir = $null,
        [Parameter(Mandatory=$false,HelpMessage="Run the task on a scheduled day of the week",ParameterSetName="Scheduled")][Switch]$TaskScheduled,
        [Parameter(Mandatory=$false,HelpMessage="A compressed JSON list of dictionaries representing the schedules for the task",ParameterSetName="Scheduled")][String]$TaskSchedules = $null,
        [Parameter(Mandatory=$false,HelpMessage="The user to run the task as",ParameterSetName="Scheduled")][String]$TaskUser = "SYSTEM",
        [Parameter(Mandatory=$false,HelpMessage="Run the task at reboot",ParameterSetName="Scheduled")][Switch]$TaskAtReboot,
        [Parameter(Mandatory=$false,HelpMessage="Run the task at logon",ParameterSetName="AtLogon")][Switch]$TaskAtLogon

    )
    # Create an OZOScheduledTask object
    [OZOScheduledTask]::new($TaskName,$TaskScript,$TaskScriptParams,$TaskDir,$TaskScheduled.IsPresent,$TaskSchedules,$TaskUser,$TaskAtReboot.IsPresent,$TaskAtLogon.IsPresent)
}

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
    # Create an OZOScheduledTask object
    [OZOScheduledTask]::new($TaskName)
}

Export-ModuleMember `
    Set-OZOScheduledTask,
    Remove-OZOScheduledTask

Set-Alias -Name New-OZOScheduledTask -Value Set-OZOScheduledTask -Option Global
