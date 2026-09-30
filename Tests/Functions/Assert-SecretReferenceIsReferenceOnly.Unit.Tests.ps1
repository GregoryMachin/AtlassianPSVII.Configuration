#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "6.2"; MaximumVersion = "6.999" }

Describe "Assert-SecretReferenceIsReferenceOnly" -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
        Import-Module $script:moduleToTest
    }

    InModuleScope "AtlassianPSVII.Configuration" {
        It "allows provider lookup metadata" {
            {
                Assert-SecretReferenceIsReferenceOnly -SecretReference @{
                    Provider = 'Environment'
                    Name     = 'ATLASSIAN_TOKEN'
                    Type     = 'Token'
                }
            } | Should -Not -Throw
        }

        It "rejects inline secret material" {
            {
                Assert-SecretReferenceIsReferenceOnly -SecretReference @{
                    Provider = 'Environment'
                    Name     = 'ATLASSIAN_TOKEN'
                    Password = 'secret-value'
                }
            } | Should -Throw "*Store only provider and lookup metadata*"
        }
    }
}
