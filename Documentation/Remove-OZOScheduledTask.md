# Remove-OZOScheduledTask
This function is part of the [OZOTaskScheduler PowerShell Module](../README.md).

## Description
Removes a task, if found.

## Prerequisites
This script requires _Administrator_ privileges.

## Syntax
```
Remove-OZOScheduledTask
    -TaskName <String>
```

## Parameters
|Parameter|Description|
|---------|-----------|
|`TaskName`|The name of the task to remove.|

## Examples
```powershell
Remove-OZOScheduledTask -TaskName "Update OZO PowerShell Module"
```
