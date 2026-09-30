#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "6.2"; MaximumVersion = "6.999" }

Describe "[AtlassianPSVII.ServerData] Tests" -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
        Import-Module $script:moduleToTest

        $script:certificate = $null
        $script:session = $null

        # ARRANGE
        $testPath = (Get-PSDrive TestDrive).Root
        if (Get-Command openssl -ErrorAction SilentlyContinue) {
            openssl req -x509 -newkey rsa:4096 -sha256 -keyout "$testPath/openssl.key" -out "$testPath/openssl.crt" -subj "/CN=company.co.nz" -days 600 -passout pass:"hunter2"
            $script:certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList "$testPath/openssl.crt"
        }
        else {
            $script:certificate = Get-ChildItem -Path "Cert:\LocalMachine\" -Recurse |
                Where-Object { $_.GetType().Name -eq "X509Certificate2" } |
                Select-Object -First 1
        }

        $script:session = New-Object -TypeName Microsoft.PowerShell.Commands.WebRequestSession
    }
    It "does not allow for an empty object" {
        { [AtlassianPSVII.ServerData]::new() } | Should -Throw
        { [AtlassianPSVII.ServerData]@{} } | Should -Throw
        { New-Object -TypeName AtlassianPSVII.ServerData } | Should -Throw
    }

    It "throws an error if incomplete data is provided" {
        $message = "*Must contain Id, Name, Uri and Type.*"

        { [AtlassianPSVII.ServerData]@{ } } | Should -Throw $message
        { [AtlassianPSVII.ServerData]@{ Id = 1 } } | Should -Throw $message
        { [AtlassianPSVII.ServerData]@{ Name = "Name" } } | Should -Throw $message
        { [AtlassianPSVII.ServerData]@{ Uri = "https://google.com" } } | Should -Throw $message
        { [AtlassianPSVII.ServerData]@{ Type = "Jira" } } | Should -Throw $message
        { [AtlassianPSVII.ServerData]@{ Session = $script:session } } | Should -Throw $message
        { [AtlassianPSVII.ServerData]@{ Certificate = [System.Security.Cryptography.X509Certificates.X509Certificate]$script:certificate } } | Should -Throw $message
        { [AtlassianPSVII.ServerData]@{ Name = "Name"; Uri = "https://google.com" } } | Should -Throw $message
    }

    It "converts a [Hashtable] to [AtlassianPSVII.ServerData]" {
        { [AtlassianPSVII.ServerData]@{ Id = 1; Name = "Name"; Uri = "https://google.com"; Type = "Jira" } } | Should -Not -Throw
        { [AtlassianPSVII.ServerData]@{ Id = 1; Name = "Name"; Uri = "https://google.com"; Type = "Jira"; Session = $script:session } } | Should -Not -Throw
        { [AtlassianPSVII.ServerData]@{ Id = 1; Name = "Name"; Uri = "https://google.com"; Type = "Jira"; Session = $script:session; Headers = @{ } } } | Should -Not -Throw
        { [AtlassianPSVII.ServerData]@{ Id = 1; Name = "Name"; Uri = "https://google.com"; Type = "Jira"; Session = $script:session; Certificate = [System.Security.Cryptography.X509Certificates.X509Certificate]$script:certificate ; Headers = @{ } } } | Should -Not -Throw
    }

    It "has a constructor" {
        { [AtlassianPSVII.ServerData]::new(1, "Name", "https://google.com", "Jira") } | Should -Not -Throw
        { New-Object -TypeName AtlassianPSVII.ServerData -ArgumentList 1, "Name", "https://google.com", "Jira" } | Should -Not -Throw
    }

    It "has a string representation" {
        $object = [AtlassianPSVII.ServerData]@{ Id = 1; Name = "Name"; Uri = "https://google.com"; Type = "Jira" }

        $object.ToString() | Should -Be "Name (https://google.com/)"
    }

    Context "Types of properties" {
        BeforeAll {
            $script:object = [AtlassianPSVII.ServerData]@{
                Id          = 1
                Name        = "Name"
                Uri         = "https://google.com"
                Type        = "Jira"
                Session     = $script:session
                Certificate = [System.Security.Cryptography.X509Certificates.X509Certificate]$script:certificate
                Headers     = @{ }
            }
        }

        It "has a Id of type UInt32" {
            $object.Id | Should -BeOfType [UInt32]
        }

        It "has a Name of type String" {
            $object.Name | Should -BeOfType [String]
        }

        It "has a Uri of type Uri" {
            $object.Uri | Should -BeOfType [Uri]
        }

        It "has a Certificate of type X509Certificate" {
            $object.Certificate | Should -BeOfType [X509Certificate]
        }

        It "has a Type of type AtlassianPSVII.ServerType" {
            $object.Type | Should -BeOfType [AtlassianPSVII.ServerType]
        }
    }
}
