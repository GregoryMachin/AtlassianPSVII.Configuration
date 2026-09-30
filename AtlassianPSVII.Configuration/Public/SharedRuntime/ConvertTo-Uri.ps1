function ConvertTo-Uri {
    [CmdletBinding()]
    [OutputType([Uri])]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Uri,

        [Parameter(Mandatory)]
        [ValidateSet('Bitbucket', 'Confluence', 'Jira')]
        [String]
        $Product,

        [Parameter(Mandatory)]
        [ValidateSet('Cloud', 'DataCenter', 'Server')]
        [String]
        $DeploymentType,

        [Parameter()]
        [ValidateSet('Site', 'Api', 'OAuth', 'Pagination')]
        [String]
        $Mode = 'Site',

        [Parameter()]
        [String]
        $CloudId,

        [Parameter()]
        [String]
        $BaseUri
    )

    process {
        Test-AtlassianRawUriPathIsSafe -Uri $Uri

        $parsedUri = $null
        if (-not [Uri]::TryCreate($Uri, [UriKind]::RelativeOrAbsolute, [ref]$parsedUri)) {
            throw "Uri '$Uri' is not valid."
        }

        $base = $null
        if (-not [String]::IsNullOrWhiteSpace($BaseUri)) {
            if (-not [Uri]::TryCreate($BaseUri, [UriKind]::Absolute, [ref]$base)) {
                throw "BaseUri '$BaseUri' is not an absolute URI."
            }
            Test-AtlassianUriIsSafe -Uri $base -DeploymentType $DeploymentType -Mode Site -BaseUri $null
        }

        if ($Mode -eq 'OAuth') {
            if ($DeploymentType -ne 'Cloud') {
                throw "OAuth URI normalization is only supported for Cloud deployments."
            }
            if ([String]::IsNullOrWhiteSpace($CloudId)) {
                throw "CloudId is required for OAuth URI normalization."
            }
            if ($parsedUri.IsAbsoluteUri -and $parsedUri.Host -ne 'api.atlassian.com') {
                throw "OAuth URI normalization only allows host 'api.atlassian.com'."
            }

            $productPath = switch ($Product) {
                'Confluence' { 'confluence' }
                'Jira' { 'jira' }
                default { throw "OAuth URI normalization is not supported for product '$Product'." }
            }
            $relativePath = if ($parsedUri.IsAbsoluteUri) { $parsedUri.PathAndQuery } else { $Uri }
            $relativePath = ConvertTo-AtlassianRelativePath -Path $relativePath
            $absolute = [Uri]::new("https://api.atlassian.com/ex/$productPath/$CloudId/")
            $result = [Uri]::new($absolute, $relativePath.TrimStart('/'))
            Test-AtlassianUriIsSafe -Uri $result -DeploymentType $DeploymentType -Mode $Mode -BaseUri $null
            return $result
        }

        if (-not $parsedUri.IsAbsoluteUri) {
            if (-not $base) {
                throw "Relative URI '$Uri' requires BaseUri."
            }
            $parsedUri = [Uri]::new($base, $Uri)
        }

        Test-AtlassianUriIsSafe -Uri $parsedUri -DeploymentType $DeploymentType -Mode $Mode -BaseUri $base

        $builder = [UriBuilder]::new($parsedUri)
        $builder.Scheme = $builder.Scheme.ToLowerInvariant()
        $builder.Host = $builder.Host.ToLowerInvariant()
        if ($builder.IsDefaultPort) {
            $builder.Port = -1
        }

        if ($DeploymentType -eq 'Cloud' -and $Product -eq 'Confluence' -and $Mode -in @('Site', 'Api')) {
            $path = ConvertTo-AtlassianPath -Path $builder.Path -EnsureConfluenceWiki
            $builder.Path = $path
        }
        else {
            $builder.Path = ConvertTo-AtlassianPath -Path $builder.Path
        }

        if ($Mode -eq 'Site' -and -not $builder.Path.EndsWith('/')) {
            $builder.Path = "$($builder.Path)/"
        }

        $resultUri = $builder.Uri
        Test-AtlassianUriIsSafe -Uri $resultUri -DeploymentType $DeploymentType -Mode $Mode -BaseUri $base
        return $resultUri
    }
}

function ConvertTo-AtlassianPath {
    [CmdletBinding()]
    param(
        [Parameter()]
        [String]
        $Path,

        [Parameter()]
        [Switch]
        $EnsureConfluenceWiki
    )

    if ([String]::IsNullOrWhiteSpace($Path)) {
        $Path = '/'
    }

    $normalizedPath = $Path -replace '/{2,}', '/'
    if (-not $normalizedPath.StartsWith('/')) {
        $normalizedPath = "/$normalizedPath"
    }

    if ($EnsureConfluenceWiki -and $normalizedPath -notmatch '^/wiki(/|$)') {
        if ($normalizedPath -eq '/') {
            $normalizedPath = '/wiki/'
        }
        else {
            $normalizedPath = "/wiki$normalizedPath"
        }
    }

    return $normalizedPath
}

function ConvertTo-AtlassianRelativePath {
    [CmdletBinding()]
    param(
        [Parameter()]
        [String]
        $Path
    )

    if ([String]::IsNullOrWhiteSpace($Path)) {
        return '/'
    }
    return ($Path -replace '^[\\/]+', '')
}

function Test-AtlassianRawUriPathIsSafe {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [String]
        $Uri
    )

    $rawPath = $Uri -replace '^[a-zA-Z][a-zA-Z0-9+.-]*://[^/]*', ''
    $rawPath = ($rawPath -split '[?#]', 2)[0]
    $segments = [Uri]::UnescapeDataString($rawPath).Split(
        [Char[]]@('/', '\'),
        [StringSplitOptions]::RemoveEmptyEntries
    )
    if ($segments -contains '..') {
        throw "URI path traversal segments are not allowed."
    }
}

function Test-AtlassianUriIsSafe {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [Uri]
        $Uri,

        [Parameter(Mandatory)]
        [String]
        $DeploymentType,

        [Parameter(Mandatory)]
        [String]
        $Mode,

        [Parameter()]
        [Uri]
        $BaseUri
    )

    if (-not [String]::IsNullOrEmpty($Uri.UserInfo)) {
        throw "URI must not include embedded credentials."
    }
    if (-not [String]::IsNullOrEmpty($Uri.Fragment)) {
        throw "URI fragments are not supported for request normalization."
    }

    $segments = [Uri]::UnescapeDataString($Uri.AbsolutePath).Split(
        [Char[]]@('/'),
        [StringSplitOptions]::RemoveEmptyEntries
    )
    if ($segments -contains '..') {
        throw "URI path traversal segments are not allowed."
    }

    if ($DeploymentType -eq 'Cloud' -and $Uri.Scheme -ne 'https') {
        throw "Cloud endpoints must use HTTPS."
    }

    if ($Mode -eq 'OAuth' -and $Uri.Host -ne 'api.atlassian.com') {
        throw "OAuth URI normalization only allows host 'api.atlassian.com'."
    }

    if ($Mode -eq 'Pagination' -and $BaseUri -and $Uri.Host -ne $BaseUri.Host) {
        throw "Pagination links must remain on the trusted base URI host."
    }
}
