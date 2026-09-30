#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

Describe "Resolve-SecretReference" -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
        Import-Module $script:moduleToTest
    }

    InModuleScope "AtlassianPSVII.Configuration" {
        BeforeEach {
            $script:environmentVariableName = "ATLASSIANPSVII_TEST_TOKEN_$([Guid]::NewGuid().ToString('N'))"
            [Environment]::SetEnvironmentVariable($script:environmentVariableName, $null)
        }

        AfterEach {
            [Environment]::SetEnvironmentVariable($script:environmentVariableName, $null)
        }

        It "returns caller-supplied credentials without prompting" {
            $securePassword = [System.Net.NetworkCredential]::new('', 'secret-value').SecurePassword
            $credential = [System.Management.Automation.PSCredential]::new(
                'user@example.test',
                $securePassword
            )

            $resolved = Resolve-SecretReference -Credential $credential

            $resolved.Source | Should -Be "Caller"
            $resolved.SecretType | Should -Be "Credential"
            $resolved.Credential | Should -Be $credential
        }

        It "returns caller-supplied secure tokens without prompting" {
            $token = [System.Net.NetworkCredential]::new('', 'secret-value').SecurePassword

            $resolved = Resolve-SecretReference -Token $token

            $resolved.Source | Should -Be "Caller"
            $resolved.SecretType | Should -Be "Token"
            $resolved.Token | Should -BeOfType [SecureString]
            $resolved.Token | Should -Not -Be "secret-value"
        }

        It "resolves environment references to SecureString tokens" {
            [Environment]::SetEnvironmentVariable($script:environmentVariableName, 'secret-value')

            $resolved = Resolve-SecretReference -SecretReference @{
                Provider = 'Environment'
                Name     = $script:environmentVariableName
                Type     = 'Token'
            }

            $resolved.Source | Should -Be "Environment"
            $resolved.SecretType | Should -Be "Token"
            $resolved.Token | Should -BeOfType [SecureString]
            $resolved.Token | Should -Not -Be "secret-value"
        }

        It "resolves environment references to credentials when username metadata is supplied" {
            [Environment]::SetEnvironmentVariable($script:environmentVariableName, 'secret-value')

            $resolved = Resolve-SecretReference -SecretReference @{
                Provider = 'Environment'
                Name     = $script:environmentVariableName
                Type     = 'Credential'
                UserName = 'user@example.test'
            }

            $resolved.SecretType | Should -Be "Credential"
            $resolved.Credential | Should -BeOfType [System.Management.Automation.PSCredential]
            $resolved.Credential.UserName | Should -Be 'user@example.test'
        }

        It "fails when an environment secret is missing without revealing the name" {
            {
                Resolve-SecretReference -SecretReference @{
                    Provider = 'Environment'
                    Name     = $script:environmentVariableName
                    Type     = 'Token'
                }
            } | Should -Throw "*provider 'Environment'*"
        }

        It "fails when SecretManagement is unavailable" {
            Mock Get-Command -ModuleName AtlassianPSVII.Configuration {
                $null
            } -ParameterFilter { $Name -eq 'Get-Secret' }

            {
                Resolve-SecretReference -SecretReference @{
                    Provider = 'SecretManagement'
                    Name     = 'AtlassianApiToken'
                    Type     = 'Token'
                }
            } | Should -Throw "*SecretManagement provider is unavailable*"
        }

        It "uses registered provider adapters" {
            $adapter = @{
                TestVault = {
                    param($SecretReference)
                    [System.Net.NetworkCredential]::new('', 'secret-value').SecurePassword
                }
            }

            $resolved = Resolve-SecretReference -SecretReference @{
                Provider = 'TestVault'
                Name     = 'AtlassianApiToken'
                Type     = 'Token'
            } -ProviderAdapter $adapter

            $resolved.Source | Should -Be "TestVault"
            $resolved.Token | Should -BeOfType [SecureString]
        }

        It "redacts provider adapter errors" {
            $adapter = @{
                TestVault = {
                    throw "backend leaked secret-value"
                }
            }

            {
                Resolve-SecretReference -SecretReference @{
                    Provider = 'TestVault'
                    Name     = 'AtlassianApiToken'
                    Type     = 'Token'
                } -ProviderAdapter $adapter
            } | Should -Throw "Secret reference resolution failed for provider 'TestVault'."
        }

        It "rejects plaintext secret material in references" {
            {
                Resolve-SecretReference -SecretReference @{
                    Provider = 'Environment'
                    Name     = 'ATLASSIAN_TOKEN'
                    Token    = 'secret-value'
                }
            } | Should -Throw "*Store only provider and lookup metadata*"
        }

        It "rejects unsupported secret reference types" {
            {
                Resolve-SecretReference -SecretReference @{
                    Provider = 'Environment'
                    Name     = 'ATLASSIAN_TOKEN'
                    Type     = 'PlainText'
                }
            } | Should -Throw "*not supported*"
        }
    }
}
