#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "6.2"; MaximumVersion = "6.999" }

Describe "ConvertTo-SecretResolution" -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
        Import-Module $script:moduleToTest
    }

    InModuleScope "AtlassianPSVII.Configuration" {
        It "converts strings to secure token results" {
            $resolved = ConvertTo-SecretResolution -Secret 'secret-value' -SecretType Token -Source Test

            $resolved.Source | Should -Be "Test"
            $resolved.SecretType | Should -Be "Token"
            $resolved.Token | Should -BeOfType [SecureString]
        }

        It "requires username metadata for credential construction" {
            {
                ConvertTo-SecretResolution `
                    -Secret ([System.Net.NetworkCredential]::new('', 'secret-value').SecurePassword) `
                    -SecretType Credential `
                    -Source Test
            } | Should -Throw "*UserName*"
        }
    }
}
