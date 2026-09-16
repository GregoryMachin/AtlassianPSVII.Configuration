@{
    RootModule           = 'AtlassianPS.Configuration.psm1'
    ModuleVersion        = '0.2'
    GUID                 = 'f946e1f7-ed4f-43da-aa24-6d57a25117cb'
    Author               = 'Lipkau'
    CompanyName          = 'AtlassianPS'
    Copyright            = '(c) 2018 AtlassianPS. All rights reserved.'
    Description          = "A module for modules - AtlasianPS modules use this to handle the user's configuration"
    RequiredModules      = @(
        @{
            ModuleName    = 'Configuration'
            ModuleVersion = '1.3.1'
        }
    )
    FormatsToProcess     = @('AtlassianPS.Configuration.format.ps1xml')
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
                'AtlassianPS'
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
