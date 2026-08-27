## OZOOnceDateTime
This class is part of the [OZOTaskScheduler PowerShell Module](../README.md).

## Description
Internal class that validates the date/time and random delay used by a task's one-time trigger.

## Important Note
This is an **internal class** used by `OZOTask`. It is not intended for direct use by module consumers.

## Constructors

**OnceDateTime Constructor**
```
OZOOnceDateTime($OnceDateTime)
```
Creates a new instance from a one-time trigger definition.
- `$OnceDateTime`: A definition containing `DateTime` and `RandomDelay`

## Properties
Public properties:
- `$Valid`: Boolean indicating whether the one-time trigger definition is valid
- `$RandomDelay`: Random delay in seconds for the trigger
- `$RandomDelayMax`: Maximum allowed random delay in seconds (`3600`)
- `$DateTime`: The date and time when the task should run once

## Methods
- **Validates()**
  Validates that the random delay is within range, the date/time can be parsed as a `DateTime`, and the date/time is not in the past.
  - Returns: `Boolean` - `$true` if valid, `$false` otherwise

## How It Works
1. `OZOTask` creates an instance when `Once` is enabled
2. The constructor copies the values from the `OnceDateTime` JSON dictionary
3. `Validates()` checks the date/time and random delay
4. `OZOTask` uses the valid definition to create a one-time trigger

## JSON Definition
The `OnceDateTime` value is a dictionary within a task definition:
```json
{
    "DateTime":"2026-09-01T09:00:00",
    "RandomDelay":0
}
```

Use an ISO 8601 date/time value. The date/time must not be in the past, and `RandomDelay` must be between 0 and 3600 seconds.

## See Also
- [OZOTask](OZOTask.md)
- [OZOJsonTask](OZOJsonTask.md)
- [New-OZOScheduledTask](New-OZOScheduledTask.md)
- [Set-OZOScheduledTask](Set-OZOScheduledTask.md)
