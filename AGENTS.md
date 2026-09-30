# AI Instructions for AtlassianPSVII.Configuration

> **Canonical AI guidance for this repository.**
> `CLAUDE.md`, `GEMINI.md`, `.github/copilot-instructions.md`, `.github/instructions/*.instructions.md`, and `.cursor/rules/*.mdc` must stay aligned with this file.

## Non-Negotiable Rules

1. **Ship complete vertical slices**: code, tests, docs, and changelog updates move together.
2. **Use the right test loop**: during iteration, run targeted `Invoke-Pester` for affected tests when possible (for example `Invoke-Pester -Path 'Tests/Functions/Get-Configuration.Unit.Tests.ps1'`).
3. **Do not finish on a red build**: run `Invoke-Build -Task Build, Test` at minimum before completion.
4. **Preserve persisted configuration compatibility**: do not break existing `Configuration.psd1` data.
5. **Use existing wrappers/helpers**: no ad-hoc config persistence or direct command bypasses.
6. **Validate behavior changes with tests**: update or add tests under `Tests/`.

## AI Tool Compatibility

| Tool | Entry point | Canonical references |
|------|-------------|----------------------|
| GitHub Copilot | `.github/copilot-instructions.md` | `AGENTS.md`, `.github/ai-context/powershell-rules.md` |
| GitHub Copilot (file rules) | `.github/instructions/configuration-compatibility.instructions.md` | `.github/ai-context/powershell-rules.md` |
| Cursor | `.cursor/rules/atlassianpsvii-configuration.mdc` | `AGENTS.md`, `.github/ai-context/powershell-rules.md` |
| Claude Code | `CLAUDE.md` | `AGENTS.md`, `.github/ai-context/powershell-rules.md` |
| Gemini/Antigravity | `GEMINI.md` | `AGENTS.md`, `.github/ai-context/powershell-rules.md` |

## Repository Surfaces

- Module source: `AtlassianPSVII.Configuration/Public/*.ps1`, `AtlassianPSVII.Configuration/Private/*.ps1`
- Module bootstrap and schema wiring: `AtlassianPSVII.Configuration/AtlassianPSVII.Configuration.psm1`
- Persisted defaults: `AtlassianPSVII.Configuration/Configuration.psd1`
- Build entrypoint: `AtlassianPSVII.Configuration.build.ps1`
- Tests: `Tests/**/*.ps1`
- Help sources: `docs/en-US/commands/*.md`, `docs/en-US/about_*.md`

## Configuration Schema and Compatibility Requirements

- Keep top-level configuration keys compatible with existing installs, especially `Message` and `ServerList`.
- Keep `ServerList` entries compatible with `[AtlassianPSVII.ServerData]` serialization/deserialization.
- Preserve metadata converter contracts in `AtlassianPSVII.Configuration.psm1` (`AtlassianPSVIIMessageStyle`, `AtlassianPSVIIServerData`).
- Persist config only through `Save-Configuration`; it intentionally strips `ServerList[].Session` before export.
- Do not rename/remove persisted keys or change semantics without migration coverage and regression tests.

## Wrapper and Helper Requirements

- Use `Get-Configuration`, `Set-Configuration`, `Remove-Configuration`, and `Save-Configuration` for config IO flows.
- Use the module’s private `Invoke-WebRequest` wrapper for HTTP behavior that must stay cross-version compatible.
- Keep module-qualified command wrappers mockable via `Import-MqcnAlias` when following existing helper patterns.
- Use existing error helpers (`WriteError`, `ThrowError`) for consistent error records.

## Validation Commands (run from repo root)

```powershell
./Tools/setup.ps1
Invoke-Build -Task Lint
Invoke-Build -Task Build, Test
```

Recommended focused loop while iterating:

```powershell
Invoke-Pester -Path 'Tests/Functions/Get-Configuration.Unit.Tests.ps1'
```

## Branch, Commit, and Merge Workflow

- Start each new coherent piece of work from a clean `master` branch and create a dedicated, descriptively named task branch before editing tracked files.
- Keep directly related implementation, tests, documentation, and changelog changes together on that branch; do not mix unrelated work or reuse a merged branch.
- Commit the completed work only after the repository's required focused and full validation passes.
- When a requested series has further directly related work, keep the task branch open and continue there.
- When no further related work remains and validation is green, merge the completed task branch into `master` using the repository's normal protected-branch or pull-request workflow, then verify `master` is clean.
- Do not push branches, tags, or merges to a remote unless the user explicitly requests it.

## CI/CD References

- `.github/workflows/ci.yml` is the required quality gate for runtime/code changes.
- Instruction-only changes can be skipped by CI path filters; run local validation and report exact command outcomes.
- `.github/workflows/release.yml` publishes tagged releases.
