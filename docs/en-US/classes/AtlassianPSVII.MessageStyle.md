---
layout: documentation
Module Name: AtlassianPSVII.Configuration
permalink: /docs/AtlassianPS.Configuration/classes/AtlassianPSVII.MessageStyle/
---
# AtlassianPSVII.MessageStyle

## SYNOPSIS

Object that describes the users preference on how messages such be displayed.

## DESCRIPTION

Object that describes the users preference on how messages such be displayed.
These messages can be Verbose, Debug, Warning, etc.

This object must be stored in the `AtlassianPSVII.Configuration` under the key
`Message`.

### Examples

#### Example: modifying a value

```powershell
# get the current values
$messagePreferences = Get-AtlassianConfiguration -Name Message -ValueOnly
# change one property
$messagePreferences.BreadCrumbs = $true
# save changes
Set-AtlassianConfiguration -Name Message -Value $messagePreferences
```

#### Example: setting custom preferences

```powershell
# create a new object with default values
$messagePreferences = [AtlassianPSVII.MessageStyle]@{}
# save it
Set-AtlassianConfiguration -Name Message -Value $messagePreferences
```

## CONSTRUCTORS

### $null

A new object of type `[AtlassianPSVII.MessageStyle]` with default values can be
create by calling it without any parameter.

```powershell
New-Object -TypeName AtlassianPSVII.MessageStyle
[AtlassianPSVII.MessageStyle]@{}
[AtlassianPSVII.MessageStyle]:new()
```

### Positional Parameters

A new object of type `[AtlassianPSVII.MessageStyle]` can be created by providing a
value for the properties.

The order is: Indent, TimeStamp, BreadCrumbs, FunctionName

```powershell
New-Object -TypeName AtlassianPSVII.MessageStyle -ArgumentList 0, $true, $true, $true
[AtlassianPSVII.MessageStyle]::new(0, $true, $true, $true)
```

### Hashtable

A new object of type `[AtlassianPSVII.MessageStyle]` can be create by providing a
hashtable with the desired values for the properties.

```powershell
[AtlassianPSVII.MessageStyle]@{
    Indent = 0;
    TimeStamp = $true;
    BreadCrumbs = $true;
    FunctionName = $true
}
```

## PROPERTIES

### Indent

A numerical value representing how many whitespaces should be used in the
message line when using breadcrumbs.

Must be a positive natural number.

```yaml
DataType: UInt32
Default Value: 4
```

### Timestamp

Switch for showing the timestamp in front of the message.

The timestamp uses the format: `HH:mm:ss` (24 hours)

```yaml
DataType: Boolean
Default Value: True
```

### Breadcrumbs

Switch for showing breadcrumbs of the function which is showing the message.

The breadcrumbs represent the nested calls of the functions.
By enabling this, one can easily understand dependencies between functions.

```yaml
DataType: Boolean
Default Value: False
```

### FunctionName

Switch for showing the name of the function which is showing the message.

```yaml
DataType: Boolean
Default Value: True
```
