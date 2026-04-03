function Assert-BuiltModuleHasNoDuplicateFunctionName {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][pscustomobject]$ProjectInfo
    )

    $psm1Path = $ProjectInfo.ModuleFilePSM1
    if (-not (Test-Path -LiteralPath $psm1Path)) {
        throw "Built module file not found: $psm1Path"
    }

    $parsed = Get-PowerShellAstFromFile -Path $psm1Path
    if ($parsed.Errors -and $parsed.Errors.Count -gt 0) {
        $messages = @($parsed.Errors | ForEach-Object { $_.Message }) -join '; '
        throw "Built module contains parse errors and cannot be validated for duplicates. File: $psm1Path. Errors: $messages"
    }

    $topLevelFunctions = Get-TopLevelFunctionAst -Ast $parsed.Ast
    $duplicates = Get-DuplicateFunctionGroup -FunctionAst $topLevelFunctions

    if (-not $duplicates) {
        return
    }

    $sourceFiles = Get-ProjectScriptFile -ProjectInfo $ProjectInfo
    $sourceIndex = Get-FunctionSourceIndex -File $sourceFiles

    $errorText = Format-DuplicateFunctionErrorMessage -Psm1Path $psm1Path -DuplicateGroup $duplicates -SourceIndex $sourceIndex
    throw $errorText
}
