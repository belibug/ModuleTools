function Format-DuplicateFunctionErrorMessage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Psm1Path,
        [Parameter(Mandatory)][object[]]$DuplicateGroup,
        [hashtable]$SourceIndex
    )

    $lines = New-Object 'System.Collections.Generic.List[string]'
    $lines.Add("Duplicate top-level function names detected in built module: $Psm1Path")

    foreach ($dup in ($DuplicateGroup | Sort-Object -Property Name)) {
        $key = '' + $dup.Name
        $displayName = $dup.Group[0].Name

        $lines.Add('')
        $lines.Add("- $displayName")

        foreach ($occurrence in ($dup.Group | Sort-Object { $_.Extent.StartLineNumber })) {
            $lines.Add(("  - dist line {0}" -f $occurrence.Extent.StartLineNumber))
        }

        foreach ($sourceLine in (Get-DuplicateFunctionSourceLine -Key $key -SourceIndex $SourceIndex)) {
            $lines.Add($sourceLine)
        }
    }

    return ($lines -join "`n")
}
