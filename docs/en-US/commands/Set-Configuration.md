---
external help file: AtlassianPSVII.Configuration-help.xml
Module Name: AtlassianPSVII.Configuration
online version: https://github.com/GregoryMachin/AtlassianPSVII.Configuration/blob/master/docs/en-US/commands/Set-Configuration.md
locale: en-US
schema: 2.0.0
---
# Set-Configuration

## SYNOPSIS

Stores a key/value pair to the configuration

## SYNTAX

```powershell
Set-AtlassianConfiguration [-Name] <String> [[-Value] <Object>] [-Append] [-Passthru]
 [<CommonParameters>]
```

## DESCRIPTION

Stores a key/value pair to the configuration.

This is only available in the current sessions, unless exported.

## EXAMPLES

### EXAMPLE 1

```powershell
Set-AtlassianConfiguration -Name "Headers" -Value @{Accept = "application/json"}
```

This command will store a new Header configuration

## PARAMETERS

### -Name

Name under which to store the value

Is not case sensitive

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Value

Value to store

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Append

Append Value to existing data

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Passthru

Whether output should be provided after invoking this function

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction,
-ErrorVariable, -InformationAction, -InformationVariable, -OutVariable,
-OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters
(<http://go.microsoft.com/fwlink/?LinkID=113216>).

## INPUTS

## OUTPUTS

### PSCustomObject

## NOTES

## RELATED LINKS

[Get-Configuration](../Get-Configuration/)

[Remove-Configuration](../Remove-Configuration/)

[Export-Configuration](https://github.com/PoshCode/Configuration)
