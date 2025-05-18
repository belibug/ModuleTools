# Get-AliasNamesFromFile
function Get-AliasNamesFromFile {
    param($filePath)

    $aliasToExport = @()

    try {
        $moduleContent = Get-Content -Path $filePath -Raw
        $ast = [System.Management.Automation.Language.Parser]::ParseInput($moduleContent, [ref]$null, [ref]$null)

        # Find and add aliases defined by Set-Alias
        $ast.EndBlock.Statements
        | Where-Object { $_ -match "^\s*Set-Alias .+" }
        | ForEach-Object { $_.Extent.text }
        | ForEach-Object {
            $params = $_ -split '\s+'
            # $content += "`n$_"

            if ($_ -imatch "-na") {
                # alias is defined using -Name parameter to Set-Alias
                # so get the alias name from the next parameter
                $i = 0
                $parNameLoc = 0
                ForEach ($par in $params) {
                    if ($par -imatch "-na") {
                        $parNameLoc = $i
                    }
                    ++$i
                }
                $aliasToExport += $params[$parNameLoc + 1]
            }
            else {
                $aliasToExport += $params[1]
            }
            # Write-Verbose "Content: $_"
        }

        # Find and add aliases defined by [Alias("Some-Alias")] attribute
        $insideFunctionAliasName = $ast.FindAll({
            $args[0] -is [System.Management.Automation.Language.AttributeAst]
        }, $true)
        | Where-Object { $_.Parent.Extent.text -match '^param' }
        | Select-Object -ExpandProperty PositionalArguments
        | Select-Object -ExpandProperty Value -ErrorAction SilentlyContinue

        if ($insideFunctionAliasName) {
            $insideFunctionAliasName | ForEach-Object {
                $aliasToExport += $_
            }
        }
        return $aliasToExport
    }
    catch { return '' }
}