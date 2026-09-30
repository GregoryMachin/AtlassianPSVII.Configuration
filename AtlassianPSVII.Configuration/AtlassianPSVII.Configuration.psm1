#region Dependencies
# Load the Module's namespace from C#
if (-not("AtlassianPSVII.ServerData" -as [Type])) {
    $assemblyReferences = @(
        'Microsoft.CSharp'
        'Microsoft.PowerShell.Commands.Utility'
        'System.Management.Automation'
        'System.Runtime.Extensions'
        'System.Security.Cryptography.X509Certificates'
    )

    if ($PSVersionTable.PSEdition -eq 'Core') {
        $assemblyReferences += 'System.Security.Cryptography'
    }

    Add-Type -Path (Join-Path $PSScriptRoot AtlassianPSVII.Configuration.Types.cs) -ReferencedAssemblies $assemblyReferences
}
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Add-Type -Path (Join-Path $PSScriptRoot AtlassianPSVII.Configuration.Attributes.cs) -ReferencedAssemblies Microsoft.CSharp, Microsoft.PowerShell.Commands.Utility, System.Management.Automation, System.Runtime.Extensions, System.Security.Cryptography.X509Certificates
}

#endregion Dependencies

#region ModuleConfig
# Add our own Converters for serialization
Add-MetadataConverter @{
    [AtlassianPSVII.MessageStyle] = { "AtlassianPSVIIMessageStyle -Indent {0} -TimeStamp {1} -BreadCrumbs {2} -FunctionName {3}" -f (ConvertTo-Metadata $_.Indent), (ConvertTo-Metadata $_.TimeStamp), (ConvertTo-Metadata $_.BreadCrumbs), (ConvertTo-Metadata $_.FunctionName) }
    AtlassianPSVIIMessageStyle    = {
        param($Indent, $TimeStamp, $BreadCrumbs, $FunctionName)
        [AtlassianPSVII.MessageStyle]$PSBoundParameters
    }
    [AtlassianPSVII.ServerData]   = {
        $metadata = "AtlassianPSVIIServerData -Id {0} -Name '{1}' -Uri '{2}' -Type '{3}' -Headers {4}" -f $_.Id, $_.Name, $_.Uri, $_.Type, (ConvertTo-Metadata $_.Headers)
        foreach ($propertyName in @('Product', 'DeploymentType', 'AuthenticationType', 'CloudId', 'SecretReference')) {
            if (-not [string]::IsNullOrEmpty($_.$propertyName)) {
                $metadata += " -$propertyName {0}" -f (ConvertTo-Metadata $_.$propertyName)
            }
        }
        $metadata
    }
    AtlassianPSVIIServerData      = {
        param($Id, $Name, $Uri, $Type, $Headers, $Product, $DeploymentType, $AuthenticationType, $CloudId, $SecretReference)
        if ([string]::IsNullOrEmpty($Headers)) { $null = $PSBoundParameters.Remove('Headers') }
        if ([string]::IsNullOrEmpty($SecretReference)) { $null = $PSBoundParameters.Remove('SecretReference') }
        [AtlassianPSVII.ServerData]$PSBoundParameters
    }
}

#region LoadFunctions
$PublicFunctions = @(
    Get-ChildItem -Path "$PSScriptRoot/Public" -Recurse -File -Filter "*.ps1" -ErrorAction SilentlyContinue |
        Sort-Object -Property FullName
)
$PrivateFunctions = @(
    Get-ChildItem -Path "$PSScriptRoot/Private" -Recurse -File -Filter "*.ps1" -ErrorAction SilentlyContinue |
        Sort-Object -Property FullName
)

# Dot source the functions
foreach ($file in @($PublicFunctions + $PrivateFunctions)) {
    try {
        . $file.FullName
    }
    catch {
        $errorItem = [System.Management.Automation.ErrorRecord]::new(
            ([System.ArgumentException]"Function not found"),
            'Load.Function',
            [System.Management.Automation.ErrorCategory]::ObjectNotFound,
            $file
        )
        $errorItem.ErrorDetails = "Failed to import function $($file.BaseName)"
        throw $errorItem
    }
}
Export-ModuleMember -Function $PublicFunctions.BaseName -Alias *
#endregion LoadFunctions

# Load configuration using
# https://github.com/PoshCode/Configuration
[Hashtable]$script:Configuration = Import-Configuration -CompanyName "AtlassianPSVII" -Name "AtlassianPSVII.Configuration"
if (-not $script:Configuration) { $script:Configuration = @{} }
if (-not $script:Configuration.ContainsKey("ServerList")) {
    $script:Configuration.Add("ServerList", [System.Collections.Generic.List[AtlassianPSVII.ServerData]]::new())
}
#endregion ModuleConfig
