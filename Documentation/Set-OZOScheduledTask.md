# Set-OZOScheduledTask
This function is part of the [OZOTaskScheduler PowerShell Module](https://github.com/onezeroone-dev/OZOTaskScheduler-PowerShell-Repository/blob/main/README.md).

## Description
Updates scheduled tasks for running scripts. Uses PowerShell to run `.ps1` scripts and CMD to run everything else. Tasks may be run at logon by the logged in user with the _TaskAtLogon_ parameter, *or* may be scheduled to run as the _SYSTEM_ user with the _TaskScheduled_ paramter. Scheduled tasks can have multiple schedules and can optionally run at reboot with the _TaskAtReboot_ parameter.

If the task already exists, it will be deleted and recreated.

## Prerequisites
This script requires _Administrator_ privileges.

## Syntax
This function supports two parameter sets: one for scheduled tasks and one for logon tasks.

```
Set-OZOScheduledTask
    -TaskName <String>
    -TaskScript <String>
    [-TaskScriptParams <String>]
    [-TaskDir <String>]
    [-TaskCompatibility <String>]
    [-TaskDisabled]
    -TaskScheduled
    -TaskSchedules <String>
    [-TaskAtReboot]

Set-OZOScheduledTask
    -TaskName <String>
    -TaskScript <String>
    [-TaskScriptParams <String>]
    [-TaskDir <String>]
    [-TaskCompatibility <String>]
    [-TaskDisabled]
    -TaskAtLogon
```

## Parameters
|Parameter|Description|
|---------|-----------|
|`TaskName`|The name of the scheduled task.|
|`TaskScript`|The absolute path to the script to run.|
|`TaskScriptParams`|Parameters for the script.|
|`TaskDir`|The directory where the script should be run. Defaults to the directory containing _TaskScript_.|
|`TaskCompatibility`|Compatibility mode for the task. Allowed values are At, V1, Vista, Win7, and Win8. Use Win8 for modern systems. Use earlier versions only if targeting legacy Windows versions. Defaults to _Win8_.|
|`TaskDisabled`|Whether the task is disabled on creation.|
|`TaskScheduled`|Run the task on a scheduled day of the week. When this parameter is specified, _TaskSchedules_ is required and _TaskAtReboot_ is optional. Exclusive with _TaskAtLogon_.|
|`TaskSchedules`|See _TaskSchedules Configuration_, below.|
|`TaskAtReboot`|Run the task at system startup.|
|`TaskAtLogon`|Run the task at user logon. Exclusive with _TaskScheduled_.|

## TaskSchedules Configuration
The _TaskSchedules_ parameter is a string containing a compressed JSON list of the schedules for the task. Each dictionary should contain a Weekday, a StartTime in HH:MM AM|PM format, and a RandomDelay in seconds. Example:
```json
[
    {
        "WeekDay":"Monday",
        "StartTime":"8:00 AM",
        "RandomDelay":0
    },
    {
        "WeekDay":"Wednesday",
        "StartTime":"8:00 AM",
        "RandomDelay":0
    },
    {
        "WeekDay":"Friday",
        "StartTime":"8:00 AM",
        "RandomDelay":0
    }
]
```
You can define your JSON in any text editor and save it as a file e.g., [`taskSchedules-example.json`](taskSchedules-example.json) and convert your file to a compressed JSON string with:
```powershell
(Get-Content .\taskSchedules-example.json -Raw | ConvertFrom-Json) | ConvertTo-Json -Compress
[{"WeekDay":"Monday","StartTime":"8:00 AM","RandomDelay":0},{"WeekDay":"Wednesday","StartTime":"8:00 AM","RandomDelay":0},{"WeekDay":"Friday","StartTime":"8:00 AM","RandomDelay":0}]
```
The resulting compressed JSON should be encapsulated in single quotes (') so PowerShell interprets it as one continuous string:
```powershell
'[{"WeekDay":"Monday","StartTime":"8:00 AM","RandomDelay":0},{"WeekDay":"Wednesday","StartTime":"8:00 AM","RandomDelay":0},{"WeekDay":"Friday","StartTime":"8:00 AM","RandomDelay":0}]'
```
This string can then be passed as the value for _TaskSchedules_.

## Examples
### Example 1
```powershell
Set-OZOScheduledTask -TaskName "Update OZO PowerShell Module" -TaskScript "C:\Windows\Program Files\WindowsPowerShell\Scripts\ozo-update-ozo-powershell-module.ps1" -TaskDir "C:\Windows\Program Files\WindowsPowerShell\Scripts" -TaskScheduled -TaskSchedules '[{"WeekDay":"Monday","StartTime":"8:00 AM","RandomDelay":0},{"WeekDay":"Wednesday","StartTime":"8:00 AM","RandomDelay":0},{"WeekDay":"Friday","StartTime":"8:00 AM","RandomDelay":0}]' -TaskAtReboot
```
### Example 2
```powershell
Set-OZOScheduledTask -TaskName "Register OZO PowerShell Repository" -TaskScript "C:\Windows\Program Files\WindowsPowerShell\Scripts\ozo-register-ozo-powershell-repository.ps1" -TaskAtLogon
```

## Outputs
None.

## See Also
* [`taskSchedules-example.json`](taskSchedules-example.json)
