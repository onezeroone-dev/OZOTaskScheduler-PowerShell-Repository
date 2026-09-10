# New-OZOScheduledTask
This function is part of the [OZOTaskScheduler PowerShell Module](../README.md).

## Description
Creates a new scheduled task from a JSON file or a JSON string. The module uses `powershell.exe` to run `.ps1` scripts and `cmd.exe` to run other executable files.

> **Note:** Tasks created with `Scheduled`, `Once`, or `AtReboot` always run as the _SYSTEM_ account; there is currently no JSON option to specify a different account. If a task needs to run as a different user, create or update it with this module first, then change the task's principal (and supply credentials) directly in Task Scheduler or with `Set-ScheduledTask -User -Password`.

## Prerequisites
This script requires _Administrator_ privileges.

## Syntax
```
New-OZOScheduledTask
    -JsonFile <String>
    [-PassThru]

New-OZOScheduledTask
    -JsonString <String>
    [-PassThru]
```

## Parameters
|Parameter|Description|
|---------|-----------|
|`JsonFile`|The path to a JSON file that defines the task configuration.|
|`JsonString`|A compressed JSON string that defines the task configuration.|
|`PassThru`|Return the created task.|

## JSON Definition
See [Set-OZOScheduledTask](Set-OZOScheduledTask.md) for the JSON definition.

## Examples
```powershell
New-OZOScheduledTask -JsonFile "C:\Temp\OZOTaskScheduler-ScheduledTask-Example.json"
```

```powershell
New-OZOScheduledTask -JsonString '{"Name":"Example Scheduled Task","Script":"C:\\Temp\\OZOTaskScheduler-ScheduledTask-Example.ps1","Parameters":"","Directory":"C:\\Temp","Disabled":true,"Settings":{"AllowDemandStart":true,"AllowHardTerminate":true,"AllowStartOnRemoteAppSession":true,"Compatibility":"Win8","DeleteExpiredTaskAfter":"PT0S","DisallowStartIfOnBatteries":false,"DontStopIfGoingOnBatteries":true,"ExecutionTimeLimit":"PT0S","Hidden":false,"IdleSettings":{"StopOnIdleEnd":false,"RestartOnIdle":false},"MultipleInstances":"IgnoreNew","Priority":"Normal","RunOnlyIfNetworkAvailable":false,"WakeToRun":false},"AtLogon":false,"AtReboot":true,"Once":true,"OnceDateTime":{"DateTime":"2026-09-01T09:00:00","RandomDelay":0},"Scheduled":true,"Schedules":[{"WeekDay":"Monday","StartTime":"8:00 AM","RandomDelay":0},{"WeekDay":"Wednesday","StartTime":"8:00 AM","RandomDelay":0},{"WeekDay":"Friday","StartTime":"8:00 AM","RandomDelay":0}]}'
```

## See Also
- [Set-OZOScheduledTask](Set-OZOScheduledTask.md)
- [OZOJsonTask](OZOJsonTask.md)
- [OZOTask](OZOTask.md)
