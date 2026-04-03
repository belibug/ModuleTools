function New-TestProjectRoot {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$TestDriveRoot,
        [Parameter(Mandatory)][string]$Name
    )

    $root = Join-Path $TestDriveRoot $Name
    New-Item -ItemType Directory -Path $root -Force | Out-Null

    foreach ($dir in @(
            'src/public',
            'src/public/nested',
            'src/private',
            'src/private/a',
            'src/private/b',
            'src/classes',
            'src/classes/nested',
            'docs'
        )) {
        New-Item -ItemType Directory -Path (Join-Path $root $dir) -Force | Out-Null
    }

    return $root
}

function Write-TestProjectJson {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$ProjectRoot,
        [Parameter(Mandatory)][hashtable]$Options
    )

    $project = [ordered]@{
        ProjectName = ('' + $Options.ProjectName)
        Description = 'Test project'
        Version = '0.0.1'
        copyResourcesToModuleRoot = $false
        BuildRecursiveFolders = [bool]$Options.BuildRecursiveFolders
        FailOnDuplicateFunctionNames = [bool]$Options.FailOnDuplicateFunctionNames
        Manifest = [ordered]@{
            Author = 'Test'
            PowerShellHostVersion = '7.4'
            GUID = '11111111-1111-1111-1111-111111111111'
            Tags = @()
            ProjectUri = ''
        }
    }

    $json = $project | ConvertTo-Json -Depth 10
    Set-Content -LiteralPath (Join-Path $ProjectRoot 'project.json') -Value $json -Encoding utf8
}

function Invoke-BuildAndParsePsm1Ast {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$ProjectRoot
    )

    Push-Location -LiteralPath $ProjectRoot
    try {
        Invoke-MTBuild

        $info = Get-MTProjectInfo
        $psm1 = Join-Path $ProjectRoot ("dist/{0}/{0}.psm1" -f $info.ProjectName)
        if (-not (Test-Path -LiteralPath $psm1)) {
            throw "Expected built psm1 not found: $psm1"
        }

        $tokens = $null
        $errors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($psm1, [ref]$tokens, [ref]$errors)
        if ($errors -and $errors.Count -gt 0) {
            throw "Built psm1 parse errors: $(@($errors | ForEach-Object Message) -join '; ')"
        }

        return $ast
    }
    finally {
        Pop-Location
    }
}

function Get-TopLevelFunctionAstFromAst {
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

        if (-not $nested) { $candidate }
    }

    return @($top)
}
