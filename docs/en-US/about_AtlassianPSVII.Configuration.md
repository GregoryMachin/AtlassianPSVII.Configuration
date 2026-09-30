---
Module Name: AtlassianPSVII.Configuration
online version: https://atlassianps.org/docs/AtlassianPS.Configuration/
locale: en-US
layout: documentation
permalink: /docs/AtlassianPS.Configuration/
hide: true
---
# AtlassianPSVII.Configuration

## about_AtlassianPSVII.Configuration

# SHORT DESCRIPTION

AtlassianPSVII.Configuration is a module that offers a common set of tools to the
<https://AtlassianPS.org> products to handle user-specific configuration.

# LONG DESCRIPTION

This module contains a set of cmdlets for AtlassianPSVII products,
such as JiraPSVII and ConfluencePSVII, to use for storing
and retrieving user settings.

The module shall be imported into the global scope
and thus making the configuration available across all AtlassianPSVII products
loaded into the same powershell workspace.

The module stores a Hashtable in a private variable - not available in the
global scope.
This Hashtable can be extended with virtually any key-value pair by using the
module's cmdlets.
Such a key-value pair will not produce any change in behavior of any other
cmdlet by itself; the module using this module, AtlassianPSVII.Configuration,
must implement a usage for the key-value.
A documentation of the currently implemented key-value pairs can be found in
[About AtlassianPSVII.Configuration Keys](/docs/AtlassianPS.Configuration/about/implemented-keys.html).

## Guides

<div class="reference-index">
    <a href="/docs/AtlassianPS.Configuration/about/implemented-keys.html">Implemented Keys</a>
</div>

This module stores the latest configuration in memory to disk.
By doing so, the module is able to retrieve the last known configuration when
being imported.

> AtlassianPSVII.Configuration uses
> [PoshCode/Configuration](https://github.com/PoshCode/Configuration) for importing and
> exporting the configuration.  
> Where the configuration is exported and how the configuration is imported is
> described [here](https://github.com/PoshCode/Configuration#how-it-works)

# EXAMPLES

> This example uses [ConfluencePSVII](https://atlassianps.org/docs/ConfluencePS) for illustration.  
> This example uses [splatting](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_splatting).

```powershell
Import-Module ConfluencePSVII # AtlassianPSVII.Configuration is imported automatically

$serverData = @{
    # BaseURL of the server
    Uri = "https://powershell.atlassian.net/wiki"
    # Name with which you want to address this server
    ServerName = "AtlassianPSVII - wiki"
    # Type of the Atlassian product
    Type = "Confluence"
}
Add-AtlassianServerConfiguration @serverData

Get-ConfluenceSpace -Server "AtlassianPSVII - wiki"
```

# NOTE

This project is run by the volunteer organization AtlassianPSVII.
We are always interested in hearing from new users!
Find us on GitHub or Slack, and let us know what you think.

# SEE ALSO

[Commands index](/docs/AtlassianPS.Configuration/commands/)

[Classes index](/docs/AtlassianPS.Configuration/classes/)

[Enumerations index](/docs/AtlassianPS.Configuration/enumerations/)

[AtlassianPSVII org](https://atlassianps.org)

[AtlassianPSVII Slack team](https://atlassianps.org/slack)

# KEYWORDS

- Atlassian
- AtlassianPSVII
- Atlassian Configuration
- Bitbucket Server
- BitbucketPS Server
- Confluence Server
- ConfluencePSVII Server
- Hipchat Server
- HipchatPS Server
- Jira Server
- JiraPSVII Server
