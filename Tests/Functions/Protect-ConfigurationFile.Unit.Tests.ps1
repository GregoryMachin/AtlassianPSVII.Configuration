#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "6.2"; MaximumVersion = "6.999" }

Describe "Protect-ConfigurationFile" -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
        Import-Module $script:moduleToTest
    }

    InModuleScope "AtlassianPSVII.Configuration" {
        It "restricts a file without changing its content" {
            $path = Join-Path $TestDrive 'Configuration.psd1'
            [IO.File]::WriteAllText($path, '@{}', [Text.UTF8Encoding]::new($true))  # BOM, on PS 5.1 and 7
            $before = [IO.File]::ReadAllBytes($path)

            Protect-ConfigurationFile -Path $path

            [IO.File]::ReadAllBytes($path) | Should -BeExactly $before
        }

        It "requires an existing file" {
            { Protect-ConfigurationFile -Path (Join-Path $TestDrive 'missing.psd1') } | Should -Throw
        }
    }
}
