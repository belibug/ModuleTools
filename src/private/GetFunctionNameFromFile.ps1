function Get-FunctionNameFromFile {
    param($filePath)
    try {
        $moduleContent = Get-Content -Path $filePath -Raw
        $ast = [System.Management.Automation.Language.Parser]::ParseInput($moduleContent, [ref]$null, [ref]$null)
        $functionName = $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false) | ForEach-Object { $_.Name } 
        return $functionName
    }
    catch { return '' }
}