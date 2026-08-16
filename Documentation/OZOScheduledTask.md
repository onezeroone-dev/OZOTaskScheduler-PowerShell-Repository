## OZOScheduledTask
This class is part of the [OZOTaskScheduler PowerShell Module](https://github.com/onezeroone-dev/OZOTaskScheduler-PowerShell-Repository/blob/main/README.md).

## Usage
This class is used by the `New-OZOScheduledTask` and `Set-OZOScheduledTask` functions.

## Public Properties
None.

## Public Methods
None.

## Definition
### Associations
```
- $taskScheduled:Boolean   = $false
- $taskAtReboot:Boolean    = $true
- $taskAtLogon:Boolean     = $true
- $taskRandomDelayMask     = 0
- $taskTriggers:System.Collections.Generic.List[Microsoft.Management.Infrastructure.CimInstance] = @()
- $taskWeekdays:System.Collections.Generic.List[String] = @()
- $taskSchedules:PSCustomObject = @()
- $taskName:String         = $null
- $taskScript:String       = $null
- $taskScriptParams:String = $null
- $taskDir:String          = $null
- $taskUser:String         = $null
```
### Operations
```
+ OZOScheduledTask($TaskName:String,$TaskScript:String,$TaskScriptParams:String,$TaskDir:String,$TaskScheduled:Boolean,$TaskSchedules:String,$TaskUser:String,$TaskAtReboot:Boolean,$TaskAtLogon:Boolean):Void
+ OZOScheduledTask($TaskName:String):Void
- ValidateConfiguration():Boolean
- ValidateEnvironment():Boolean
- TaskExists():Boolean
- AddTask():Void
- RemoveTask():Void
```