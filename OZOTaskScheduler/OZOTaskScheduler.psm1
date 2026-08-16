Class OZOScheduledTask {
    # PROPERTIES: Booleans
    [Boolean]$taskScheduled = $false
    [Boolean]$taskAtReboot  = $false
    [Boolean]$taskAtLogon   = $false
    # PROPERTIES: Lists
    [System.Collections.Generic.List[Microsoft.Management.Infrastructure.CimInstance]]$taskTriggers = @()
    # PROPERTIES: Strings
    [String]$taskName         = $null
    [String]$taskScript       = $null
    [String]$taskScriptParams = $null
    [String]$taskDir          = $null
    [String]$taskWeekday      = $null
    [String]$taskStartTime    = $null
    [String]$taskUser         = $null
    # PROPERTIES: Int32s
    [Int32]$taskRandomDelay = 0
    # METHODS: Constructor method - New and Update overload
    OZOScheduledTask($TaskName,$TaskScript,$TaskScriptParams,$TaskDir,$TaskScheduled,$TaskWeekday,$TaskStartTime,$TaskRandomDelay,$TaskUser,$TaskAtReboot,$TaskAtLogon) {
        # Set properties
        $this.taskName         = $TaskName
        $this.taskScript       = $TaskScript
        $this.taskScriptParams = $TaskScriptParams
        $this.taskDir          = $TaskDir
        $this.taskScheduled    = $TaskScheduled
        $this.taskWeekday      = $TaskWeekday
        $this.taskStartTime    = $TaskStartTime
        $this.taskRandomDelay  = $TaskRandomDelay
        $this.taskAtReboot     = $TaskAtReboot
        $this.taskAtLogon      = $TaskAtLogon
        $this.taskUser         = $TaskUser
        # Determine if the configuration and environment validate
        If (($this.ValidateConfiguration() -And $this.ValidateEnvironment()) -eq $true) {
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
        # Call RemoveTask to remove the task
        $this.RemoveTask()
    }
    # METHODS: Configuration validation method
    [Boolean] ValidateConfiguration() {
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
        # Return
        Return $Return
    }
    # METHODS: Environment validation method
    [Boolean] ValidateEnvironment() {
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
    [Boolean]TaskExists() {
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
    [Void]AddTask() {
        # Ensure the task is removed
        $this.RemoveTask()
        # Determine if TaskScheduled is set
        If ($this.taskScheduled -eq $true) {
            # TaskScheduled is set; create a weekly trigger
            [Microsoft.Management.Infrastructure.CimInstance]$TaskTrigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek $this.taskWeekday -At $this.taskStartTime -RandomDelay $this.taskRandomDelay
            # Add the trigger to the list of triggers
            $this.taskTriggers.Add($TaskTrigger)
        }
        # Determine if TaskAtReboot is set
        If ($this.taskAtReboot -eq $true) {
            # TaskAtReboot is set; create a boot trigger
            [Microsoft.Management.Infrastructure.CimInstance]$TaskTrigger = New-ScheduledTaskTrigger -AtStartup
            # Add the trigger to the list of triggers
            $this.taskTriggers.Add($TaskTrigger)
        }
        # Determine if TaskAtLogon is set
        If ($this.taskAtLogon -eq $true) {
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
        #>
        # Determine if the task exists
        If ($this.TaskExists() -eq $false) {
            # Task does not exist; determine if TaskAtLogon is set
            If ($this.taskAtLogon -eq $true) {
                # Set parameters for Register-ScheduledTask without User parameter
                $taskParameters = @{
                    TaskName = $this.taskName
                    Trigger  = $this.taskTriggers
                    Action   = $TaskAction
                    Settings = $TaskSettings
                }
            } Else {
                
                $taskParameters = @{
                    TaskName = $this.taskName
                    Trigger  = $this.taskTriggers
                    User     = $this.taskUser
                    Action   = $TaskAction
                    Settings = $TaskSettings
                }
            }
            # Try to create
            Try {
                # Create the task
                Register-ScheduledTask @taskParameters
                # Success
            } Catch {
                # Failure
                Write-OZOProvider -Message ("Failed to add the " + $this.taskName + " scheduled task with error " + $_ + ".") -Level "Error"
            }
        }
    }
    # METHODS: RemoveTask method
    [Void]RemoveTask($TaskName) {
        # Detemrine if the task exists
        If ($this.TaskExists($TaskName) -eq $true) {
            # Task exists; try to disable and unregister
            Try {
                Disable-ScheduledTask -TaskName $TaskName -ErrorAction Stop
                Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction Stop
                # Success
            } Catch {
                # Failure
                Write-OZOProvider -Message ("Failed to remove the " + $TaskName + "scheduled task with error " + $_ + ".") -Level "Error"
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
        Run the task on a scheduled day of the week. When this parameter is specified, "TaskWeekday" and "TaskStartTime" are required, and "TaskRandomDelay" and "TaskAtReboot" are optional. Exclusive with "TaskAtLogon".
        .PARAMETER TaskWeekday
        The day of the week to run the task. Allowed values are "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", and "Saturday".
        .PARAMETER TaskStartTime
        A string representing the time to run the task in the HH:MM AM/PM format e.g., "12:00 PM".
        .PARAMETER TaskRandomDelay
        The number of seconds to randomly delay the task. Allowed range is 0-3600 seconds. Defaults to 0 seconds.
        .PARAMETER TaskAtReboot
        Run the task at system startup.
        .PARAMETER TaskAtLogon
        Run the task at user logon.
        .EXAMPLE
        Set-OZOScheduledTask -TaskName "Update OZO PowerShell Module" -TaskScript "C:\Windows\Program Files\WindowsPowerShell\Scripts\ozo-update-ozo-powershell-module.ps1" -TaskScheduled -TaskWeekday "Monday" -TaskStartTime "8:00 AM" -TaskAtReboot
        .EXAMPLE
        Set-OZOScheduledTask -TaskName "Update OZO PowerShell Module" -TaskScript "C:\Windows\Program Files\WindowsPowerShell\Scripts\ozo-update-ozo-powershell-module.ps1" -TaskAtLogon
        .LINK
        https://github.com/onezeroone-dev/OZOTaskScheduler-PowerShell-Repository/blob/main/Documentation/Set-OZOScheduledTask.md
    #>
    [CmdLetBinding()]Param (
        [Parameter(Mandatory=$true,HelpMessage="The name of the scheduled task")][String]$TaskName,
        [Parameter(Mandatory=$true,HelpMessage="The absolute path to the script to run")][String]$TaskScript,
        [Parameter(Mandatory=$false,HelpMessage="Parameters for the script")][String]$TaskScriptParams = $null,
        [Parameter(Mandatory=$false,HelpMessage="The directory where the task should be run")][String]$TaskDir = $null,
        [Parameter(Mandatory=$false,HelpMessage="Run the task on a scheduled day of the week",ParameterSetName="Scheduled")][Switch]$TaskScheduled,
        [Parameter(Mandatory=$true,HelpMessage="The day of the week to run the task",ParameterSetName="Scheduled")][ValidateSet("Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday")][String]$TaskWeekday = $null,
        [Parameter(Mandatory=$true,HelpMessage="The time to start the task",ParameterSetName="Scheduled")][String]$TaskStartTime = $null,
        [Parameter(Mandatory=$false,HelpMessage="The random delay for the task",ParameterSetName="Scheduled")][ValidateRange(0,3600)][Int32]$TaskRandomDelay = 0,
        [Parameter(Mandatory=$false,HelpMessage="The user to run the task as")][String]$TaskUser = "SYSTEM",
        [Parameter(Mandatory=$false,HelpMessage="Run the task at reboot",ParameterSetName="Scheduled")][Switch]$TaskAtReboot,
        [Parameter(Mandatory=$false,HelpMessage="Run the task at logon",ParameterSetName="AtLogon")][Switch]$TaskAtLogon

    )
    # Create an OZOScheduledTask object
    [OZOScheduledTask]::new($TaskName,$TaskScript,$TaskScriptParams,$TaskDir,$TaskScheduled.IsPresent,$TaskWeekday,$TaskStartTime,$TaskRandomDelay,$TaskUser,$TaskAtReboot.IsPresent,$TaskAtLogon.IsPresent)
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
