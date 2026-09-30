function ConvertTo-SecretResolution {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingConvertToSecureStringWithPlainText',
        '',
        Justification = 'Converts externally resolved non-persisted secret material into SecureString for in-memory handoff.'
    )]
    [CmdletBinding()]
    [OutputType([Hashtable])]
    param(
        [Parameter(Mandatory)]
        [Object]
        $Secret,

        [Parameter(Mandatory)]
        [ValidateSet('SecureString', 'Token', 'Credential')]
        [String]
        $SecretType,

        [Parameter()]
        [String]
        $UserName,

        [Parameter(Mandatory)]
        [String]
        $Source
    )

    if ($Secret -is [Hashtable]) {
        if ($Secret.ContainsKey('Credential')) {
            $Secret = $Secret.Credential
            $SecretType = 'Credential'
        }
        elseif ($Secret.ContainsKey('Token')) {
            $Secret = $Secret.Token
            $SecretType = 'Token'
        }
        elseif ($Secret.ContainsKey('Secret')) {
            $Secret = $Secret.Secret
        }
    }

    if ($Secret -is [System.Management.Automation.PSCredential]) {
        return @{
            Source     = $Source
            SecretType = 'Credential'
            Credential = $Secret
        }
    }

    if ($Secret -is [String]) {
        if ([String]::IsNullOrEmpty($Secret)) {
            throw "Secret reference resolved to an empty value."
        }
        $Secret = ConvertTo-SecureString -String $Secret -AsPlainText -Force
    }

    if ($Secret -isnot [SecureString]) {
        throw "Secret reference resolved to an unsupported secret type."
    }

    if ($SecretType -eq 'Credential') {
        if ([String]::IsNullOrWhiteSpace($UserName)) {
            throw "Credential secret references require non-secret UserName metadata."
        }
        return @{
            Source     = $Source
            SecretType = 'Credential'
            Credential = [System.Management.Automation.PSCredential]::new($UserName, $Secret)
        }
    }

    return @{
        Source     = $Source
        SecretType = $SecretType
        Token      = $Secret
    }
}

