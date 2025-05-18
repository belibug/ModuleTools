function Get-FunctionNameFromFile {
    param($filePath)
    try {
        $moduleContent = Get-Content -Path $filePath -Raw
        $ast = [System.Management.Automation.Language.Parser]::ParseInput($moduleContent, [ref]$null, [ref]$null)
        $functionName = $ast.FindAll({
            $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] -and
            # Ignore Functions defined inside other Functions (e.g., nested functions or Class methods)
            ($PSVersionTable.PSVersion.Major -lt 5 -or
            $args[0].Parent -isnot [System.Management.Automation.Language.FunctionMemberAst])
        }, $false) | ForEach-Object { $_.Name }

        return $functionName
    }
    catch { return '' }
}