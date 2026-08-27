# Disable-OZOScheduledTask
This function is part of the [OZOTaskScheduler PowerShell Module](https://github.com/onezeroone-dev/OZOTaskScheduler-PowerShell-Repository/blob/main/README.md).

## Description
Disables a task, if found.

## Prerequisites
This script requires _Administrator_ privileges.

## Syntax
```
Disable-OZOScheduledTask
    -TaskName <String>
```

## Parameters
|Parameter|Description|
|---------|-----------|
|`TaskName`|The name of the task to disable.|

## Examples
`````powershell
Disable-OZOScheduledTask -TaskName "Update OZO PowerShell Module"
`````
