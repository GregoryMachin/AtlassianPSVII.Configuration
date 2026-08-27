---
external help file: AtlassianPS.Configuration-help.xml
Module Name: AtlassianPS.Configuration
online version: https://atlassianps.org/docs/AtlassianPS.Configuration/commands/Add-ServerConfiguration/
locale: en-US
schema: 2.0.0
layout: documentation
permalink: /docs/AtlassianPS.Configuration/commands/Add-ServerConfiguration/
---
# Add-ServerConfiguration

## SYNOPSIS

Stores a new Server entry for the module to known with what server it should talk to.

## SYNTAX

```powershell
Add-AtlassianServerConfiguration [-Uri] <Uri> [[-Name] <String>]
 [-Type] <ServerType> [[-Session] <WebRequestSession>] [[-Headers] <Hashtable>]
 [[-Product] <String>] [[-DeploymentType] <String>] [[-AuthenticationType] <String>]
 [[-CloudId] <String>] [[-SecretReference] <Hashtable>]
 [<CommonParameters>]
```

## DESCRIPTION

This function allows for several Server object to be stored in memory.
Stored servers are used by the commands in order to know with what server to communicate.

The stored servers can be exported to file with [Export-Configuration](https://github.com/PoshCode/Configuration).  
_Exported servers will be imported automatically when the module is loaded._

## EXAMPLES

### EXAMPLE 1

```powershell
Add-AtlassianServerConfiguration -Uri "https://server.com/" -Name "Server Prod" -Type "Jira"
```

This command will store the Jira server address and name in memory and allow other
commands to identify the server by the name "Server Prod"

### EXAMPLE 2

```powershell
Add-AtlassianServerConfiguration -Uri "https://server.com/" -Type "Jira"
```

This command will store the Jira server address with the name "server.com" in memory and allow other
commands to identify the server by the name "Server Prod"

### EXAMPLE 3

```powershell
Add-AtlassianServerConfiguration -Uri "https://example.atlassian.net/" -Type "Jira" -Product "Jira" -DeploymentType "Cloud" -AuthenticationType "OAuth" -CloudId "00000000-0000-0000-0000-000000000000"
```

This command stores explicit deployment metadata with the server entry so dependent modules do not need
to infer Cloud/Data Center routing or authentication behavior from the network.

### EXAMPLE 4

```powershell
Add-AtlassianServerConfiguration -Name "Example Secret Ref" -Uri "https://example.atlassian.net/" -Type "Jira" -SecretReference @{ Provider = "Environment"; Name = "ATLASSIAN_API_TOKEN"; Type = "Token" }
```

This command stores a reference to an external secret. The token value is not stored in configuration.

## PARAMETERS

### -Uri

Address of the Server.

```yaml
Type: Uri
Parameter Sets: (All)
Aliases: Url, Address

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Name

Name with which this server will be stored.

If no name is provided, the "Authority" of the address will be used.
This value must be unique.

In case the ServerName was already saved, an error is written and the existing entry is not changed.

Example for "Authority":
  `https://**www.google.com**/maps?hl=en` --> `www.google.com`

Is not case sensitive

```yaml
Type: String
Parameter Sets: (All)
Aliases: ServerName, Alias

Required: False
Position: 2
Default value: $Uri.Authority
Accept pipeline input: True (ByPropertyName)
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

Required: True
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Session

Stores a WebSession to the server object.

```yaml
Type: WebRequestSession
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Headers

Stores the Headers that should be used for this server

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: True (ByPropertyName)
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
Position: 6
Default value: None
Accept pipeline input: True (ByPropertyName)
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
Position: 7
Default value: None
Accept pipeline input: True (ByPropertyName)
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
Position: 8
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -CloudId

Optional Atlassian Cloud ID metadata for OAuth-backed Cloud requests.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: None
Accept pipeline input: True (ByPropertyName)
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
Position: 10
Default value: None
Accept pipeline input: True (ByPropertyName)
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

[AtlassianPS.ServerData](../../classes/AtlassianPS.ServerData/)

[Get-ServerConfiguration](../Get-ServerConfiguration/)

[Remove-ServerConfiguration](../Remove-ServerConfiguration/)

[Export-Configuration](https://github.com/PoshCode/Configuration)
