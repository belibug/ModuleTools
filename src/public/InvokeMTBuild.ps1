function Invoke-MTBuild {
    [CmdletBinding()]
    param (
    )
    $ErrorActionPreference = 'Stop'
    Reset-ProjectDist
    Build-Module

    $data = Get-MTProjectInfo
    if ($data.FailOnDuplicateFunctionNames) {
        Assert-BuiltModuleHasNoDuplicateFunctionName -ProjectInfo $data
    }

    Build-Manifest
    Build-Help
    Copy-ProjectResource
}