# Get-AliasNamesFromFile
function Get-AliasNamesFromFile {
    param($filePath)

    $aliasesToExport = @()

    try {
        $moduleContent = Get-Content -Path $filePath -Raw
        $ast = [System.Management.Automation.Language.Parser]::ParseInput($moduleContent, [ref]$null, [ref]$null)

        # Find and add aliases defined by Set-Alias
        $outsideFunctionAliasName = (
            $ast.EndBlock.Statements
            | Where-Object { $_ -match "^\s*Set-Alias .+" }
            | ForEach-Object { $_.Extent.text }
        )

        # Parse Set-Alias statements to extract the alias name
        ForEach ($saEntry in $outsideFunctionAliasName) {
            $saParams = $saEntry -split '\s+'

            # Check if alias is defined using -Name parameter to Set-Alias
            # and if so get the alias name from the next parameter after -Name
            if ($saEntry -imatch "-na") {
                $i = 0
                $parNameLoc = 0
                # Loop through all parameters for this Set-Alias command
                ForEach ($par in $saParams) {
                    if ($par -imatch "-na") {
                        $parNameLoc = $i
                    }
                    ++$i
                }
                $aliasesToExport += $saParams[$parNameLoc + 1]
            }
            # If -Name parameter is not used then assume the alias name is the
            #   first parameter to Set-Alias
            else {
                $aliasesToExport += $saParams[1]
            }
        }

        # Find and add aliases defined by [Alias("Some-Alias")] attribute
        #  of functions
        $insideFunctionAliasName = $ast.FindAll({
            $args[0] -is [System.Management.Automation.Language.AttributeAst]}, $true)
                | Where-Object { $_.Parent.Extent.text -match '^param' }
                | Select-Object -ExpandProperty PositionalArguments
                | Select-Object -ExpandProperty Value -ErrorAction SilentlyContinue

        if ($insideFunctionAliasName) {
            $insideFunctionAliasName | ForEach-Object {
                $aliasesToExport += $_
            }
        }

        return $aliasesToExport
    }
    catch { return '' }
}