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
- $taskScheduled:Boolean = $false
- $taskAtReboot:Boolean  = $true
- $taskAtLogon:Boolean   = $true
- $taskTriggers:System.Collections.Generic.List[Microsoft.Management.Infrastructure.CimInstance] = @()
- $taskName:String       = $null
- $taskScript            = $null
- $taskScriptParams      = $null
- $taskDir               = $null
- $taskWeekday           = $null
- $taskStartTime         = $null
- $taskUser              = $null
- $taskRandomDelay       = 0
```
### Operations
```
+ OZOScheduledTask($TaskName:String,$TaskScript:String,$TaskScriptParams:String,$TaskDir:String,$TaskScheduled:Boolean,$TaskWeekday:String,$TaskStartTime:String,$TaskRandomDelay:Int32,$TaskUser:String,$TaskAtReboot:Boolean,$TaskAtLogon:Boolean):Void
+ OZOScheduledTask($TaskName:String):Void
- ValidateConfiguration():Boolean
- ValidateEnvironment():Boolean
- TaskExists():Boolean
- AddTask():Void
- RemoveTask():Void
```