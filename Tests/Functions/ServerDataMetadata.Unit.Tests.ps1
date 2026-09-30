#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

Describe "ServerData deployment metadata" -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
        Import-Module $script:moduleToTest
    }

    InModuleScope "AtlassianPSVII.Configuration" {
        It "deserializes legacy records without deployment metadata" {
            $server = [AtlassianPSVII.ServerData]@{
                Id   = 1
                Name = "Legacy"
                Uri  = "https://legacy.example.test"
                Type = "Jira"
            }

            $server.Product | Should -BeNullOrEmpty
            $server.DeploymentType | Should -BeNullOrEmpty
            $server.AuthenticationType | Should -BeNullOrEmpty
            $server.CloudId | Should -BeNullOrEmpty
            $server.SecretReference | Should -BeNullOrEmpty
        }

        It "deserializes records with deployment metadata" {
            $server = [AtlassianPSVII.ServerData]@{
                Id                 = 1
                Name               = "Cloud Jira"
                Uri                = "https://example.atlassian.net"
                Type               = "Jira"
                Product            = "Jira"
                DeploymentType     = "Cloud"
                AuthenticationType = "OAuth"
                CloudId            = "00000000-0000-0000-0000-000000000000"
                SecretReference    = @{
                    Provider = "Environment"
                    Name     = "ATLASSIAN_TOKEN"
                    Type     = "Token"
                }
            }

            $server.Product | Should -Be "Jira"
            $server.DeploymentType | Should -Be "Cloud"
            $server.AuthenticationType | Should -Be "OAuth"
            $server.CloudId | Should -Be "00000000-0000-0000-0000-000000000000"
            $server.SecretReference.Provider | Should -Be "Environment"
            $server.SecretReference.Name | Should -Be "ATLASSIAN_TOKEN"
        }

        It "preserves unknown enum-like values loaded from existing configuration" {
            $server = [AtlassianPSVII.ServerData]@{
                Id                 = 1
                Name               = "Future Product"
                Uri                = "https://future.example.test"
                Type               = "Jira"
                Product            = "Compass"
                DeploymentType     = "SovereignCloud"
                AuthenticationType = "FutureAuth"
                CloudId            = "future-cloud-id"
            }

            $server.Product | Should -Be "Compass"
            $server.DeploymentType | Should -Be "SovereignCloud"
            $server.AuthenticationType | Should -Be "FutureAuth"
            $server.CloudId | Should -Be "future-cloud-id"
        }

        It "round-trips deployment metadata through the metadata converter" {
            $server = [AtlassianPSVII.ServerData]@{
                Id                 = 1
                Name               = "Cloud Jira"
                Uri                = "https://example.atlassian.net"
                Type               = "Jira"
                Product            = "Jira"
                DeploymentType     = "Cloud"
                AuthenticationType = "OAuth"
                CloudId            = "00000000-0000-0000-0000-000000000000"
                SecretReference    = @{
                    Provider = "Environment"
                    Name     = "ATLASSIAN_TOKEN"
                    Type     = "Token"
                }
            }

            $configurationPath = Join-Path $TestDrive 'Configuration.psd1'
            Export-Metadata -Path $configurationPath -InputObject @{ ServerList = @($server) }
            $roundTripped = (Import-Metadata -Path $configurationPath).ServerList[0]

            $roundTripped | Should -BeOfType [AtlassianPSVII.ServerData]
            $roundTripped.Product | Should -Be "Jira"
            $roundTripped.DeploymentType | Should -Be "Cloud"
            $roundTripped.AuthenticationType | Should -Be "OAuth"
            $roundTripped.CloudId | Should -Be "00000000-0000-0000-0000-000000000000"
            $roundTripped.SecretReference.Provider | Should -Be "Environment"
            $roundTripped.SecretReference.Name | Should -Be "ATLASSIAN_TOKEN"
        }
    }
}
