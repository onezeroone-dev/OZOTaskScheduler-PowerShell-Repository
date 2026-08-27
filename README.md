# OZOTaskScheduler PowerShell Module

## Description
OZOTaskScheduler provides a lightweight PowerShell interface for managing Windows Task Scheduler tasks. It is designed to create, update, enable, disable, export, and remove scheduled tasks using simple function calls and JSON task definitions.

## Installation
This module is published to Microsoft's [PowerShell Gallery](https://learn.microsoft.com/en-us/powershell/scripting/gallery/overview?view=powershell-5.1). Run the following command in an _Administrator_ PowerShell session:

```powershell
Install-Module OZOTaskScheduler
```

## Usage
Import the module in your script or console:

```powershell
Import-Module OZOTaskScheduler
```

## Functions
- [Disable-OZOScheduledTask](Documentation/Disable-OZOScheduledTask.md)
- [Enable-OZOScheduledTask](Documentation/Enable-OZOScheduledTask.md)
- [Export-OZOScheduledTask](Documentation/Export-OZOScheduledTask.md)
- [Get-OZOScheduledTask](Documentation/Get-OZOScheduledTask.md)
- [New-OZOScheduledTask](Documentation/New-OZOScheduledTask.md)
- [Set-OZOScheduledTask](Documentation/Set-OZOScheduledTask.md)
- [Remove-OZOScheduledTask](Documentation/Remove-OZOScheduledTask.md)

## Classes
- [OZOJsonTask](Documentation/OZOJsonTask.md)
- [OZOTask](Documentation/OZOTask.md)
- [OZOSchedule](Documentation/OZOSchedule.md)

## Logging
When available, messages are written to the [_One Zero One_ event provider](https://github.com/onezeroone-dev/OZOLogger-PowerShell-Module/blob/main/README.md). Otherwise, events are written to the _Microsoft-Windows-PowerShell_ provider as _Information_ events with event ID *4100*.

## License
This module is licensed under the [GNU General Public License (GPL) version 2.0](LICENSE).

## Acknowledgements
Special thanks to my employer, [Sonic Healthcare USA](https://sonichealthcareusa.com), who supports the growth of my PowerShell skillset and enables me to contribute portions of my work product to the PowerShell community.
