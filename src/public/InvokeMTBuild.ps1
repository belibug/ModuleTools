<#
.SYNOPSIS
    Invokes the process to build a module in ModuleTools format.

.DESCRIPTION
    This function is used to build a module, dist folder is cleaned up and whole module is build from scracth. copies all necessary resource files.

.PARAMETER None
    This function does not accept any parameters.

.EXAMPLE
    Invoke-MTBuild
    Invokes the process to build a module.
#>
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