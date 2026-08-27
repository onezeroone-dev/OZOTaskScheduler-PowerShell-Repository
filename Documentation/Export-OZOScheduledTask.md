# Export-OZOScheduledTask
This function is part of the [OZOTaskScheduler PowerShell Module](https://github.com/onezeroone-dev/OZOTaskScheduler-PowerShell-Repository/blob/main/README.md).

## Description
Exports a task to JSON, if found.

## Prerequisites
This script requires _Administrator_ privileges.

## Syntax
```
Export-OZOScheduledTask
    -OutFile  <String>
    -TaskName <String>
```

## Parameters
|Parameter|Description|
|---------|-----------|
|`OutFile`|The path for the output JSON file.|
|`TaskName`|The name of the task to export.|

## Examples
```powershell
Export-OZOScheduledTask -OutFile "C:\Temp\update-ozo-powershell-module-task.json" -TaskName "Update OZO PowerShell Module"
```
