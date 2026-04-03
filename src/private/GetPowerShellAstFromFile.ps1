function Get-PowerShellAstFromFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Path
    )

    $tokens = $null
    $errors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref]$tokens, [ref]$errors)

    return [pscustomobject]@{
        Ast = $ast
        Errors = $errors
    }
}
