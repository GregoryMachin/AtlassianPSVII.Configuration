---
external help file: AtlassianPSVII.Configuration-help.xml
Module Name: AtlassianPSVII.Configuration
online version: https://atlassianps.org/docs/AtlassianPS.Configuration/commands/ConvertTo-Uri/
locale: en-US
schema: 2.0.0
layout: documentation
permalink: /docs/AtlassianPS.Configuration/commands/ConvertTo-Uri/
---
# ConvertTo-Uri

## SYNOPSIS

Normalizes Atlassian product, deployment, OAuth, and pagination URIs.

## SYNTAX

```powershell
ConvertTo-AtlassianUri [-Uri] <String> [-Product] <String> [-DeploymentType] <String>
 [[-Mode] <String>] [[-CloudId] <String>] [[-BaseUri] <String>] [<CommonParameters>]
```

## DESCRIPTION

Returns a normalized `[Uri]` for Atlassian Cloud and Data Center request boundaries.
The helper keeps product-specific rules in one place:

- Jira Cloud site URLs remain rooted at the site host.
- Confluence Cloud site/API URLs include `/wiki`.
- OAuth routes are built under `https://api.atlassian.com/ex/{product}/{cloudId}/`.
- Data Center and Server context paths are preserved.
- Relative pagination links are resolved against a trusted base URI.

Cloud endpoints must use HTTPS. The helper rejects embedded credentials, fragments, path traversal,
unexpected OAuth hosts, and absolute pagination links that leave the trusted base host.

## EXAMPLES

### EXAMPLE 1

```powershell
ConvertTo-AtlassianUri -Uri "https://example.atlassian.net" -Product Confluence -DeploymentType Cloud
```

Returns `https://example.atlassian.net/wiki/`.

### EXAMPLE 2

```powershell
ConvertTo-AtlassianUri -Uri "/rest/api/3/myself" -Product Jira -DeploymentType Cloud -Mode OAuth -CloudId "00000000-0000-0000-0000-000000000000"
```

Returns an `api.atlassian.com` Jira OAuth route for the supplied Cloud ID.

### EXAMPLE 3

```powershell
ConvertTo-AtlassianUri -Uri "/wiki/api/v2/pages?cursor=abc" -BaseUri "https://example.atlassian.net/wiki/api/v2/pages" -Product Confluence -DeploymentType Cloud -Mode Pagination
```

Returns the absolute pagination URI on the trusted base host.

## PARAMETERS

### -Uri

URI or relative link to normalize.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True
Accept wildcard characters: False
```

### -Product

Atlassian product that owns the URI rules.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Bitbucket, Confluence, Jira

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DeploymentType

Deployment type that owns the URI trust rules.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Cloud, DataCenter, Server

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Mode

Normalization mode.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Site, Api, OAuth, Pagination

Required: False
Position: 4
Default value: Site
Accept pipeline input: False
Accept wildcard characters: False
```

### -CloudId

Atlassian Cloud ID required for OAuth route normalization.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BaseUri

Trusted absolute base URI used to resolve relative pagination links and validate absolute pagination links.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
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

System.String

## OUTPUTS

System.Uri

## NOTES

This helper does not perform network access.

## RELATED LINKS

[ConvertFrom-QueryString](../ConvertFrom-QueryString/)

