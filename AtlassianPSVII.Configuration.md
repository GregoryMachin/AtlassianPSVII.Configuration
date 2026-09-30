# AtlassianPSVII.Configuration current state

Reviewed: 2026-07-27

## Purpose

`AtlassianPSVII.Configuration` supplies common persisted configuration and runtime helpers to AtlassianPSVII modules.
It stores named Atlassian server records, resolves default parameters and file paths, converts query strings, and centralizes compatible messaging and HTTP support.

## How it works

- The module manifest is `AtlassianPSVII.Configuration/AtlassianPSVII.Configuration.psd1`, currently version `0.2`.
- Public configuration commands read and mutate the Configuration module's in-memory data and persist changes through `Save-Configuration`.
- `Configuration.psd1` holds the persisted `Message` and `ServerList` schema.
- `AtlassianPSVII.ServerData` objects represent named endpoints and optional sessions.
- Persistence deliberately strips live `ServerList[].Session` values before export.
- `Public/SharedRuntime` and `Private/SharedRuntime` contain helpers intended for reuse by dependent modules.
- The manifest applies the `Atlassian` default command prefix and depends on `Configuration` 1.3.1.

Snapshot: branch `master`, 19 public and 11 private source files, last local commit `3cd7574` dated 2026-05-31.

## Testing and delivery

- 44 `*.Tests.ps1` files are present, including 36 named unit-test files.
- Coverage includes public/private functions, classes, enumerations, module loading, manifest/build behavior, help, examples, and tooling.
- There is intentionally no external Atlassian integration suite; this repository owns local configuration behavior rather than a product API.
- CI lints on Ubuntu, builds an artifact, and tests Windows PowerShell 5.1 plus PowerShell 7 on Windows, Ubuntu, and macOS.
- Dependencies are pinned, including Pester 5.7.1 and PSScriptAnalyzer 1.25.0.
- The documented full local gate is `Invoke-Build -Task Build, Test`, with lint run separately.

## Current strengths

- Compatibility-sensitive persistence rules are documented in `AGENTS.md`.
- Mutating commands have `ShouldProcess` support in the unreleased work.
- Tests cover duplicate servers, URI validation, pipeline behavior, empty lists, and session sanitization.
- Build and dependency tasks are converging on `AtlassianPSVII.Standards`.
- Runtime helper separation reduces coupling between configuration storage and shared utilities.

## Gaps and risks

1. The source version remains `0.2` even though the unreleased section contains substantial modernization.
   Consumers cannot rely on the improvements until a tested release is cut.
2. `FunctionsToExport = '*'` makes accidental exports possible; generate and pin the explicit public surface during build and validate the packaged manifest.
3. The persisted configuration schema has compatibility rules but no explicit schema version or migration framework.
4. Server records are generic.
   They do not model deployment type, authentication type, Cloud ID, token expiry metadata, or OAuth refresh state needed by a Cloud-first Atlassian stack.
5. Secure authentication must not be persisted as reusable plaintext or serialized live sessions.
   The current sanitization is a good start, but the supported secret-storage contract should be explicit.
6. The build still references Standards 0.1.6 while Standards is locally at 0.1.12.

## Recommended update plan

### Now

1. Release the accumulated changes after the full matrix passes, with migration notes from the last published `0.2` behavior.
2. Update the Standards dependency/action pin in one synchronized change and run `Invoke-Build -Task Lint, Build, Test`.
3. Add an explicit packaged-export test and replace wildcard exports in the release manifest.
4. Add corruption, concurrent-write, atomic-save, encoding, and interrupted-write regression tests around `Configuration.psd1`.

### Next

5. Add an additive schema version and tested migrations while preserving existing `Message` and `ServerList` data.
6. Extend server metadata additively with `Product`, `DeploymentType`, `AuthenticationType`, and optional `CloudId`.
7. Define a secret-provider interface so records contain secret references rather than tokens.
   Keep Windows Credential Manager, SecretManagement, CI environment variables, and caller-supplied credentials pluggable.
8. Define canonical URI normalization for Jira Cloud, Confluence Cloud (`/wiki`), `api.atlassian.com` OAuth routes, and Data Center context paths.
9. Add compatibility tests using both Windows PowerShell 5.1 and current PowerShell 7 serialization behavior.

## Atlassian platform context

Cloud integrations increasingly require scoped API tokens or OAuth and deployment-aware URLs.
Data Center compatibility remains transitional because affected products reach end of life on 2029-03-28:
<https://www.atlassian.com/licensing/data-center-end-of-life>

## Review boundary

This was a static review of source, tests, build scripts, and workflows.
The test suite was inventoried but not executed as part of this documentation-only change.

