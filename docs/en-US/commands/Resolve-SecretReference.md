---
external help file: AtlassianPSVII.Configuration-help.xml
Module Name: AtlassianPSVII.Configuration
online version: https://atlassianps.org/docs/AtlassianPS.Configuration/commands/Resolve-SecretReference/
locale: en-US
schema: 2.0.0
layout: documentation
permalink: /docs/AtlassianPS.Configuration/commands/Resolve-SecretReference/
---
# Resolve-SecretReference

## SYNOPSIS

Resolves external secret references into in-memory secure objects.

## SYNTAX

```powershell
Resolve-AtlassianSecretReference [[-SecretReference] <Hashtable>] [[-ProviderAdapter] <Hashtable>]
 [[-Credential] <PSCredential>] [[-Token] <SecureString>] [<CommonParameters>]
```

## DESCRIPTION

Resolves caller-supplied credentials, caller-supplied secure tokens, environment-variable references,
SecretManagement references, or custom provider adapters into secure in-memory values.

References contain lookup metadata only. They must not contain token, password, secret, credential, API key,
authorization, or plaintext fallback values.

## EXAMPLES

### EXAMPLE 1

```powershell
$env:ATLASSIAN_API_TOKEN = "example-token"
Resolve-AtlassianSecretReference -SecretReference @{
    Provider = "Environment"
    Name     = "ATLASSIAN_API_TOKEN"
    Type     = "Token"
}
$env:ATLASSIAN_API_TOKEN = $null
```

Returns a hashtable with a `SecureString` token resolved from the environment variable.

### EXAMPLE 2

```powershell
$token = [System.Net.NetworkCredential]::new("", "example-token").SecurePassword
Resolve-AtlassianSecretReference -Token $token
```

Returns caller-supplied secure token material without reading configuration or prompting internally.

### EXAMPLE 3

```powershell
if (Get-Command -Name Get-Secret -ErrorAction SilentlyContinue) {
    Resolve-AtlassianSecretReference -SecretReference @{
        Provider = "SecretManagement"
        Name     = "AtlassianApiToken"
        Type     = "Token"
    }
}
```

Returns a token resolved through PowerShell SecretManagement when `Get-Secret` is available.

## PARAMETERS

### -SecretReference

Reference metadata used to locate a secret outside the configuration file.
Supported keys are `Provider`, `Name`, `Type`, and optional non-secret `UserName`.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True
Accept wildcard characters: False
```

### -ProviderAdapter

Hashtable of provider names to script blocks. Custom adapters receive `-SecretReference` and must return a
`SecureString`, `PSCredential`, or a hashtable containing `Token`, `Credential`, or `Secret`.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: @{}
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential

Caller-supplied credential. This value is returned directly and is never persisted.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Token

Caller-supplied secure token. This value is returned directly and is never persisted.

```yaml
Type: SecureString
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
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

System.Collections.Hashtable

## OUTPUTS

System.Collections.Hashtable

## NOTES

Resolution errors are intentionally redacted. Configure provider-specific logging outside this helper when
diagnosing backend access issues.

## RELATED LINKS

[Add-ServerConfiguration](../Add-ServerConfiguration/)
