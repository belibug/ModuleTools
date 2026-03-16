function Publish-MTLocal {
    [CmdletBinding()]
    param(
        [string]$ModuleDirectoryPath
    )

    if ($ModuleDirectoryPath) {
        if (-not (Test-Path $ModuleDirectoryPath -PathType Container)) {
            New-Item $ModuleDirectoryPath -ItemType Directory -Force | Out-Null
        }
    } else {
        $ModuleDirectoryPath = Get-LocalModulePath
    }

    Write-Verbose "Using $ModuleDirectoryPath as path"

    $ProjectInfo = Get-MTProjectInfo

    # Ensure module is locally built and ready
    if (-not (Test-Path $ProjectInfo.OutputModuleDir)) {
        throw 'Dist folder is empty, build the module before running publish command'
    }

    # Cleanup old files
    $OldModule = Join-Path -Path $ModuleDirectoryPath -ChildPath $ProjectInfo.ProjectName
    if (Test-Path -Path $OldModule) {
        Write-Verbose 'Removing old module files'
        Remove-Item -Recurse $OldModule -Force
    }

    # Copy New Files
    Write-Verbose 'Copying new Files'
    Copy-Item -Path $ProjectInfo.OutputModuleDir -Destination $ModuleDirectoryPath -Recurse -ErrorAction Stop
    Write-Verbose 'Module copy to local path complete, Refresh session or import module manually'
}