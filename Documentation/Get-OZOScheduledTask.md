# Get-OZOScheduledTask
This function is part of the [OZOTaskScheduler PowerShell Module](https://github.com/onezeroone-dev/OZOTaskScheduler-PowerShell-Repository/blob/main/README.md).

## Description
Get an object representing an existing task, if found.

## Prerequisites
This script requires _Administrator_ privileges.

## Syntax
```
Get-OZOScheduledTask
    -TaskName <String>
```

## Parameters
|Parameter|Description|
|---------|-----------|
|`TaskName`|The name of the task to get.|

## Examples
`````powershell
$ozoGetScheduledTask = (Get-OZOScheduledTask -TaskName "Update OZO PowerShell Module")
`````
