function Save-Configuration {
    [CmdletBinding()]
    param(
        [Parameter()]
        [String]$Path,

        [Parameter()]
        [ValidateRange(1, 60000)]
        [Int]$LockTimeoutMilliseconds = 5000
    )

    begin {
        Write-Verbose "Function started"

        $configuration = Get-Configuration -AsHashtable
        $export = @{}
        foreach ($key in $configuration.Keys) {
            $export[$key] = $configuration[$key]
        }

        $serverList = [System.Collections.Generic.List[AtlassianPSVII.ServerData]]::new()
        foreach ($server in @($export["ServerList"])) {
            if (-not $server) { continue }

            $safeHeaders = @{}
            if ($server.Headers) {
                foreach ($headerName in @($server.Headers.Keys)) {
                    if ($headerName -notmatch '(?i)authorization|cookie|token|api[-_]?key|secret') {
                        $safeHeaders[$headerName] = $server.Headers[$headerName]
                    }
                }
            }

            $serverData = [AtlassianPSVII.ServerData]@{
                Id                 = $server.Id
                Name               = $server.Name
                Uri                = $server.Uri
                Type               = $server.Type
                Certificate        = $server.Certificate
                Headers            = if ($safeHeaders.Count -gt 0) { $safeHeaders } else { $null }
                Product            = $server.Product
                DeploymentType     = $server.DeploymentType
                AuthenticationType = $server.AuthenticationType
                CloudId            = $server.CloudId
                SecretReference    = $server.SecretReference
            }
            $serverList.Add($serverData)
        }
        $export["ServerList"] = $serverList

        if ([String]::IsNullOrWhiteSpace($Path)) {
            $configurationDirectory = $null
            try {
                $configurationDirectory = @(
                    Configuration\Get-ConfigurationPath `
                        -CompanyName 'AtlassianPSVII' `
                        -Name 'AtlassianPSVII.Configuration' `
                        -Scope Enterprise `
                        -ErrorAction Stop
                ) |
                    Where-Object { $_ -and -not [String]::IsNullOrWhiteSpace([String]$_) } |
                    Select-Object -Last 1
            }
            catch {
                Write-DebugMessage "Unable to resolve the Configuration module storage path. Falling back to the PowerShell user data path. $($_.Exception.Message)"
            }

            if ($configurationDirectory) {
                $configurationDirectory = [String]$configurationDirectory
            }
            if ([String]::IsNullOrWhiteSpace($configurationDirectory)) {
                $configurationDirectory = Join-Path $HOME '.local/share/powershell/AtlassianPSVII/AtlassianPSVII.Configuration'
            }

            $Path = Join-Path $configurationDirectory 'Configuration.psd1'
        }

        $null = Write-AtomicConfigurationFile `
            -InputObject $export `
            -Path $Path `
            -LockTimeoutMilliseconds $LockTimeoutMilliseconds

        Write-Verbose "Function ended"
        return $export
    }
}
