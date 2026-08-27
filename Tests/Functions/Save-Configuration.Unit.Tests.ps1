#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

Describe "Save-Configuration" -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
        Import-Module $script:moduleToTest
    }

    InModuleScope "AtlassianPS.Configuration" {
        BeforeEach {
            #region Mocking
            Mock Write-DebugMessage -ModuleName "AtlassianPS.Configuration" {}
            Mock Write-Verbose -ModuleName "AtlassianPS.Configuration" {}

            Mock Write-AtomicConfigurationFile -ModuleName "AtlassianPS.Configuration" {}
            Mock Configuration\Get-ConfigurationPath -ModuleName "AtlassianPS.Configuration" {
                $TestDrive
            }

            Mock Get-Configuration -ModuleName "AtlassianPS.Configuration" {
                @{
                    Foo        = "lorem ipsum"
                    Bar        = 42
                    ServerList = @(
                        [AtlassianPS.ServerData]@{
                            Id              = 1
                            Name            = "Google"
                            Uri             = "https://google.com"
                            Type            = "Jira"
                            Product         = "Jira"
                            DeploymentType  = "DataCenter"
                            SecretReference = @{
                                Provider = "Environment"
                                Name     = "ATLASSIAN_TOKEN"
                                Type     = "Token"
                            }
                        }
                        [AtlassianPS.ServerData]@{
                            Id      = 2
                            Name    = "Google with Session"
                            Uri     = "https://google.com"
                            Type    = "Jira"
                            Session = (New-Object -TypeName Microsoft.PowerShell.Commands.WebRequestSession)
                            Headers = @{
                                Accept        = 'application/json'
                                Authorization = 'Bearer secret-value'
                                Cookie        = 'session=secret-value'
                                'X-Api-Key'   = 'secret-value'
                            }
                        }
                    )
                }
            }
            #endregion Mocking
        }

        Context "Sanity checking" { }

        Context "Behavior checking" {
            It "does not fail on invocation" {
                { Save-Configuration } | Should -Not -Throw
            }

            It "writes through the atomic persistence helper" {
                Save-Configuration

                Should -Invoke "Write-AtomicConfigurationFile" -ModuleName "AtlassianPS.Configuration" -Exactly -Times 1 -Scope It
            }

            It "exports all keys in the configuration" {
                $after = Save-Configuration

                $after["Foo"] | Should -Not -BeNullOrEmpty
                $after["Foo"] | Should -BeOfType [String]
                $after["Bar"] | Should -Not -BeNullOrEmpty
                $after["Bar"] | Should -BeOfType [Int]
                $after["ServerList"] | Should -Not -BeNullOrEmpty
                ($after["ServerList"] | Select-Object -First 1) | Should -BeOfType [AtlassianPS.ServerData]
                $after["ServerList"] | Should -HaveCount 2
            }

            It "does not allow sessions to be exported" {
                $before = Get-Configuration
                $after = Save-Configuration

                $after["Foo"] | Should -BeOfType [String]
                $after["Bar"] | Should -BeOfType [Int]
                ($before["ServerList"] | Where-Object Session | Select-Object -First 1).Session.UserAgent | Should -Not -BeNullOrEmpty
                ($after["ServerList"] | Where-Object Name -eq "Google with Session" | Select-Object -First 1).Session | Should -BeNullOrEmpty
            }

            It "does not allow authentication headers or tokens to be exported" {
                $after = Save-Configuration
                $headers = (
                    $after["ServerList"] |
                        Where-Object Name -eq "Google with Session" |
                        Select-Object -First 1
                ).Headers

                $headers.Accept | Should -Be 'application/json'
                $headers.Authorization | Should -BeNullOrEmpty
                $headers.Cookie | Should -BeNullOrEmpty
                $headers.'X-Api-Key' | Should -BeNullOrEmpty
            }

            It "does not clear sessions from the live configuration" {
                $before = Get-Configuration -AsHashtable

                Save-Configuration

                ($before["ServerList"] | Where-Object Name -eq "Google with Session" | Select-Object -First 1).Session.UserAgent | Should -Not -BeNullOrEmpty
            }

            It "preserves explicit deployment metadata" {
                $after = Save-Configuration
                $server = $after["ServerList"] | Where-Object Name -eq "Google" | Select-Object -First 1

                $server.Product | Should -Be "Jira"
                $server.DeploymentType | Should -Be "DataCenter"
            }

            It "exports secret references without secret values" {
                $after = Save-Configuration
                $server = $after["ServerList"] | Where-Object Name -eq "Google" | Select-Object -First 1

                $server.SecretReference.Provider | Should -Be "Environment"
                $server.SecretReference.Name | Should -Be "ATLASSIAN_TOKEN"
                $server.SecretReference.ContainsKey("Token") | Should -BeFalse
                $server.SecretReference.ContainsKey("Value") | Should -BeFalse
                $server.SecretReference.ContainsKey("Secret") | Should -BeFalse
            }
        }
    }
}
