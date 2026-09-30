#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "6.2"; MaximumVersion = "6.999" }

Describe "[AtlassianPSVII.MessageStyle] Tests" -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
        Import-Module $script:moduleToTest
    }

    It "allows for an empty object" {
        { [AtlassianPSVII.MessageStyle]::new() } | Should -Not -Throw
        { [AtlassianPSVII.MessageStyle]@{} } | Should -Not -Throw
        { New-Object -TypeName AtlassianPSVII.MessageStyle } | Should -Not -Throw
    }

    It "converts a [Hashtable] to [AtlassianPSVII.MessageStyle]" {
        { [AtlassianPSVII.MessageStyle]@{ Indent = 0 } } | Should -Not -Throw
        { [AtlassianPSVII.MessageStyle]@{ Indent = 0; TimeStamp = $true; } } | Should -Not -Throw
        { [AtlassianPSVII.MessageStyle]@{ Indent = 0; TimeStamp = $true; BreadCrumbs = $true } } | Should -Not -Throw
        { [AtlassianPSVII.MessageStyle]@{ Indent = 0; TimeStamp = $true; BreadCrumbs = $true; FunctionName = $true } } | Should -Not -Throw
    }

    It "has a constructor" {
        { [AtlassianPSVII.MessageStyle]::new() } | Should -Not -Throw
        { [AtlassianPSVII.MessageStyle]::new(0, $true, $true, $true) } | Should -Not -Throw
        { [AtlassianPSVII.MessageStyle]::new(0, $true, $true) } | Should -Throw
        { [AtlassianPSVII.MessageStyle]::new(0, $true) } | Should -Throw
        { [AtlassianPSVII.MessageStyle]::new(0) } | Should -Throw
        { New-Object -TypeName AtlassianPSVII.MessageStyle -ArgumentList 0, $true, $true, $true } | Should -Not -Throw
    }

    It "has a string representation" {
        $object = [AtlassianPSVII.MessageStyle]@{}

        $object.ToString() | Should -Be "AtlassianPSVII.MessageStyle"
    }
}
