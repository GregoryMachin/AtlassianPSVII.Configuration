---
Module Name: AtlassianPSVII.Configuration
online version: https://github.com/GregoryMachin/AtlassianPSVII.Configuration/blob/master/docs/en-US/about_AtlassianPSVII.Configuration_Keys.md
locale: en-US
---
# AtlassianPSVII.Configuration Implemented Keys

## about_AtlassianPSVII.Configuration_Keys

# SHORT DESCRIPTION

This article documents the Keys that AtlassianPSVII.Configuration supports and
how they are used.

# LONG DESCRIPTION

Here is the list of the currently supported Keys:

## ServerList

Is a list of servers currently stored by the user.
Server entries can include optional `Product`, `DeploymentType`, `AuthenticationType`, `CloudId`, and `SecretReference`
metadata. These fields are caller-controlled configuration and should not be overwritten by server
auto-detection when explicitly set.
`SecretReference` stores provider lookup metadata only. Secret values must remain outside `Configuration.psd1`.

> ServerData objects are describe here:  
> <https://github.com/GregoryMachin/AtlassianPSVII.Configuration/blob/master/docs/en-US/classes/AtlassianPSVII.ServerData.md>

```yaml
DataType: AtlassianPSVII.ServerData
Allowed Values: any
Used By: none yet
```

## Message

Is a [AtlassianPSVII.MessageStyle](../classes/AtlassianPSVII.MessageStyle/) which
describes the user's preference on how to see verbose and debug messages.

```yaml
DataType: AtlassianPSVII.MessageStyle
Allowed Values: any
Used By: none yet
```

# NOTE

In case you find that this document is not be up-to-date,
please let us know on github as an
[issue](https://github.com/GregoryMachin/AtlassianPSVII.Configuration/issues/new).

# RELATED LINKS

[AtlassianPSVII.MessageStyle](../classes/AtlassianPSVII.MessageStyle/)
