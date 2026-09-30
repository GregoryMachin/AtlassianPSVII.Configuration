function Resolve-SecretReference {
    [CmdletBinding()]
    [OutputType([Hashtable])]
    param(
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Hashtable]
        $SecretReference,

        [Parameter()]
        [Hashtable]
        $ProviderAdapter = @{},

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter()]
        [SecureString]
        $Token
    )

    process {
        if ($PSBoundParameters.ContainsKey('Credential')) {
            return @{
                Source     = 'Caller'
                SecretType = 'Credential'
                Credential = $Credential
            }
        }

        if ($PSBoundParameters.ContainsKey('Token')) {
            return @{
                Source     = 'Caller'
                SecretType = 'Token'
                Token      = $Token
            }
        }

        if (-not $SecretReference) {
            return $null
        }

        Assert-SecretReferenceIsReferenceOnly -SecretReference $SecretReference

        $provider = [String]$SecretReference.Provider
        $name = [String]$SecretReference.Name
        $secretType = if ($SecretReference.ContainsKey('Type')) { [String]$SecretReference.Type } else { 'SecureString' }
        $userName = if ($SecretReference.ContainsKey('UserName')) { [String]$SecretReference.UserName } else { $null }

        if ([String]::IsNullOrWhiteSpace($provider)) {
            throw "Secret reference is missing provider metadata."
        }
        if ([String]::IsNullOrWhiteSpace($name)) {
            throw "Secret reference is missing name metadata."
        }
        if ($secretType -notin @('SecureString', 'Token', 'Credential')) {
            throw "Secret reference type '$secretType' is not supported."
        }

        try {
            switch ($provider) {
                'Environment' {
                    $resolvedSecret = [Environment]::GetEnvironmentVariable($name)
                    if ([String]::IsNullOrEmpty($resolvedSecret)) {
                        throw "Secret reference could not be resolved by provider 'Environment'."
                    }
                    return ConvertTo-SecretResolution -Secret $resolvedSecret -SecretType $secretType -UserName $userName -Source $provider
                }
                'SecretManagement' {
                    $getSecretCommand = Get-Command -Name 'Get-Secret' -ErrorAction SilentlyContinue |
                        Select-Object -First 1
                    if (-not $getSecretCommand) {
                        throw "SecretManagement provider is unavailable."
                    }
                    $resolvedSecret = & $getSecretCommand -Name $name -ErrorAction Stop
                    return ConvertTo-SecretResolution -Secret $resolvedSecret -SecretType $secretType -UserName $userName -Source $provider
                }
                default {
                    if (-not $ProviderAdapter.ContainsKey($provider)) {
                        throw "Secret provider '$provider' is not registered."
                    }
                    $adapter = $ProviderAdapter[$provider]
                    $resolvedSecret = & $adapter -SecretReference $SecretReference
                    return ConvertTo-SecretResolution -Secret $resolvedSecret -SecretType $secretType -UserName $userName -Source $provider
                }
            }
        }
        catch {
            if (
                $_.Exception.Message -like "Secret reference*" -or
                $_.Exception.Message -like "SecretManagement provider*" -or
                $_.Exception.Message -like "Secret provider*"
            ) {
                throw
            }
            throw "Secret reference resolution failed for provider '$provider'."
        }
    }
}
