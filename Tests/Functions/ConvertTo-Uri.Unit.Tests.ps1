#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "6.2"; MaximumVersion = "6.999" }

Describe "ConvertTo-Uri" -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot/../Helpers/TestTools.ps1"
        $script:moduleToTest = Initialize-TestEnvironment
        Import-Module $script:moduleToTest
    }

    InModuleScope "AtlassianPSVII.Configuration" {
        Context "normalization" {
            It "normalizes <Name>" -TestCases @(
                @{
                    Name           = "Jira Cloud site URL"
                    Uri            = "https://Example.atlassian.net"
                    Product        = "Jira"
                    DeploymentType = "Cloud"
                    Mode           = "Site"
                    Expected       = "https://example.atlassian.net/"
                }
                @{
                    Name           = "Confluence Cloud site URL adds wiki"
                    Uri            = "https://Example.atlassian.net"
                    Product        = "Confluence"
                    DeploymentType = "Cloud"
                    Mode           = "Site"
                    Expected       = "https://example.atlassian.net/wiki/"
                }
                @{
                    Name           = "Confluence Cloud preserves wiki API path"
                    Uri            = "https://example.atlassian.net/wiki/api/v2/pages?limit=25"
                    Product        = "Confluence"
                    DeploymentType = "Cloud"
                    Mode           = "Api"
                    Expected       = "https://example.atlassian.net/wiki/api/v2/pages?limit=25"
                }
                @{
                    Name           = "Confluence Cloud prepends wiki to legacy API path"
                    Uri            = "https://example.atlassian.net/rest/api/content"
                    Product        = "Confluence"
                    DeploymentType = "Cloud"
                    Mode           = "Api"
                    Expected       = "https://example.atlassian.net/wiki/rest/api/content"
                }
                @{
                    Name           = "Data Center preserves context path"
                    Uri            = "http://jira.example.test/jira"
                    Product        = "Jira"
                    DeploymentType = "DataCenter"
                    Mode           = "Site"
                    Expected       = "http://jira.example.test/jira/"
                }
                @{
                    Name           = "Unicode and escaped segments remain valid"
                    Uri            = "https://example.atlassian.net/wiki/spaces/M%C4%81ori"
                    Product        = "Confluence"
                    DeploymentType = "Cloud"
                    Mode           = "Api"
                    Expected       = "https://example.atlassian.net/wiki/spaces/M%C4%81ori"
                }
                @{
                    Name           = "relative pagination links use the base URI"
                    Uri            = "/wiki/api/v2/pages?cursor=abc"
                    BaseUri        = "https://example.atlassian.net/wiki/api/v2/pages"
                    Product        = "Confluence"
                    DeploymentType = "Cloud"
                    Mode           = "Pagination"
                    Expected       = "https://example.atlassian.net/wiki/api/v2/pages?cursor=abc"
                }
                @{
                    Name           = "absolute pagination links preserve trusted host"
                    Uri            = "https://example.atlassian.net/rest/api/3/search?nextPageToken=abc"
                    BaseUri        = "https://example.atlassian.net/rest/api/3/search"
                    Product        = "Jira"
                    DeploymentType = "Cloud"
                    Mode           = "Pagination"
                    Expected       = "https://example.atlassian.net/rest/api/3/search?nextPageToken=abc"
                }
            ) {
                param($Uri, $Product, $DeploymentType, $Mode, $Expected, $BaseUri)

                $params = @{
                    Uri            = $Uri
                    Product        = $Product
                    DeploymentType = $DeploymentType
                    Mode           = $Mode
                }
                if ($BaseUri) {
                    $params.BaseUri = $BaseUri
                }

                (ConvertTo-Uri @params).AbsoluteUri | Should -Be $Expected
            }

            It "builds OAuth routes for Jira Cloud" {
                $result = ConvertTo-Uri `
                    -Uri "/rest/api/3/myself" `
                    -Product Jira `
                    -DeploymentType Cloud `
                    -Mode OAuth `
                    -CloudId "00000000-0000-0000-0000-000000000000"

                $result.AbsoluteUri | Should -Be "https://api.atlassian.com/ex/jira/00000000-0000-0000-0000-000000000000/rest/api/3/myself"
            }

            It "builds OAuth routes for Confluence Cloud" {
                $result = ConvertTo-Uri `
                    -Uri "api/v2/pages" `
                    -Product Confluence `
                    -DeploymentType Cloud `
                    -Mode OAuth `
                    -CloudId "00000000-0000-0000-0000-000000000000"

                $result.AbsoluteUri | Should -Be "https://api.atlassian.com/ex/confluence/00000000-0000-0000-0000-000000000000/api/v2/pages"
            }
        }

        Context "security validation" {
            It "rejects <Name>" -TestCases @(
                @{
                    Name           = "non-HTTPS Cloud endpoints"
                    Uri            = "http://example.atlassian.net"
                    Product        = "Jira"
                    DeploymentType = "Cloud"
                    Mode           = "Site"
                    Error          = "*HTTPS*"
                }
                @{
                    Name           = "embedded credentials"
                    Uri            = "https://user:pass@example.atlassian.net"
                    Product        = "Jira"
                    DeploymentType = "Cloud"
                    Mode           = "Site"
                    Error          = "*embedded credentials*"
                }
                @{
                    Name           = "path traversal segments"
                    Uri            = "https://example.atlassian.net/wiki/%2e%2e/admin"
                    Product        = "Confluence"
                    DeploymentType = "Cloud"
                    Mode           = "Api"
                    Error          = "*path traversal*"
                }
                @{
                    Name           = "fragments"
                    Uri            = "https://example.atlassian.net/wiki/api/v2/pages#token"
                    Product        = "Confluence"
                    DeploymentType = "Cloud"
                    Mode           = "Api"
                    Error          = "*fragments*"
                }
                @{
                    Name           = "untrusted absolute pagination hosts"
                    Uri            = "https://evil.example.test/wiki/api/v2/pages"
                    BaseUri        = "https://example.atlassian.net/wiki/api/v2/pages"
                    Product        = "Confluence"
                    DeploymentType = "Cloud"
                    Mode           = "Pagination"
                    Error          = "*trusted base URI host*"
                }
                @{
                    Name           = "unexpected OAuth hosts"
                    Uri            = "https://example.atlassian.net/rest/api/3/myself"
                    Product        = "Jira"
                    DeploymentType = "Cloud"
                    Mode           = "OAuth"
                    CloudId        = "00000000-0000-0000-0000-000000000000"
                    Error          = "*api.atlassian.com*"
                }
            ) {
                param($Uri, $Product, $DeploymentType, $Mode, $Error, $BaseUri, $CloudId)

                $params = @{
                    Uri            = $Uri
                    Product        = $Product
                    DeploymentType = $DeploymentType
                    Mode           = $Mode
                }
                if ($BaseUri) {
                    $params.BaseUri = $BaseUri
                }
                if ($CloudId) {
                    $params.CloudId = $CloudId
                }

                { ConvertTo-Uri @params } | Should -Throw $Error
            }

            It "requires BaseUri for relative non-OAuth links" {
                {
                    ConvertTo-Uri -Uri "/rest/api/3/search" -Product Jira -DeploymentType Cloud -Mode Pagination
                } | Should -Throw "*requires BaseUri*"
            }

            It "requires CloudId for OAuth routes" {
                {
                    ConvertTo-Uri -Uri "/rest/api/3/myself" -Product Jira -DeploymentType Cloud -Mode OAuth
                } | Should -Throw "*CloudId*"
            }
        }
    }
}
