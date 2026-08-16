## OZOScheduledTask
This class is part of the [OZOTaskScheduler PowerShell Module](https://github.com/onezeroone-dev/OZOTaskScheduler-PowerShell-Repository/blob/main/README.md).

## Description
Internal class that encapsulates the logic for creating, validating, and managing Windows Task Scheduler tasks. This class handles task validation, environment checks, and the complete lifecycle of scheduled task operations.

## Important Note
This is an **internal class** used by the module's public functions (`Set-OZOScheduledTask` and `Remove-OZOScheduledTask`). All properties and methods are hidden and not intended for direct use by module consumers.

## Constructors

**Full Constructor**
```
OZOScheduledTask($TaskName:String, $TaskScript:String, $TaskScriptParams:String, $TaskDir:String, $TaskScheduled:Boolean, $TaskSchedules:String, $TaskUser:String, $TaskAtReboot:Boolean, $TaskAtLogon:Boolean)
```
Creates a new instance for task creation operations.
- `$TaskName`: The name of the scheduled task
- `$TaskScript`: The absolute path to the script file to execute
- `$TaskScriptParams`: Optional parameters to pass to the script
- `$TaskDir`: Optional working directory for task execution
- `$TaskScheduled`: Whether the task should run on a schedule
- `$TaskSchedules`: JSON string containing schedule definitions
- `$TaskUser`: User account to run scheduled tasks as (currently SYSTEM only)
- `$TaskAtReboot`: Whether the task should run at system reboot
- `$TaskAtLogon`: Whether the task should run at user logon

**Minimal Constructor**
```
OZOScheduledTask($TaskName:String)
```
Creates a new instance for task removal operations.
- `$TaskName`: The name of the scheduled task to remove

## Properties
All properties are hidden and managed internally:
- `$taskScheduled`: Boolean indicating if task runs on a schedule
- `$taskAtReboot`: Boolean indicating if task runs at reboot
- `$taskAtLogon`: Boolean indicating if task runs at logon
- `$taskDisabled`: Boolean indicating if task is disabled
- `$taskRandomDelayMax`: Maximum random delay in seconds (0-3600)
- `$taskTriggers`: CIM instances representing task triggers
- `$taskWeekdays`: List of allowed weekdays for tasks
- `$taskSchedules`: Parsed schedule configuration
- `$taskName`: Name of the scheduled task
- `$taskScript`: Path to the script to execute
- `$taskScriptParams`: Parameters for the script
- `$taskCompatibility`: Task scheduler compatibility mode
- `$taskDir`: Working directory for task execution
- `$taskUser`: User account for task execution

## Methods

- **ValidateConfiguration()**
  Validates that the task configuration is valid. Checks that at least one trigger is defined and that TaskSchedules is valid JSON when TaskScheduled is true.
  - Returns: `Boolean` - `$true` if valid, `$false` otherwise

- **ValidateEnvironment()**
  Validates that the environment supports task creation. Checks for administrator privileges and required dependencies.
  - Returns: `Boolean` - `$true` if environment is valid, `$false` otherwise

- **TaskExists()**
  Determines whether the scheduled task already exists in Windows Task Scheduler.
  - Returns: `Boolean` - `$true` if task exists, `$false` otherwise

- **AddTask()**
  Creates or updates the scheduled task with the configured settings. If the task exists, it is disabled and recreated.
  - Returns: `Boolean` - `$true` if successful, `$false` otherwise

- **RemoveTask()**
  Disables and removes the scheduled task from Windows Task Scheduler.
  - Returns: `Boolean` - `$true` if successful, `$false` otherwise

## How It Works
1. Public function calls constructor with task parameters
2. `ValidateConfiguration()` validates task settings
3. `ValidateEnvironment()` checks system prerequisites
4. `TaskExists()` determines if the task already exists
5. `AddTask()` or `RemoveTask()` performs the actual operation

## See Also
- [Set-OZOScheduledTask](Set-OZOScheduledTask.md)
- [Remove-OZOScheduledTask](Remove-OZOScheduledTask.md)
