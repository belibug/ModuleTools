function Get-NormalizedRelativePath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Root,
        [Parameter(Mandatory)][string]$FullName
    )

    $rel = [System.IO.Path]::GetRelativePath($Root, $FullName)
    $rel = $rel -replace '\\', '/'
    return $rel
}
