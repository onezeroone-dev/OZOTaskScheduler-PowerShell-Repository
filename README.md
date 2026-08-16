# OZOTaskScheduler PowerShell Module Installation and Usage

## Description
Provides functions for managing Windows Task Scheduler tasks.

## Installation
This module is published to Microsoft's [PowerShell Gallery](https://learn.microsoft.com/en-us/powershell/scripting/gallery/overview?view=powershell-5.1). Ensure your system is configured for this repository then execute the following in an _Administrator_ PowerShell:

```powershell
Install-Module OZOTaskScheduler
```

## Usage
Import this module in your script or console to make the functions available for use:

```powershell
Import-Module OZOTaskScheduler
```

## Functions
- [New-OZOScheduledTask](Documentation/New-OZOScheduledTask.md)
- [Set-OZOScheduledTask](Documentation/Set-OZOScheduledTask.md)
- [Remove-OZOScheduledTask](Documentation/Remove-OZOScheduledTask.md)

## Classes
- [OZOScheduledTask](Documentation/OZOScheduledTask.md)

## Logging
When available, messages are written to the [_One Zero One_ event provider](https://github.com/onezeroone-dev/OZOLogger-PowerShell-Module/blob/main/README.md). Otherwise, events are written to the _Microsoft-Windows-PowerShell_ provider as _Information_ events using event ID *4100*.

## License
This module is licensed under the [GNU General Public License (GPL) version 2.0](LICENSE).

## Acknowledgements
Special thanks to my employer, [Sonic Healthcare USA](https://sonichealthcareusa.com), who supports the growth of my PowerShell skillset and enables me to contribute portions of my work product to the PowerShell community.
