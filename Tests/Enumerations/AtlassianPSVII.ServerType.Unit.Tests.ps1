#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.7"; MaximumVersion = "5.999" }

Describe "[AtlassianPSVII.ServerType] Tests" -Tag Unit {

    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
        Import-Module $script:moduleToTest
    }
    It "creates an [AtlassianPSVII.ServerType] from a string" {
        { [AtlassianPSVII.ServerType]"bitbucket" } | Should -Not -Throw
        { [AtlassianPSVII.ServerType]"confluence" } | Should -Not -Throw
        { [AtlassianPSVII.ServerType]"jira" } | Should -Not -Throw
    }

    It "throws when an invalid string is provided" {
        { [AtlassianPSVII.ServerType]"foo" } | Should -Throw -Because "InvalidArgument"
    }

    It "has no constructor" {
        { [AtlassianPSVII.ServerType]::new("Jira") } | Should -Throw
        { New-Object -TypeName AtlassianPSVII.ServerType -ArgumentList "Jira" } | Should -Throw
    }

    It "can enumerate it's values" {
        $values = [System.Enum]::GetNames('AtlassianPSVII.ServerType')

        $values | Should -HaveCount 3
        $values | Should -Contain "BITBUCKET"
        $values | Should -Contain "CONFLUENCE"
        $values | Should -Contain "JIRA"
    }
}
