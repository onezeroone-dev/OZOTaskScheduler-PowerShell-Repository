## OZOScheduledTask
This class is part of the [OZOTaskScheduler PowerShell Module](https://github.com/onezeroone-dev/OZOTaskScheduler-PowerShell-Repository/blob/main/README.md).

## Usage
This class is used by the `New-OZOScheduledTask` and `Set-OZOScheduledTask` functions.

## Public Properties
|Property|Type|Description|
|--------|----|-----------|
|`Display`|Boolean|Determines whether or not console messages are displayed during a user-interactive session. See `SetDisplay()`.|
|`keyExists`|Boolean|True if the key Exists and otherwise False. This can be used to determine if the object represents an existing key (True) or a new key (False).|
|`keyPathValid`|Boolean|True if the key format is valid and otherwise False. This limits whether a key can be read or written.|
|`namesRead`|Boolean|True if the key exists and all values were successfully read.|
|`keyPath`|String|The registry key path, parsed for use with PowerShell cmdlets.|

## Public Methods
|Method|Return Type|Description|
|------|-----------|-----------|
|`SetDisplay([Boolean]$DisplayBool)`|Void|Sets the `$Display` property. Requires `$true` or `$false` and sets the `$Display` boolean accordingly.|
|`DisplayKey()`|Void|Displays the contents of the `$Names` array that represents `$Key`. Only produces output when `$Display` is `$true` and the session is user-interactive. Use `SetDisplay()` to set `$Display`.|
|`ReturnKeyNameValue([String]$Name,[String]$Value)`|`Byte[]`\|`Int32`\|`Int64`\|`String`\|`String[]`|Returns the value for a given name.|
|`ReturnKeyNameType([String]$Name,[String]$Value)`|`String`|Returns the type for a given name.|
|`AddKeyName([String]$Name,[Object]$Value)`|`Boolean`||
|`RemoveKeyName([String]$Name)`|`Boolean`||
|`UpdateKeyName([String]$Name,[Object]$Value)`||
|`ProcessChanges()`|`Boolean`||

## Definition
### Associations
```
+ $Display:Boolean       = $false
+ $keyExists:Boolean     = $true
+ $keyPathValid:Boolean  = $true
+ $namesRead:Boolean     = $true
+ $keyPath:String        = $null
- $Key:PSCustomObject    = $null
- $Logger:PSCustomObject = $null
- $Names:System.Collections.Generic.List[PSCustomObject] = @()
```
### Operations
```
+ OZORegistryKey($KeyPath:String,$Display:Boolean):Void
- ValidateKeyPath($KeyPath:String):Boolean
- ReadKey():Boolean
- ReadKeyValues():Boolean
+ SetDisplay($DisplayBool:Boolean):Void
+ DisplayKey():Void
+ ReturnKeyNameValue($Name:String):Object
+ ReturnKeyNameType($Name:String):String
+ AddKeyName($Name:String,$Value):Void
+ RemoveKeyName($Name:String):Void
+ UpdateKeyName($Name:String,$Value):Void
+ ProcessChanges():Boolean
```