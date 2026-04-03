function Get-ProjectScriptFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][pscustomobject]$ProjectInfo
    )

    $recurse = [bool]$ProjectInfo.BuildRecursiveFolders

    $ordered = New-Object 'System.Collections.Generic.List[System.IO.FileInfo]'

    $root = $ProjectInfo.ProjectRoot

    foreach ($f in (Get-OrderedScriptFileForDirectory -Directory $ProjectInfo.ClassesDir -ProjectRoot $root -Recurse:$recurse)) {
        $ordered.Add($f)
    }

    foreach ($f in (Get-OrderedScriptFileForDirectory -Directory $ProjectInfo.PublicDir -ProjectRoot $root -Recurse:$false)) {
        $ordered.Add($f)
    }

    foreach ($f in (Get-OrderedScriptFileForDirectory -Directory $ProjectInfo.PrivateDir -ProjectRoot $root -Recurse:$recurse)) {
        $ordered.Add($f)
    }

    return @($ordered)
}
