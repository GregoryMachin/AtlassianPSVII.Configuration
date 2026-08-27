function Assert-SecretReferenceIsReferenceOnly {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [Hashtable]
        $SecretReference
    )

    $blockedKeys = @('Secret', 'Value', 'Token', 'Password', 'Credential', 'ApiKey', 'Authorization')
    foreach ($key in @($SecretReference.Keys)) {
        if ($key -in $blockedKeys) {
            throw "Secret reference contains secret material in key '$key'. Store only provider and lookup metadata."
        }
    }
}

