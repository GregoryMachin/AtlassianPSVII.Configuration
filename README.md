# [AtlassianPSVII.Configuration](https://github.com/GregoryMachin/AtlassianPSVII.Configuration)

[![GitHub release](https://img.shields.io/github/release/GregoryMachin/AtlassianPSVII.Configuration.svg?style=for-the-badge)](https://github.com/GregoryMachin/AtlassianPSVII.Configuration/releases/latest)
[![Build Status](https://img.shields.io/github/actions/workflow/status/GregoryMachin/AtlassianPSVII.Configuration/ci.yml?style=for-the-badge)](https://github.com/GregoryMachin/AtlassianPSVII.Configuration/actions/workflows/ci.yml)
![License](https://img.shields.io/badge/license-MIT-blue.svg?style=for-the-badge)

> **Fork notice:** AtlassianPSVII.Configuration is a fork of [AtlassianPS.Configuration](https://github.com/AtlassianPS/AtlassianPS.Configuration) by the [AtlassianPS](https://github.com/AtlassianPS) team (MIT License), renamed and maintained by Gregory Machin. "VII" is only part of the name: it supports Windows PowerShell 5.1 and PowerShell 7.4+, and can be loaded side by side with the upstream module.

AtlassianPSVII.Configuration is a module that offers a common set of tools to the AtlassianPSVII products to handle user-specific configuration.

It also provides a shared runtime helper surface for dependent modules. Runtime helpers are intentionally separated from configuration cmdlets under `AtlassianPSVII.Configuration/Public/SharedRuntime/` (with shared internals under `Private/SharedRuntime/`) so helper evolution stays isolated from core configuration behavior.

<!--more-->

---

## Instructions

### Installation

AtlassianPSVII.Configuration is not published to the PowerShell Gallery; use it straight from its repository:

```powershell
git clone https://github.com/GregoryMachin/AtlassianPSVII.Configuration.git
Import-Module ./AtlassianPSVII.Configuration/AtlassianPSVII.Configuration/AtlassianPSVII.Configuration.psd1
```

For the built release copy (merged module and compiled help) run `./Tools/setup.ps1` and
`Invoke-Build -Task Build` in the clone, then import `./Release/AtlassianPSVII.Configuration/AtlassianPSVII.Configuration.psd1`.

### Usage

> This example uses [ConfluencePSVII](https://github.com/GregoryMachin/ConfluencePSVII/tree/master/docs/en-US) for illustration.  
> This example uses [splatting](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_splatting).

```powershell
Import-Module ConfluencePSVII   # AtlassianPSVII.Configuration is imported automatically

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

The full documentation is in the [docs folder](https://github.com/GregoryMachin/AtlassianPSVII.Configuration/tree/master/docs/en-US) and in the console.

```powershell
# Review the help at any time!
Get-Help about_AtlassianPSVII.Configuration
Get-Command -Module AtlassianPSVII.Configuration
Get-Help Get-AtlassianServerConfiguration -Full # or any other command
```

### Contribute

Want to contribute? Great!
Contributions are welcome: open an issue or a pull request in this repository.

Check out our guidelines on [Contributing] to our modules and documentation.

## Tested on

| Configuration | Status |
| ------------- | ------ |
| Windows PowerShell v5.1 | [CI workflow](https://github.com/GregoryMachin/AtlassianPSVII.Configuration/actions/workflows/ci.yml) |
| PowerShell 7 on Windows | [CI workflow](https://github.com/GregoryMachin/AtlassianPSVII.Configuration/actions/workflows/ci.yml) |
| PowerShell 7 on Ubuntu | [CI workflow](https://github.com/GregoryMachin/AtlassianPSVII.Configuration/actions/workflows/ci.yml) |
| PowerShell 7 on macOS | [CI workflow](https://github.com/GregoryMachin/AtlassianPSVII.Configuration/actions/workflows/ci.yml) |

## Acknowledgements

* This module is a fork of [AtlassianPS.Configuration](https://github.com/AtlassianPS/AtlassianPS.Configuration); thanks to its original authors and contributors.

## Useful links

* [Source Code]
* [Latest Release]
* [Submit an Issue]
* [Contributing]
* How you can help us: [List of Issues](https://github.com/GregoryMachin/AtlassianPSVII.Configuration/issues?q=is%3Aissue+is%3Aopen+label%3Aup-for-grabs)

## Disclaimer

Hopefully this is obvious, but:

> This is an open source project (under the [MIT license]), and all contributors are volunteers. All commands are executed at your own risk. Please have good backups before you start, because you can delete a lot of stuff if you're not careful.

<!-- reference-style links -->
  [PowerShell Gallery]: https://www.powershellgallery.com/
  [Source Code]: https://github.com/GregoryMachin/AtlassianPSVII.Configuration
  [Latest Release]: https://github.com/GregoryMachin/AtlassianPSVII.Configuration/releases/latest
  [Submit an Issue]: https://github.com/GregoryMachin/AtlassianPSVII.Configuration/issues/new
  [MIT license]: https://github.com/GregoryMachin/AtlassianPSVII.Configuration/blob/master/LICENSE
  [Contributing]: .github/CONTRIBUTING.md

<!-- [//]: # (Sweet online markdown editor at http://dillinger.io) -->
<!-- [//]: # ("GitHub Flavored Markdown" https://help.github.com/articles/github-flavored-markdown/) -->
