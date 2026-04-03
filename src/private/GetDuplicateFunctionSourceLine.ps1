function Get-DuplicateFunctionSourceLine {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Key,
        [hashtable]$SourceIndex
    )

    if (-not $SourceIndex) {
        return @()
    }

    if (-not $SourceIndex.ContainsKey($Key)) {
        return @()
    }

    $lines = New-Object 'System.Collections.Generic.List[string]'
    $lines.Add('  - source files:')

    foreach ($src in ($SourceIndex[$Key] | Sort-Object Path, Line)) {
        $lines.Add(("    - {0}:{1}" -f $src.Path, $src.Line))
    }

    return @($lines)
}
