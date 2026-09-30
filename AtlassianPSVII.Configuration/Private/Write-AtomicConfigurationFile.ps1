function Write-AtomicConfigurationFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [Hashtable]$InputObject,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$Path,

        [Parameter()]
        [ValidateRange(1, 60000)]
        [Int]$LockTimeoutMilliseconds = 5000
    )

    $parentPath = Split-Path -Path $Path -Parent
    if ([String]::IsNullOrWhiteSpace($parentPath)) {
        throw "Configuration path '$Path' must have a parent directory."
    }
    if (-not (Test-Path -LiteralPath $parentPath -PathType Container)) {
        $null = New-Item -Path $parentPath -ItemType Directory -Force
    }

    $resolvedParentPath = (Resolve-Path -LiteralPath $parentPath).ProviderPath
    $targetPath = Join-Path $resolvedParentPath (Split-Path -Path $Path -Leaf)
    $lockPath = "$targetPath.lock"
    $backupPath = "$targetPath.backup"
    $temporaryPath = Join-Path $resolvedParentPath (
        '.{0}.{1}.tmp' -f (Split-Path -Path $targetPath -Leaf), [Guid]::NewGuid().ToString('N')
    )

    $lockStream = $null
    $stopwatch = [Diagnostics.Stopwatch]::StartNew()
    while (-not $lockStream) {
        try {
            $lockStream = [IO.File]::Open(
                $lockPath,
                [IO.FileMode]::OpenOrCreate,
                [IO.FileAccess]::ReadWrite,
                [IO.FileShare]::None
            )
        }
        catch [IO.IOException] {
            if ($stopwatch.ElapsedMilliseconds -ge $LockTimeoutMilliseconds) {
                throw "Timed out waiting for the configuration lock '$lockPath'."
            }
            Start-Sleep -Milliseconds 50
        }
    }

    try {
        if (
            -not (Test-Path -LiteralPath $targetPath -PathType Leaf) -and
            (Test-Path -LiteralPath $backupPath -PathType Leaf)
        ) {
            try {
                $recoveryData = Import-Metadata -Path $backupPath -ErrorAction Stop
                if ($recoveryData -isnot [Collections.IDictionary]) {
                    throw 'The recovery file does not contain a configuration dictionary.'
                }
                [IO.File]::Move($backupPath, $targetPath)
            }
            catch {
                throw "Unable to recover interrupted configuration write from '$backupPath'. $($_.Exception.Message)"
            }
        }
        elseif (Test-Path -LiteralPath $backupPath -PathType Leaf) {
            Remove-Item -LiteralPath $backupPath -Force
        }

        Get-ChildItem `
            -LiteralPath $resolvedParentPath `
            -File `
            -Filter ".$(Split-Path -Path $targetPath -Leaf).*.tmp" `
            -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -ne $temporaryPath } |
            Remove-Item -Force -ErrorAction SilentlyContinue

        Export-Metadata `
            -InputObject $InputObject `
            -Path $temporaryPath `
            -AsHashtable `
            -ErrorAction Stop

        $serializedText = [IO.File]::ReadAllText($temporaryPath)
        $normalizedText = $serializedText -replace "`r`n", "`n" -replace "`r", "`n"
        if (-not $normalizedText.EndsWith("`n")) {
            $normalizedText += "`n"
        }
        [IO.File]::WriteAllText(
            $temporaryPath,
            ($normalizedText -replace "`n", "`r`n"),
            [Text.UTF8Encoding]::new($true)
        )
        Protect-ConfigurationFile -Path $temporaryPath

        try {
            $validated = Import-Metadata -Path $temporaryPath -ErrorAction Stop
        }
        catch {
            throw "Serialized configuration validation failed. $($_.Exception.Message)"
        }
        if ($validated -isnot [Collections.IDictionary]) {
            throw 'Serialized configuration validation failed: the document is not a dictionary.'
        }
        foreach ($requiredKey in @('Message', 'ServerList')) {
            if ($InputObject.ContainsKey($requiredKey) -and -not $validated.Contains($requiredKey)) {
                throw "Serialized configuration validation failed: key '$requiredKey' was not preserved."
            }
        }

        if (Test-Path -LiteralPath $targetPath -PathType Leaf) {
            [IO.File]::Replace($temporaryPath, $targetPath, $backupPath, $true)
        }
        else {
            [IO.File]::Move($temporaryPath, $targetPath)
        }
        Protect-ConfigurationFile -Path $targetPath

        if (Test-Path -LiteralPath $backupPath -PathType Leaf) {
            Remove-Item -LiteralPath $backupPath -Force
        }
    }
    finally {
        if (Test-Path -LiteralPath $temporaryPath -PathType Leaf) {
            Remove-Item -LiteralPath $temporaryPath -Force -ErrorAction SilentlyContinue
        }
        if ($lockStream) {
            $lockStream.Dispose()
        }
    }

    return $targetPath
}
