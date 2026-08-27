# Set-OZOScheduledTask
This function is part of the [OZOTaskScheduler PowerShell Module](https://github.com/onezeroone-dev/OZOTaskScheduler-PowerShell-Repository/blob/main/README.md).

## Description
Updates a scheduled task. Uses PowerShell to run `.ps1` scripts and CMD to run everything else. Tasks may be run at logon by the logged in user with the _TaskAtLogon_ parameter, *or* may be scheduled to run as the _SYSTEM_ user with the _TaskScheduled_ paramter. _TaskScheduled_ tasks can have multiple schedules and can optionally run at reboot with the _TaskAtReboot_ parameter.

If the task already exists, it will be deleted and recreated.

## Prerequisites
This script requires _Administrator_ privileges.

## Syntax
This function supports two parameter sets: one for tasks defined as a JSON file and and one for tasks defined as a compressed JSON string

```
Set-OZOScheduledTask
    -JsonFile <string>

Set-OZOScheduledTask
    -JsonString <String>
```

## Parameters
|Parameter|Description|
|---------|-----------|
|`JsonFile`|The name of the scheduled task.|
|`JsonString`|The absolute path to the script to run.|

## Json Definition
Tasks are expressed as a JSON dictionary. Here is an example for a _Scheduled_ task with three _Schedules_:
```json
{
    "Name":"Example Scheduled Task",
    "Script":"C:\\Temp\\example.ps1",
    "Parameters":"",
    "Compatibility":"Win8",
    "Directory":"C:\\Temp",
    "Disabled":true,
    "Scheduled":true,
    "Schedules":[
        {
            "WeekDay":"Monday",
            "StartTime":"8:00 AM",
            "RandomDelay":0        },
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
    ],
    "AtReboot":false,
    "AtLogon":false,
    "OneTime":false
}
```

Here is an example of an _AtLogon_ task:
```json
{
    "Name":"Example AtLogon Task",
    "Script":"C:\\Temp\\logonScript.ps1",
    "Parameters":"",
    "Compatibility":"Win8",
    "Directory":"C:\\Temp",
    "Disabled":true,
    "Scheduled":false,
    "Schedules":[],
    "AtReboot":false,
    "AtLogon":true,
    "OneTime":false
}
```

|Key|Description|
|---|-----------|
|`Name`|The name of the scheduled task.|
|`Script`|The name of the script or program to run.|
|`Parameters`|Parameters for the script or program.|
|`Compatibility`|Compatibility for the scheduled task. Allowed values are _At_, _V1_, _Vista_, _Win7_, and _Win8_. Defaults to _Win8_.|
|`Directory`|The directory where the task will run.|
|`Disabled`|Determines if the task will be disabled on creation. Allowed values are _true_ and _false_.|
|`Scheduled`|Determines if the task will run on one or more schedules. Allowed values are _true_ and _false_. May be combined with _AtReboot_. Exclusive with _AtLogon_.|
|`Schedules`|The schedules for _Scheduled_ tasks. See _Schedules_, below.|
|`AtReboot`|Determines if the task will run at reboot. Allowed values are _true_ and _false_. May be combined with _Scheduled_. Exclusive with _AtLogon_.|
|`AtLogon`|Determines if the task will run during logon as the logged on user. Allowed values are _true_ and _false_. Exclusive with _Scheduled_ and _AtReboot_.|
|`OneTime`|Determines it the task will run only once. Allowed values are _true_ and _false_. Must be combined with exactly one of _Scheduled_, _AtReboot_, or _AtLogon_. When _Scheduled_ is _true_, only the first valid schedule definition is added to the the task.

_Schedules_ is a list of dictionaries. Each dictionary should contain a _Weekday_, a _StartTime_, and a _RandomDelay_ in seconds. Example:
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
|`StartTime`|The start time for the task in in HH:MM AM|PM format. |
|`RandomDelay`|The number of seconds to randomize the start time. Allowed range is 0-3600 seconds.|

### Generating a Compressed JSON String
You can define your JSON in any text editor and save it as a file e.g., [`OZOTaskScheduler-ScheduledTask-Example.json`](OZOTaskScheduler-ScheduledTask-Example.json) and [`OZOTaskScheduler-AtReboot-Example.json`](OZOTaskScheduler-AtRebootTask-Example.json) and convert your file to a compressed JSON string with:
```powershell
Convert-OZOJsonFileToString -Path C:\Temp\OZOTaskScheduler-ScheduledTask-Example.json
{"Name":"Example AtLogon Task","Script":"C:\\Temp\\logonScript.ps1","Parameters":"","Compatibility":"Win8","Directory":"C:\\Temp","Disabled":true,"Scheduled":false,"Schedules":[],"AtReboot":false,"AtLogon":true}
```
Encapsulate the resulting compressed JSON in single quotes (') which can be passed as one continuous string as the value for _JsonString_:
```powershell
'{"Name":"Example AtLogon Task","Script":"C:\\Temp\\logonScript.ps1","Parameters":"","Compatibility":"Win8","Directory":"C:\\Temp","Disabled":true,"Scheduled":false,"Schedules":[],"AtReboot":false,"AtLogon":true}'
```

## Examples
### Example 1
```powershell
Set-OZOScheduledTask -JsonFile "C:\Temp\OZOTaskScheduler-ScheduledTask-Example.json"
```
### Example 2
```powershell
Set-OZOScheduledTask -JsonString '{"Name":"Example AtLogon Task","Script":"C:\\Temp\\logonScript.ps1","Parameters":"","Compatibility":"Win8","Directory":"C:\\Temp","Disabled":true,"Scheduled":false,"Schedules":[],"AtReboot":false,"AtLogon":true}'
```

## See Also
* [`OZOTaskScheduler-ScheduledTask-Example.json`](OZOTaskScheduler-ScheduledTask-Example.json)
* [`OZOTaskScheduler-AtReboot-Example.json`](OZOTaskScheduler-AtRebootTask-Example.json)
