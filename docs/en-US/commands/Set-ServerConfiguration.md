---
external help file: AtlassianPSVII.Configuration-help.xml
Module Name: AtlassianPSVII.Configuration
online version: https://atlassianps.org/docs/AtlassianPS.Configuration/commands/Set-ServerConfiguration/
locale: en-US
schema: 2.0.0
layout: documentation
permalink: /docs/AtlassianPS.Configuration/commands/Set-ServerConfiguration/
---
# Set-ServerConfiguration

## SYNOPSIS

Updates a stores Server entry.

## SYNTAX

```powershell
Set-AtlassianServerConfiguration [-Id] <UInt32> [[-Uri] <Uri>]
 [[-Name] <String>] [-Type] <ServerType> [[-Session] <WebRequestSession>]
 [[-Headers] <Hashtable>] [[-Product] <String>] [[-DeploymentType] <String>]
 [[-AuthenticationType] <String>] [[-CloudId] <String>] [[-SecretReference] <Hashtable>]
 [<CommonParameters>]
```

## DESCRIPTION

This function provides the means to change a stored server entry.

## EXAMPLES

### EXAMPLE 1

```powershell
Add-AtlassianServerConfiguration -Uri "https://server.com/" -Type "Confluence"
Set-AtlassianServerConfiguration -Id 1 -Uri "https://atlassian.net"
```

This command will replace the Uri stored of the first entry of the stored servers.

### EXAMPLE 2

```powershell
Add-AtlassianServerConfiguration -Name "My Server" -Uri "https://server.com/" -Type "Jira"
Set-AtlassianServerConfiguration -Id 1 -Name "wiki" -Type "Confluence"
```

This command will replace the Name and Type of the first entry of the stored servers.

### EXAMPLE 3

```powershell
Add-AtlassianServerConfiguration -Name "JiraServer" -Uri "https://server.com/" -Type "Jira"
Get-AtlassianServerConfiguration |
    Where Type -eq "JIRA" |
    Set-AtlassianServerConfiguration -Uri "https://atlassian.net"
```

This command will replace the Uri of all stored Jira servers with the new address.

### EXAMPLE 4

```powershell
Set-AtlassianServerConfiguration -Id 1 -DeploymentType "Cloud" -AuthenticationType "ApiToken"
```

This command updates explicit deployment and authentication metadata without changing the server address.

### EXAMPLE 5

```powershell
Set-AtlassianServerConfiguration -Id 1 -SecretReference @{ Provider = "SecretManagement"; Name = "AtlassianApiToken"; Type = "Token" }
```

This command updates the server entry to resolve authentication material from an external provider.

## PARAMETERS

### -Id

Identifier (index) of the entry to update

```yaml
Type: UInt32
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Uri

Address of the Server.

```yaml
Type: Uri
Parameter Sets: (All)
Aliases: Url, Address

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name

Name with which this server will be stored.

If no name is provided, the "Authority" of the address will be used.
This value must be unique.

In case the ServerName was already saved for another entry, an error is written and the existing entries are not changed.

Example for "Authority":
  https://**www.google.com**/maps?hl=en --> "www.google.com"

Is not case sensitive

```yaml
Type: String
Parameter Sets: (All)
Aliases: ServerName, Alias

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type

Type of the server to store.

This can be:

* Bitbucket
* Confluence
* Jira

```yaml
Type: ServerType
Parameter Sets: (All)
Aliases:
Accepted values: BITBUCKET, CONFLUENCE, JIRA

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Session

Stores a WebSession to the server object.

```yaml
Type: WebRequestSession
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Headers

Stores the Headers that should be used for this server

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Product

Optional product metadata for the server entry.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Bitbucket, Confluence, Jira

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DeploymentType

Optional deployment metadata for the server entry.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Cloud, DataCenter, Server

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AuthenticationType

Optional authentication metadata for the server entry.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Anonymous, Basic, ApiToken, OAuth, PersonalAccessToken, Session, Cookie

Required: False
Position: 9
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CloudId

Optional Atlassian Cloud ID metadata for OAuth-backed Cloud requests.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SecretReference

Optional lookup metadata for a secret stored outside the configuration file.
Supported reference metadata includes `Provider`, `Name`, `Type`, and optional non-secret `UserName`.
Do not store `Token`, `Password`, `Secret`, `Value`, `Credential`, `ApiKey`, or authorization material in this hashtable.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 11
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

## OUTPUTS

## NOTES

## RELATED LINKS

[AtlassianPSVII.ServerData](../../classes/AtlassianPSVII.ServerData/)

[Get-ServerConfiguration](../Get-ServerConfiguration/)

[Remove-ServerConfiguration](../Remove-ServerConfiguration/)

[Export-Configuration](https://github.com/PoshCode/Configuration)
