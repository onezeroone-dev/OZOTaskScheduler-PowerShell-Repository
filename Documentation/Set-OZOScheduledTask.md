# Set-OZOScheduledTask
This function is part of the [OZOTaskScheduler PowerShell Module](https://github.com/onezeroone-dev/OZOTaskScheduler-PowerShell-Repository/blob/main/README.md).

## Description
Updates an existing scheduled task. The module uses `powershell.exe` to run `.ps1` scripts and `cmd.exe` to run other executable files. Tasks may run at logon for the logged-in user with the `AtLogon` setting, or may be scheduled to run as the _SYSTEM_ account with the `Scheduled` setting. _Scheduled_ tasks may also run at startup with the `AtReboot` setting.

If the task already exists, it will be removed and recreated.

## Prerequisites
This script requires _Administrator_ privileges.

## Syntax
This function supports two parameter sets: one for tasks defined in a JSON file and one for tasks defined as a compressed JSON string.

```
Set-OZOScheduledTask
    -JsonFile <string>

Set-OZOScheduledTask
    -JsonString <String>
```

## Parameters
|Parameter|Description|
|---------|-----------|
|`JsonFile`|The path to a JSON file that defines the task configuration.|
|`JsonString`|A compressed JSON string that defines the task configuration.|

## JSON Definition
Tasks are expressed as a JSON dictionary. The following example shows a _Scheduled_ task with three schedule entries:
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
    ],
    "AtReboot":false,
    "AtLogon":false
}
```

The following example shows an _AtLogon_ task:
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
    "AtLogon":true
}
```

|Key|Description|
|---|-----------|
|`Name`|The name of the scheduled task.|
|`Script`|The full path to the script or program to run.|
|`Parameters`|Parameters for the script or program.|
|`Compatibility`|Task compatibility mode. Allowed values are _At_, _V1_, _Vista_, _Win7_, and _Win8_. Defaults to _Win8_.|
|`Directory`|The working directory for the task.|
|`Disabled`|Determines whether the task is disabled when created. Allowed values are _true_ and _false_.|
|`Scheduled`|Determines whether the task runs on one or more schedules. Allowed values are _true_ and _false_. May be combined with _AtReboot_. Exclusive with _AtLogon_.|
|`Schedules`|The schedule definitions for _Scheduled_ tasks. See _Schedules_, below.|
|`AtReboot`|Determines whether the task runs at startup/reboot. Allowed values are _true_ and _false_. May be combined with _Scheduled_. Exclusive with _AtLogon_.|
|`AtLogon`|Determines whether the task runs at user logon. Allowed values are _true_ and _false_. Exclusive with _Scheduled_ and _AtReboot_.|

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

### Generating a Compressed JSON String
You can define your JSON in any text editor and save it as a file, for example [`OZOTaskScheduler-ScheduledTask-Example.json`](OZOTaskScheduler-ScheduledTask-Example.json) and [`OZOTaskScheduler-AtLogonTask-Example.json`](OZOTaskScheduler-AtLogonTask-Example.json), then convert the file to a compressed JSON string with:
```powershell
Convert-OZOJsonFileToString -Path C:\Temp\OZOTaskScheduler-ScheduledTask-Example.json
{"Name":"Example AtLogon Task","Script":"C:\\Temp\\logonScript.ps1","Parameters":"","Compatibility":"Win8","Directory":"C:\\Temp","Disabled":true,"Scheduled":false,"Schedules":[],"AtReboot":false,"AtLogon":true}
```

Encapsulate the resulting compressed JSON in single quotes (`'`) so it can be passed as a single string value for _JsonString_:
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
* [`OZOTaskScheduler-AtLogonTask-Example.json`](OZOTaskScheduler-AtLogonTask-Example.json)
