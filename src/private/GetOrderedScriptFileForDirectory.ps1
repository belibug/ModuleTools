function Get-OrderedScriptFileForDirectory {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Directory,
        [Parameter(Mandatory)][string]$ProjectRoot,
        [Parameter(Mandatory)][bool]$Recurse
    )

    if (-not (Test-Path -LiteralPath $Directory)) {
        return @()
    }

    $items = if ($Recurse) {
        Get-ChildItem -Path $Directory -Filter '*.ps1' -File -Recurse -ErrorAction SilentlyContinue
    }
    else {
        Get-ChildItem -Path $Directory -Filter '*.ps1' -File -ErrorAction SilentlyContinue
    }

    $root = $ProjectRoot

    return @(
        $items |
            Sort-Object -Stable -Property @(
                @{ Expression = { (Get-NormalizedRelativePath -Root $root -FullName $_.FullName).ToLowerInvariant() } },
                @{ Expression = { $_.FullName.ToLowerInvariant() } }
            )
    )
}
