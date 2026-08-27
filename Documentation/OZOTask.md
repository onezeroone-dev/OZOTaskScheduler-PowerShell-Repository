## OZOTask
This class is part of the [OZOTaskScheduler PowerShell Module](../README.md).

## Description
Internal class that represents and manages a Windows scheduled task. This class validates task configuration, determines whether a task already exists, and performs common lifecycle operations such as creating, enabling, disabling, updating, and removing the task.

## Important Note
This is an **internal class** used by the module's public functions. It is not intended for direct use by module consumers.

## Constructors

**Minimal Constructor**
```
OZOTask($Name:String)
```
Creates a new instance for an existing task lookup or a task that will be managed by name.
- `$Name`: The name of the task

**Full Constructor**
```
OZOTask($Name:String, $Script:String, $Parameters:String, $Compatibility:String, $Directory:String, $User:String, $Disabled:Boolean, $Scheduled:Boolean, $Schedules:System.Collections.Generic.List[System.Collections.IEnumerable], $Once:Boolean, $OnceDateTime:PSCustomObject, $AtReboot:Boolean, $AtLogon:Boolean)
```
Creates a new instance for task creation or update operations.
- `$Name`: The name of the task
- `$Script`: The absolute path to the script or executable to run
- `$Parameters`: Optional parameters to pass to the script or program
- `$Compatibility`: Task scheduler compatibility mode
- `$Directory`: The working directory for the task
- `$User`: The account that the task should run as
- `$Disabled`: Indicates whether the task should be disabled when created
- `$Scheduled`: Indicates whether the task uses scheduled triggers
- `$Schedules`: The JSON schedule definitions to convert into `OZOSchedule` objects
- `$Once`: Indicates whether the task has a one-time date/time trigger
- `$OnceDateTime`: The one-time date/time trigger definition
- `$AtReboot`: Indicates whether the task should run at startup/reboot
- `$AtLogon`: Indicates whether the task should run at logon

## Properties
Public properties:
- `$Disabled`: Boolean indicating whether the task is disabled
- `$Scheduled`: Boolean indicating whether the task has scheduled triggers
- `$Once`: Boolean indicating whether the task has a one-time trigger
- `$AtReboot`: Boolean indicating whether the task runs at startup
- `$AtLogon`: Boolean indicating whether the task runs at logon
- `$OZOSchedules`: A list of converted `OZOSchedule` objects associated with the task
- `$Name`: Name of the task
- `$Script`: Path to the script or binary to run
- `$Parameters`: Parameters passed to the task action
- `$Compatibility`: Task scheduler compatibility mode
- `$Directory`: Working directory for the task action
- `$User`: Account associated with the task

`$ozoLogger`, `$Compatibilities`, and `$OnceDateTime` are hidden internal properties used for logging, compatibility validation, and one-time trigger configuration.

## Methods
- **Validates()**
  Validates the task definition. Checks the task name, script path, directory, compatibility, and schedule configuration.
  - Returns: `Boolean` - `$true` if valid, `$false` otherwise

- **Exists()**
  Determines whether the task already exists in Windows Task Scheduler.
  - Returns: `Boolean` - `$true` if the task exists, `$false` otherwise

- **GetExistingTask()**
  Hidden method used to populate task metadata from an existing Windows scheduled task.
  - Returns: `Void`

- **AddTask()**
  Creates the scheduled task using the configured weekly, one-time, startup, or logon triggers and execution action. When `.ps1` files are used, the module invokes `powershell.exe`; otherwise, it uses `cmd.exe`. `AtLogon` is ignored when `Scheduled`, `Once`, or `AtReboot` is enabled.
  - Returns: `Void`

- **EnableTask()**
  Enables the scheduled task if it exists.
  - Returns: `Void`

- **DisableTask()**
  Disables the scheduled task if it exists.
  - Returns: `Void`

- **RemoveTask()**
  Disables and removes the scheduled task if it exists.
  - Returns: `Void`

- **UpdateTask()**
  Removes the existing task and recreates it based on the current configuration.
  - Returns: `Void`

## How It Works
1. The constructor initializes the task metadata and logger
2. `Validates()` confirms the task definition is usable
3. `AddTask()` creates the task in Windows Task Scheduler
4. `EnableTask()`, `DisableTask()`, `RemoveTask()`, and `UpdateTask()` manage the task lifecycle

## See Also
- [New-OZOScheduledTask](New-OZOScheduledTask.md)
- [Set-OZOScheduledTask](Set-OZOScheduledTask.md)
- [OZOJsonTask](OZOJsonTask.md)
- [OZOSchedule](OZOSchedule.md)
