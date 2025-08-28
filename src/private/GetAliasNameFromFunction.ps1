<#
.SYNOPSIS
Retrieves information about alias in a given function/file so it can be added to module manifest

.DESCRIPTION
Adding alias to module manifest and exporting it will ensure that functions can be called using alias without importing explicitly
#>
function Get-AliasInFunctionFromFile {
    param($filePath)
    try {
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($filePath, [ref]$null, [ref]$null)

        $functionNodes = $ast.FindAll({
                param($node)
                $node -is [System.Management.Automation.Language.FunctionDefinitionAst]
            }, $true)

        $function = $functionNodes[0]
        $paramsAttributes = $function.Body.ParamBlock.Attributes 

        $aliases = ($paramsAttributes | Where-Object { $_.TypeName -like 'Alias' } | ForEach-Object PositionalArguments).Value
        $aliases
    } catch {
        return
    }
}