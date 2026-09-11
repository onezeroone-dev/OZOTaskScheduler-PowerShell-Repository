# Enable-OZOScheduledTask
This function is part of the [OZOTaskScheduler PowerShell Module](../README.md).

## Description
Enables a task, if found.

## Prerequisites
This script requires _Administrator_ privileges.

## Syntax
```
Enable-OZOScheduledTask
    -TaskName <String>
    [-PassThru]
```

## Parameters
|Parameter|Description|
|---------|-----------|
|`TaskName`|The name of the task to enable.|
|`PassThru`|Return the enabled task.|

## Example
```powershell
Enable-OZOScheduledTask -TaskName "Update OZO PowerShell Module"
```
