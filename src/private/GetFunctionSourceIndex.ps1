function Get-FunctionSourceIndex {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][System.IO.FileInfo[]]$File
    )

    $index = @{}

    foreach ($f in $File) {
        foreach ($fn in (Get-TopLevelFunctionAstFromFile -Path $f.FullName)) {
            $key = ('' + $fn.Name).ToLowerInvariant()

            $list = Get-OrCreateHashtableList -Index $index -Key $key
            $list.Add([pscustomobject]@{
                    Path = $f.FullName
                    Line = $fn.Extent.StartLineNumber
                })
        }
    }

    return $index
}
