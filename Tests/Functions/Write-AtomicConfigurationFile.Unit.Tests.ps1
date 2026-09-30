#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

Describe "Write-AtomicConfigurationFile" -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
        Import-Module $script:moduleToTest
    }

    InModuleScope "AtlassianPSVII.Configuration" {
        BeforeEach {
            $script:configurationPath = Join-Path $TestDrive 'Configuration.psd1'
            Get-ChildItem -LiteralPath $TestDrive -Force -ErrorAction SilentlyContinue |
                Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
            $script:configuration = @{
                Message    = [AtlassianPSVII.MessageStyle]@{
                    Indent       = 2
                    TimeStamp    = $true
                    BreadCrumbs  = $false
                    FunctionName = $true
                }
                ServerList = @(
                    [AtlassianPSVII.ServerData]@{
                        Id   = 1
                        Name = 'Example'
                        Uri  = 'https://example.test'
                        Type = 'Jira'
                    }
                )
            }
        }

        It "creates and validates a first configuration write" {
            $result = Write-AtomicConfigurationFile `
                -InputObject $script:configuration `
                -Path $script:configurationPath

            $result | Should -Be $script:configurationPath
            $saved = Import-Metadata -Path $script:configurationPath
            $saved.Message | Should -BeOfType [AtlassianPSVII.MessageStyle]
            @($saved.ServerList) | Should -HaveCount 1
            $saved.ServerList[0] | Should -BeOfType [AtlassianPSVII.ServerData]
        }

        It "atomically replaces an existing configuration" {
            $null = Write-AtomicConfigurationFile `
                -InputObject $script:configuration `
                -Path $script:configurationPath
            $script:configuration.ServerList[0].Name = 'Replacement'

            $null = Write-AtomicConfigurationFile `
                -InputObject $script:configuration `
                -Path $script:configurationPath

            $saved = Import-Metadata -Path $script:configurationPath
            $saved.ServerList[0].Name | Should -Be 'Replacement'
            "$script:configurationPath.backup" | Should -Not -Exist
        }

        It "recovers a valid backup left by an interrupted replacement" {
            $backupPath = "$script:configurationPath.backup"
            Export-Metadata `
                -InputObject $script:configuration `
                -Path $backupPath `
                -AsHashtable

            $script:configuration.ServerList[0].Name = 'After recovery'
            $null = Write-AtomicConfigurationFile `
                -InputObject $script:configuration `
                -Path $script:configurationPath

            $saved = Import-Metadata -Path $script:configurationPath
            $saved.ServerList[0].Name | Should -Be 'After recovery'
            $backupPath | Should -Not -Exist
        }

        It "does not replace the current file when serialized validation fails" {
            $null = Write-AtomicConfigurationFile `
                -InputObject $script:configuration `
                -Path $script:configurationPath
            $before = [IO.File]::ReadAllBytes($script:configurationPath)
            Mock Import-Metadata -ModuleName AtlassianPSVII.Configuration {
                throw 'Invalid serialized data'
            }

            {
                Write-AtomicConfigurationFile `
                    -InputObject $script:configuration `
                    -Path $script:configurationPath
            } | Should -Throw '*Serialized configuration validation failed*'

            [IO.File]::ReadAllBytes($script:configurationPath) |
                Should -BeExactly $before
        }

        It "times out safely when another writer holds the lock" {
            $lockPath = "$script:configurationPath.lock"
            $lock = [IO.File]::Open(
                $lockPath,
                [IO.FileMode]::OpenOrCreate,
                [IO.FileAccess]::ReadWrite,
                [IO.FileShare]::None
            )
            try {
                {
                    Write-AtomicConfigurationFile `
                        -InputObject $script:configuration `
                        -Path $script:configurationPath `
                        -LockTimeoutMilliseconds 100
                } | Should -Throw '*Timed out waiting for the configuration lock*'
            }
            finally {
                $lock.Dispose()
            }

            $script:configurationPath | Should -Not -Exist
        }

        It "writes UTF-8 BOM content with consistent CRLF newlines" {
            $script:configuration.ServerList[0].Name = 'Māori'
            $null = Write-AtomicConfigurationFile `
                -InputObject $script:configuration `
                -Path $script:configurationPath

            $bytes = [IO.File]::ReadAllBytes($script:configurationPath)
            $bytes[0..2] | Should -Be @(0xEF, 0xBB, 0xBF)
            $text = [IO.File]::ReadAllText($script:configurationPath)
            $text | Should -Match 'Māori'
            $text | Should -Not -Match "(?<!`r)`n"
        }

        It "restricts file access to the current user on Windows" -Skip:(
            $PSVersionTable.PSEdition -ne 'Desktop' -and $env:OS -ne 'Windows_NT'
        ) {
            $null = Write-AtomicConfigurationFile `
                -InputObject $script:configuration `
                -Path $script:configurationPath

            $acl = Get-Acl -LiteralPath $script:configurationPath
            $acl.AreAccessRulesProtected | Should -BeTrue
            @($acl.Access).Count | Should -Be 1
            $acl.Access[0].IdentityReference.Value |
                Should -Be ([Security.Principal.WindowsIdentity]::GetCurrent().Name)
        }

        It "leaves the previous configuration intact on a protection error" {
            $null = Write-AtomicConfigurationFile `
                -InputObject $script:configuration `
                -Path $script:configurationPath
            $before = [IO.File]::ReadAllBytes($script:configurationPath)
            Mock Protect-ConfigurationFile -ModuleName AtlassianPSVII.Configuration {
                throw 'Protection failed'
            }

            {
                Write-AtomicConfigurationFile `
                    -InputObject $script:configuration `
                    -Path $script:configurationPath
            } | Should -Throw '*Protection failed*'

            [IO.File]::ReadAllBytes($script:configurationPath) |
                Should -BeExactly $before
        }
    }
}
