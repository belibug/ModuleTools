function Get-TopLevelFunctionAst {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][System.Management.Automation.Language.Ast]$Ast
    )

    $all = @($Ast.FindAll({
                param($n)
                $n -is [System.Management.Automation.Language.FunctionDefinitionAst]
            }, $true))

    $top = foreach ($candidate in $all) {
        $nested = $false
        foreach ($other in $all) {
            if ($other -eq $candidate) { continue }

            if ($other.Extent.StartOffset -lt $candidate.Extent.StartOffset -and $other.Extent.EndOffset -gt $candidate.Extent.EndOffset) {
                $nested = $true
                break
            }
        }

        if (-not $nested) {
            $candidate
        }
    }

    return @($top)
}
