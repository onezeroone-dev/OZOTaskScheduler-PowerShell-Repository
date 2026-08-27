# New-OZOScheduledTask
This function is part of the [OZOTaskScheduler PowerShell Module](../README.md).

## Description
Creates a new scheduled task from a JSON file or a JSON string. The module uses `powershell.exe` to run `.ps1` scripts and `cmd.exe` to run other executable files.

## Prerequisites
This script requires _Administrator_ privileges.

## Syntax
```
New-OZOScheduledTask
    -JsonFile <String>

New-OZOScheduledTask
    -JsonString <String>
```

## Parameters
|Parameter|Description|
|---------|-----------|
|`JsonFile`|The path to a JSON file that defines the task configuration.|
|`JsonString`|A compressed JSON string that defines the task configuration.|

## Examples
```powershell
New-OZOScheduledTask -JsonFile "C:\Temp\OZOTaskScheduler-ScheduledTask-Example.json"
```

```powershell
New-OZOScheduledTask -JsonString '{"Name":"Example Scheduled Task","Script":"C:\\Temp\\example.ps1","Parameters":"","Compatibility":"Win8","Directory":"C:\\Temp","Disabled":true,"Scheduled":true,"Schedules":[{"WeekDay":"Monday","StartTime":"8:00 AM","RandomDelay":0},{"WeekDay":"Wednesday","StartTime":"8:00 AM","RandomDelay":0},{"WeekDay":"Friday","StartTime":"8:00 AM","RandomDelay":0}],"Once":false,"OnceDateTime":{},"AtReboot":false,"AtLogon":false}'
```

## See Also
- [Set-OZOScheduledTask](Set-OZOScheduledTask.md)
- [OZOJsonTask](OZOJsonTask.md)
- [OZOTask](OZOTask.md)
