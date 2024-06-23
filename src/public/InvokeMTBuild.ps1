function Invoke-MTBuild {
    [CmdletBinding()]
    param (
    )
    $ErrorActionPreference = 'Stop'
    Reset-ProjectDist
    Build-Module
    Build-Manifest
    Copy-ProjectResource
}