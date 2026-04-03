function Get-OrCreateHashtableList {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][hashtable]$Index,
        [Parameter(Mandatory)][string]$Key
    )

    if (-not $Index.ContainsKey($Key)) {
        $Index[$Key] = New-Object 'System.Collections.Generic.List[object]'
    }

    return $Index[$Key]
}
