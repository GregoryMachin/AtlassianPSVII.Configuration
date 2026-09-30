function ConvertTo-URLEncoded {
    # .ExternalHelp ..\AtlassianPSVII.Configuration-help.xml
    [CmdletBinding()]
    [OutputType([String])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [String[]]
        $InputString
    )

    begin {
        Import-HttpUtility
    }

    process {
        foreach ($string in $InputString) {
            [System.Web.HttpUtility]::UrlEncode($string)
        }
    }
}
