@{
    RootModule           = 'AtlassianPSVII.Configuration.psm1'
    ModuleVersion        = '1.0.0'
    GUID                 = '3f17d2ff-3fd0-46a8-bf56-35300ba2d24e'
    Author               = 'Lipkau'
    CompanyName          = 'AtlassianPSVII'
    Copyright            = '(c) 2018 AtlassianPSVII. All rights reserved.'
    Description          = "A module for modules - AtlasianPS modules use this to handle the user's configuration"
    RequiredModules      = @(
        @{
            ModuleName    = 'Configuration'
            ModuleVersion = '1.3.1'
        }
    )
    FormatsToProcess     = @('AtlassianPSVII.Configuration.format.ps1xml')
    FunctionsToExport    = @(
        'Add-ServerConfiguration'
        'Get-Configuration'
        'Get-ServerConfiguration'
        'Remove-Configuration'
        'Remove-ServerConfiguration'
        'Set-Configuration'
        'Set-ServerConfiguration'
        'ConvertFrom-QueryString'
        'ConvertFrom-URLEncoded'
        'ConvertTo-Hashtable'
        'ConvertTo-QueryString'
        'ConvertTo-Uri'
        'ConvertTo-URLEncoded'
        'Join-Hashtable'
        'Resolve-DefaultParameterValue'
        'Resolve-FilePath'
        'Resolve-SecretReference'
        'Write-DebugMessage'
        'Write-NonTerminatingError'
        'Write-TerminatingError'
        'Write-VerboseMessage'
    )
    CmdletsToExport      = @()
    VariablesToExport    = @()
    AliasesToExport      = @()
    PrivateData          = @{
        PSData = @{
            Tags         = @(
                'AtlassianPSVII'
                'Configuration'
            )
            LicenseUri   = 'https://github.com/AtlassianPS/AtlassianPS.Configuration/blob/master/LICENSE'
            ProjectUri   = 'https://github.com/AtlassianPS/AtlassianPS.Configuration'
            IconUri      = 'https://atlassianps.org/assets/img/AtlassianPS.Configuration.png'
            ReleaseNotes = 'https://github.com/AtlassianPS/AtlassianPS.Configuration/blob/master/CHANGELOG.md'
            Prerelease   = ''
        }
    }
    HelpInfoURI          = 'https://atlassianps.org/docs/AtlassianPS.Configuration/'
    DefaultCommandPrefix = 'Atlassian'
}
