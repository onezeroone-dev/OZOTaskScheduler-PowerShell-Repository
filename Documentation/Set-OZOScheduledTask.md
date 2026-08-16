# Set-OZOScheduledTask
This function is part of the [OZOTaskScheduler PowerShell Module](https://github.com/onezeroone-dev/OZOTaskScheduler-PowerShell-Repository/blob/main/README.md).

## Description
Updates scheduled tasks for running scripts. Uses PowerShell to run .ps1 scripts and CMD to run everything else.

## Syntax
```
Set-OZOScheduledTask
    -TaskName <String>
    -TaskScript <String>
    [-TaskScriptParams <String>]
    [-TaskPath <String>]
    -TaskScheduled
    -TaskWeekday <String>
    -TaskStartTime <String>
    -TaskRandomDelay <Int32>
    -TaskAtReboot

Set-OZOScheduledTask
    -TaskName <String>
    -TaskScript <String>
    [-TaskScriptParams <String>]
    [-TaskPath <String>]
    -TaskAtLogon
```

## Parameters
|Parameter|Description|
|---------|-----------|
|`TaskName`|The name of the scheduled task.|
|`TaskScript`|The absolute path to the script to run.|
|`TaskScriptParams`|Parameters for the script.|
|`TaskPath`|The directory where the script should be run. Defaults to the directory containing _TaskScript_.|
|`TaskScheduled`|Run the task on a scheduled day of the week. When this parameter is specified, _TaskWeekday_ and _TaskStartTime_ are required, and _TaskRandomDelay_ and _TaskAtReboot_ are optional. Exclusive with _TaskAtLogon_.|
|`TaskWeekday`|The day of the week to run the task. Allowed values are _Sunday_, _Monday_, _Tuesday_, _Wednesday_, _Thursday_, _Friday_, and _Saturday_.|
|`TaskStartTime`|A string representing the time to run the task in the HH:MM AM/PM format e.g., _12:00 PM_.|
|`TaskRandomDelay`|The number of seconds to randomly delay the task. Allowed range is 0-3600 seconds. Defaults to 0 seconds.|
|`TaskAtReboot`|Run the task at system startup.|
|`TaskAtLogon`|Run the task at user logon.|

## Examples
`````powershell

`````

## Outputs
None.