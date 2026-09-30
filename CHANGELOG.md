# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/),
and this project adheres to [Semantic Versioning](http://semver.org/).

## Unreleased

## 0.3 - 2026-09-17

### Improvements

- Bumped the `AtlassianPSVII.Standards` pin from `0.1.11` to a locally built `0.2.0`, resolved via a sibling `.local-modules/` directory rather than the real PowerShell Gallery (this fork's own local development has no relationship to the real, independently published `AtlassianPSVII.Standards` release line). `Tools/setup.ps1` and the hard `#requires` pin in `AtlassianPSVII.Configuration.build.ps1` both now resolve `0.2.0`.
- Declared the source manifest's `FunctionsToExport`/`CmdletsToExport`/`VariablesToExport`/`AliasesToExport` explicitly instead of `'*'` (Phase 9 Task 58), making the manifest's `FunctionsToExport` this module's committed compatibility baseline, and added a new `Tests/Project.Tests.ps1` assertion that fails the build if the declared list drifts from the actual `Public/` folder contents. Module behavior is unchanged: `AtlassianPSVII.Configuration.psm1` already restricted runtime exports to `Public/*.ps1` via `Export-ModuleMember`, and no cmdlet, variable, or persistent alias was ever actually exported despite the wildcards.
- Added `-WhatIf` and `-Confirm` support to mutating configuration and server configuration commands.
- Migrated `Tools/setup.ps1` to shared `AtlassianPSVII.Standards` bootstrap/dependency commands with synchronized ScriptAnalyzer settings.
- Migrated `Tools/update.dependencies.ps1` to shared `AtlassianPSVII.Standards\Update-AtlassianPSVIIDependencyReference` with `ShouldProcess` and fail-fast behavior.
- Aligned workflow setup pins and build/release standards version references to `AtlassianPSVII.Standards` `0.1.11`.
- Added regression coverage for setup/update delegation and cross-surface standards version consistency.
- Aligned build lint/publish tasks with JiraPSVII north-star shared helpers (`Invoke-AtlassianPSVIILint`, `Publish-AtlassianPSVIIModuleRelease`, `New-AtlassianPSVIIModulePackage`) and updated release workflow to call `Invoke-Build -Task Publish`.
- Added release changelog extraction to publish workflow and attached changelog body to the GitHub release.
- Wired `changelog-to-release` to `./.github/changelog.configuration.json` for JiraPSVII-parity release note rendering.
- Added `PrivateData.PSData.Prerelease` to the module manifest and regression checks so release publish/version tasks cannot fail on missing prerelease metadata.
- Removed smoke and placeholder integration test surfaces to keep this repository focused on unit/build validation.
- Removed build-time `ModuleVersion` mutation from `UpdateManifest`; release version updates now remain publish-scoped through `SetVersion`.
- Added optional server deployment metadata fields for product, deployment type, authentication type, and Cloud ID.
- Added secret-reference metadata and a provider-neutral resolver for caller-supplied, environment, SecretManagement, and custom adapter secrets without persisting secret values.
- Added product-aware Atlassian URI normalization for Cloud, Data Center, OAuth, and pagination request boundaries.

### Changed

- Added a dedicated shared runtime helper surface in `Public/SharedRuntime` and `Private/SharedRuntime`.
- Added `Write-VerboseMessage` as a public shared runtime helper for formatted verbose output without shadowing PowerShell's built-in `Write-Verbose`.
- Moved shared runtime helper implementations from `AtlassianPSVII.Standards` into `AtlassianPSVII.Configuration` to keep standards tooling-focused.

### Fixed

- Preserved in-memory server sessions while exporting sanitized configuration.
- Fixed server add/remove/update edge cases around duplicate names, pipeline input, URI validation, and empty server lists.
- Protected the internal `ServerList` key from generic configuration mutation while keeping `Message` configurable.
- Corrected first-use and command documentation for server configuration commands.

## 0.2 - 2018-10-03

### Changed

- Configuration is now persisted to disk with every change to it.

### Removed

- `Export-Configuration`

## 0.1 - 2018-07-17

This is a **Pre-Release**

This version the first pre-release version.
This release enables the development of the first integrations with other
modules.
Once the modules successfully implement this, it will be released with version
1.0.

<!-- Template
## x.x - YYYY-MM-DD

### FEATURES

### IMPROVEMENTS

### BUG FIXES
-->
