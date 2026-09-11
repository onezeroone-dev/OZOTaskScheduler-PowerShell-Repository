# Set-OZOScheduledTask
This function is part of the [OZOTaskScheduler PowerShell Module](../README.md).

## Description
Updates an existing scheduled task. The module uses `powershell.exe` to run `.ps1` scripts and `cmd.exe` to run other executable files. Tasks may run at logon for the logged-in user with the `AtLogon` setting, or may run as the _SYSTEM_ account with `Scheduled`, `Once`, and `AtReboot` triggers. `Once` creates a single date/time trigger from `OnceDateTime`. `AtLogon` is ignored when `Scheduled`, `Once`, or `AtReboot` is enabled.

If the task already exists, it will be removed and recreated.

> **Note:** Tasks created with `Scheduled`, `Once`, or `AtReboot` always run as the _SYSTEM_ account; there is currently no JSON option to specify a different account. If a task needs to run as a different user, create or update it with this module first, then change the task's principal (and supply credentials) directly in Task Scheduler or with `Set-ScheduledTask -User -Password`.

## Prerequisites
This script requires _Administrator_ privileges.

## Syntax
This function supports two parameter sets: one for tasks defined in a JSON file and one for tasks defined as a compressed JSON string.

```
Set-OZOScheduledTask
    -JsonFile <string>
    [-PassThru]

Set-OZOScheduledTask
    -JsonString <String>
    [-PassThru]
```

## Parameters
|Parameter|Description|
|---------|-----------|
|`JsonFile`|The path to a JSON file that defines the task configuration.|
|`JsonString`|A compressed JSON string that defines the task configuration. See _Generating a Compressed JSON String_, below.|
|`PassThru`|Return the updated task.|

## JSON Definition
Tasks are expressed as a JSON dictionary. The following example shows a _Scheduled_ task with three schedule entries:
```json
{
    "Name":"Example Scheduled Task",
    "Script":"C:\\Temp\\OZOTaskScheduler-ScheduledTask-Example.ps1",
    "Parameters":"",
    "Directory":"C:\\Temp",
    "Disabled":true,
    "Settings":{
        "AllowDemandStart":true,
        "AllowHardTerminate":true,
        "AllowStartOnRemoteAppSession":true,
        "Compatibility":"Win8",
        "DeleteExpiredTaskAfter":"PT0S",
        "DisallowStartIfOnBatteries":false,
        "DontStopIfGoingOnBatteries":true,
        "ExecutionTimeLimit":"PT0S",
        "Hidden":false,
        "IdleSettings":{
            "StopOnIdleEnd":false,
            "RestartOnIdle":false
        },
        "MultipleInstances":"IgnoreNew",
        "Priority":"Normal",
        "RunOnlyIfNetworkAvailable":false,
        "WakeToRun":false
    },
    "AtLogon":false,
    "AtReboot":true,
    "Once":true,
    "OnceDateTime":{
        "DateTime":"2026-09-01T09:00:00",
        "RandomDelay":0
    },
    "Scheduled":true,
    "Schedules":[
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
}
```

The following example shows an _AtLogon_ task:
```json
{
    "Name":"Example AtLogon Task",
    "Script":"C:\\Temp\\OZOTaskScheduler-AtLogonTask-Example.ps1",
    "Parameters":"",
    "Directory":"C:\\Temp",
    "Disabled":true,
    "Settings":{
        "AllowDemandStart":true,
        "AllowHardTerminate":true,
        "AllowStartOnRemoteAppSession":true,
        "Compatibility":"Win8",
        "DeleteExpiredTaskAfter":"PT0S",
        "DisallowStartIfOnBatteries":false,
        "DontStopIfGoingOnBatteries":true,
        "ExecutionTimeLimit":"PT0S",
        "Hidden":false,
        "IdleSettings":{
            "StopOnIdleEnd":false,
            "RestartOnIdle":false
        },
        "MultipleInstances":"IgnoreNew",
        "Priority":"Normal",
        "RunOnlyIfNetworkAvailable":false,
        "WakeToRun":false
    },
    "AtLogon":true,
    "AtReboot":false,
    "Once":false,
    "OnceDateTime":{},
    "Scheduled":false,
    "Schedules":[]
}
```

|Key|Description|
|---|-----------|
|`Name`|The name of the scheduled task.|
|`Script`|The full path to the script or program to run.|
|`Parameters`|Parameters for the script or program.|
|`Directory`|The working directory for the task.|
|`Disabled`|Determines whether the task is disabled when created. Allowed values are _true_ and _false_.|
|`Settings`|A dictionary of Task Scheduler settings. See _Settings_, below.|
|`Scheduled`|Determines whether the task runs on one or more weekly schedules. Allowed values are _true_ and _false_. May be combined with _Once_ and _AtReboot_. If combined with _AtLogon_, the _AtLogon_ trigger is ignored.|
|`Schedules`|The schedule definitions for _Scheduled_ tasks. See _Schedules_, below.|
|`Once`|Determines whether the task runs once at the date and time in _OnceDateTime_. Allowed values are _true_ and _false_. May be combined with _Scheduled_ and _AtReboot_. If combined with _AtLogon_, the _AtLogon_ trigger is ignored.|
|`OnceDateTime`|The one-time trigger definition. Required when _Once_ is _true_; use an empty object when _Once_ is _false_. See _OnceDateTime_, below.|
|`AtReboot`|Determines whether the task runs at startup/reboot. Allowed values are _true_ and _false_. May be combined with _Scheduled_ and _Once_. If combined with _AtLogon_, the _AtLogon_ trigger is ignored.|
|`AtLogon`|Determines whether the task runs at user logon. Allowed values are _true_ and _false_. The trigger is created only when _Scheduled_, _Once_, and _AtReboot_ are all _false_.|

_Settings_ is a dictionary containing Task Scheduler settings:
```json
{
    "AllowDemandStart":true,
    "AllowHardTerminate":true,
    "AllowStartOnRemoteAppSession":true,
    "Compatibility":"Win8",
    "DeleteExpiredTaskAfter":"PT0S",
    "DisallowStartIfOnBatteries":false,
    "DontStopIfGoingOnBatteries":true,
    "ExecutionTimeLimit":"PT0S",
    "Hidden":false,
    "IdleSettings":{
        "StopOnIdleEnd":false,
        "RestartOnIdle":false
    },
    "MultipleInstances":"IgnoreNew",
    "Priority":"Normal",
    "RunOnlyIfNetworkAvailable":false,
    "WakeToRun":false
}
```

|Key|Description|
|---|-----------|
|`AllowDemandStart`|Determines whether the task can be started on demand (manually or by another program). Allowed values are _true_ and _false_. Defaults to _true_.|
|`AllowHardTerminate`|Determines whether the task can be terminated by ending its process. Allowed values are _true_ and _false_. Defaults to _true_.|
|`AllowStartOnRemoteAppSession`|Determines whether the task can start when launched from a Remote Desktop/RemoteApp session. Allowed values are _true_ and _false_. Defaults to _true_.|
|`Compatibility`|Task compatibility mode. Allowed values are _At_, _V1_, _Vista_, _Win7_, and _Win8_. Defaults to _Win8_.|
|`DeleteExpiredTaskAfter`|The amount of time to wait after the task expires before Task Scheduler deletes it, expressed as an ISO 8601 duration (for example, _PT0S_ or _P30D_). Omit to never delete the task automatically.|
|`DisallowStartIfOnBatteries`|Determines whether the task is prevented from starting when the computer is running on battery power. Allowed values are _true_ and _false_. Defaults to _true_.|
|`DontStopIfGoingOnBatteries`|Determines whether a running task keeps running after the computer switches to battery power. Allowed values are _true_ and _false_. Defaults to _false_.|
|`ExecutionTimeLimit`|The maximum amount of time the task is allowed to run, expressed as an ISO 8601 duration (for example, _PT72H_, or _PT0S_ for no limit). Defaults to _PT72H_.|
|`Hidden`|Determines whether the task is hidden in the Task Scheduler UI. Allowed values are _true_ and _false_. Defaults to _false_.|
|`IdleSettings`|Idle-related settings for the task. See _IdleSettings_, below.|
|`MultipleInstances`|Determines how Task Scheduler handles multiple simultaneous instances of the task. Allowed values are _IgnoreNew_, _Parallel_, and _Queue_. Defaults to _IgnoreNew_.|
|`Priority`|The task's process priority. Accepts an integer from _0_ (highest) to _10_ (lowest), or the friendly value _Normal_ (equivalent to _7_). Defaults to _7_.|
|`RunOnlyIfNetworkAvailable`|Determines whether the task only runs when a network connection is available. Allowed values are _true_ and _false_. Defaults to _false_.|
|`WakeToRun`|Determines whether the computer is woken from sleep to run the task. Allowed values are _true_ and _false_. Defaults to _false_.|

_IdleSettings_ is a dictionary containing idle settings:
```
{
    "StopOnIdleEnd":false,
    "RestartOnIdle":false
}
```

|Key|Description|
|---|-----------|
|`StopOnIdleEnd`|Determines whether the task stops if the idle condition ends before the task completes. Allowed values are _true_ and _false_. Defaults to _true_.|
|`RestartOnIdle`|Determines whether the task restarts the next time the computer becomes idle, if it was stopped because the idle condition ended. Allowed values are _true_ and _false_. Defaults to _false_.|

_Schedules_ is a list of dictionaries. Each dictionary should contain a `WeekDay`, `StartTime`, and `RandomDelay` value in seconds. Example:
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

|Key|Description|
|---|-----------|
|`WeekDay`|The day of the week to run the task. Allowed values are _Sunday_, _Monday_, _Tuesday_, _Wednesday_, _Thursday_, _Friday_, and _Saturday_.|
|`StartTime`|The start time for the task in `HH:MM AM/PM` format.|
|`RandomDelay`|The number of seconds to randomize the start time. Allowed range is 0-3600 seconds.|

_OnceDateTime_ is a dictionary containing one date/time trigger definition:
```json
{
    "DateTime":"2026-09-01T09:00:00",
    "RandomDelay":0
}
```

|Key|Description|
|---|-----------|
|`DateTime`|The date and time for the one-time trigger. Use an ISO 8601 value. The value must not be in the past.|
|`RandomDelay`|The number of seconds to randomize the start time. Allowed range is 0-3600 seconds.|

### Generating a Compressed JSON String
You can define your JSON in any text editor and save it as a file, for example [`OZOTaskScheduler-ScheduledTask-Example.json`](OZOTaskScheduler-ScheduledTask-Example.json) and [`OZOTaskScheduler-AtLogonTask-Example.json`](OZOTaskScheduler-AtLogonTask-Example.json), then convert the file to a compressed JSON string with:
```powershell
Convert-OZOJsonFileToString -Path C:\Temp\OZOTaskScheduler-ScheduledTask-Example.json
{"Name":"Example Scheduled Task","Script":"C:\\Temp\\OZOTaskScheduler-ScheduledTask-Example.ps1","Parameters":"","Directory":"C:\\Temp","Disabled":true,"Settings":{"AllowDemandStart":true,"AllowHardTerminate":true,"AllowStartOnRemoteAppSession":true,"Compatibility":"Win8","DeleteExpiredTaskAfter":"PT0S","DisallowStartIfOnBatteries":false,"DontStopIfGoingOnBatteries":true,"ExecutionTimeLimit":"PT0S","Hidden":false,"IdleSettings":{"StopOnIdleEnd":false,"RestartOnIdle":false},"MultipleInstances":"IgnoreNew","Priority":"Normal","RunOnlyIfNetworkAvailable":false,"WakeToRun":false},"AtLogon":false,"AtReboot":true,"Once":true,"OnceDateTime":{"DateTime":"2026-09-01T09:00:00","RandomDelay":0},"Scheduled":true,"Schedules":[{"WeekDay":"Monday","StartTime":"8:00 AM","RandomDelay":0},{"WeekDay":"Wednesday","StartTime":"8:00 AM","RandomDelay":0},{"WeekDay":"Friday","StartTime":"8:00 AM","RandomDelay":0}]}
```

Encapsulate the resulting compressed JSON in single quotes (`'`) so it can be passed as a single string value for _JsonString_:
```powershell
'{"Name":"Example Scheduled Task","Script":"C:\\Temp\\OZOTaskScheduler-ScheduledTask-Example.ps1","Parameters":"","Directory":"C:\\Temp","Disabled":true,"Settings":{"AllowDemandStart":true,"AllowHardTerminate":true,"AllowStartOnRemoteAppSession":true,"Compatibility":"Win8","DeleteExpiredTaskAfter":"PT0S","DisallowStartIfOnBatteries":false,"DontStopIfGoingOnBatteries":true,"ExecutionTimeLimit":"PT0S","Hidden":false,"IdleSettings":{"StopOnIdleEnd":false,"RestartOnIdle":false},"MultipleInstances":"IgnoreNew","Priority":"Normal","RunOnlyIfNetworkAvailable":false,"WakeToRun":false},"AtLogon":false,"AtReboot":true,"Once":true,"OnceDateTime":{"DateTime":"2026-09-01T09:00:00","RandomDelay":0},"Scheduled":true,"Schedules":[{"WeekDay":"Monday","StartTime":"8:00 AM","RandomDelay":0},{"WeekDay":"Wednesday","StartTime":"8:00 AM","RandomDelay":0},{"WeekDay":"Friday","StartTime":"8:00 AM","RandomDelay":0}]}'
```

## Examples
### Example 1
```powershell
Set-OZOScheduledTask -JsonFile "C:\Temp\OZOTaskScheduler-ScheduledTask-Example.json"
```
### Example 2
```powershell
Set-OZOScheduledTask -JsonString '{"Name":"Example Scheduled Task","Script":"C:\\Temp\\OZOTaskScheduler-ScheduledTask-Example.ps1","Parameters":"","Directory":"C:\\Temp","Disabled":true,"Settings":{"AllowDemandStart":true,"AllowHardTerminate":true,"AllowStartOnRemoteAppSession":true,"Compatibility":"Win8","DeleteExpiredTaskAfter":"PT0S","DisallowStartIfOnBatteries":false,"DontStopIfGoingOnBatteries":true,"ExecutionTimeLimit":"PT0S","Hidden":false,"IdleSettings":{"StopOnIdleEnd":false,"RestartOnIdle":false},"MultipleInstances":"IgnoreNew","Priority":"Normal","RunOnlyIfNetworkAvailable":false,"WakeToRun":false},"AtLogon":false,"AtReboot":true,"Once":true,"OnceDateTime":{"DateTime":"2026-09-01T09:00:00","RandomDelay":0},"Scheduled":true,"Schedules":[{"WeekDay":"Monday","StartTime":"8:00 AM","RandomDelay":0},{"WeekDay":"Wednesday","StartTime":"8:00 AM","RandomDelay":0},{"WeekDay":"Friday","StartTime":"8:00 AM","RandomDelay":0}]}'
```

## See Also
* [`OZOTaskScheduler-ScheduledTask-Example.json`](OZOTaskScheduler-ScheduledTask-Example.json)
* [`OZOTaskScheduler-AtLogonTask-Example.json`](OZOTaskScheduler-AtLogonTask-Example.json)
