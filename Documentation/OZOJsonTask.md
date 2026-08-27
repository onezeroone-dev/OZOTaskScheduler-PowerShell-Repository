## OZOJsonTask
This class is part of the [OZOTaskScheduler PowerShell Module](../README.md).

## Description
Internal class that reads a scheduled task definition from a JSON file or a JSON string, validates the input, and creates the corresponding `OZOTask` object used by the module's public functions.

## Important Note
This is an **internal class** used by the module's public functions (`New-OZOScheduledTask` and `Set-OZOScheduledTask`). It is not intended for direct use by module consumers.

## Constructors

**Full Constructor**
```
OZOJsonTask($JsonFile:String, $JsonString:String)
```
Creates a new instance from either a JSON file path or a JSON string.
- `$JsonFile`: The path to a JSON file that defines the task
- `$JsonString`: A JSON string that defines the task

## Properties
The class exposes the following property:
- `$Task`: The `OZOTask` object created from the supplied configuration

The parsed JSON definition and logger are stored as hidden internal properties.

## Methods
- **ValidateConfiguration($JsonFile,$JsonString)**
  Attempts to load the task definition from either a file or a JSON string and validates that the input is valid JSON.
  - Returns: `Boolean` - `$true` if the configuration is valid, `$false` otherwise

- **ValidateEnvironment()**
  Checks whether the current environment is suitable for scheduled task creation. In the current implementation, this method is effectively a placeholder.
  - Returns: `Boolean` - `$true` if the environment is valid, `$false` otherwise

## How It Works
1. A public function passes a JSON file or JSON string to the constructor
2. `ValidateConfiguration()` attempts to parse the JSON content
3. `ValidateEnvironment()` confirms the environment is suitable
4. A corresponding `OZOTask` object is created and stored in `$Task`

## See Also
- [New-OZOScheduledTask](New-OZOScheduledTask.md)
- [Set-OZOScheduledTask](Set-OZOScheduledTask.md)
- [OZOTask](OZOTask.md)
