## OZOSchedule
This class is part of the [OZOTaskScheduler PowerShell Module](../README.md).

## Description
Internal class that validates and stores a single schedule definition for a task. It provides the task trigger metadata used by the module when creating weekly scheduled tasks.

## Important Note
This is an **internal class** used by `OZOTask` to validate and process daily and weekly schedule definitions. It is not intended for direct use by module consumers.

## Constructors

**Schedule Constructor**
```
OZOSchedule($Schedule)
```
Creates a new instance from a schedule object.
- `$Schedule`: A schedule definition containing `RandomDelay`, `WeekDay`, and `StartTime`

## Properties
Public properties:
- `$Valid`: Boolean indicating whether the schedule is valid
- `$RandomDelay`: Random delay in seconds for the trigger
- `$RandomDelayMax`: Maximum allowed random delay in seconds (`3600`)
- `$StartTime`: The time the task should start
- `$WeekDay`: The day of the week for the scheduled trigger

`$Weekdays` is a hidden internal list used for weekday validation.

## Methods
- **Validates()**
  Validates the schedule definition by checking that the random delay is within range, the start time can be parsed as a `DateTime`, and the weekday is recognized.
  - Returns: `Boolean` - `$true` if valid, `$false` otherwise

## How It Works
1. The constructor populates the schedule properties from the provided object
2. `Validates()` checks the values for correctness
3. The result is stored in `$Valid` and used by the task creation logic

## See Also
- [OZOTask](OZOTask.md)
- [OZOJsonTask](OZOJsonTask.md)
- [New-OZOScheduledTask](New-OZOScheduledTask.md)
