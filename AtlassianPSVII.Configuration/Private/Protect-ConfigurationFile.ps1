function Protect-ConfigurationFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [String]$Path
    )

    $resolvedPath = (Resolve-Path -LiteralPath $Path).ProviderPath
    $isWindowsPlatform = (
        $PSVersionTable.PSEdition -eq 'Desktop' -or
        $env:OS -eq 'Windows_NT'
    )

    if ($isWindowsPlatform) {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $fileInfo = [IO.FileInfo]::new($resolvedPath)
        # .NET (PowerShell 7) exposes file ACLs through FileSystemAclExtensions; .NET Framework
        # (Windows PowerShell 5.1) has them as FileInfo instance methods instead.
        $aclExtensions = 'System.IO.FileSystemAclExtensions' -as [Type]
        $security = if ($aclExtensions) { $aclExtensions::GetAccessControl($fileInfo) } else { $fileInfo.GetAccessControl() }
        $security.SetAccessRuleProtection($true, $false)
        # On .NET (PS 7) Access is $null once inheritance is removed; @($null) would yield a null rule.
        foreach ($accessRule in @($security.Access | Where-Object { $null -ne $_ })) {
            $null = $security.RemoveAccessRuleAll($accessRule)
        }
        $security.AddAccessRule(
            [Security.AccessControl.FileSystemAccessRule]::new(
                $identity.User,
                [Security.AccessControl.FileSystemRights]::FullControl,
                [Security.AccessControl.AccessControlType]::Allow
            )
        )
        if ($aclExtensions) { $aclExtensions::SetAccessControl($fileInfo, $security) } else { $fileInfo.SetAccessControl($security) }
        return
    }

    $setUnixFileMode = [IO.File].GetMethods([Reflection.BindingFlags]'Public, Static') |
        Where-Object Name -eq 'SetUnixFileMode' |
        Select-Object -First 1
    if (-not $setUnixFileMode) {
        throw 'Restrictive configuration-file permissions are unavailable on this platform.'
    }

    $modeType = $setUnixFileMode.GetParameters()[1].ParameterType
    $mode = [Enum]::Parse($modeType, 'UserRead, UserWrite')
    $null = $setUnixFileMode.Invoke($null, @($resolvedPath, $mode))
}
