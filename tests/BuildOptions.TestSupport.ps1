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
            'tests',
            'tests/nested',
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
        Pester = [ordered]@{
            TestResult = [ordered]@{
                Enabled = $true
                OutputFormat = 'NUnitXml'
            }
            Output = [ordered]@{
                Verbosity = 'Detailed'
            }
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

function Write-TestMarkerPesterFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$FilePath,
        [Parameter(Mandatory)][pscustomobject]$TestCase
    )

    $content = @"
Describe '$($TestCase.Name)' {
    It 'imports built module and writes marker' {
        Import-Module '$($TestCase.BuiltModulePath)' -Force
        Get-Module -Name '$($TestCase.ProjectName)' | Should -Not -BeNullOrEmpty
        Set-Content -LiteralPath '$($TestCase.MarkerPath)' -Value '$($TestCase.Name)' -Encoding utf8 -NoNewline
        (Get-Content -LiteralPath '$($TestCase.MarkerPath)' -Raw) | Should -Be '$($TestCase.Name)'
    }
}
"@

    Set-Content -LiteralPath $FilePath -Value $content -Encoding utf8
}

function Invoke-TestProjectTests {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$ProjectRoot,
        [Parameter(Mandatory)][string]$ModulePath
    )

    $scriptPath = Join-Path $ProjectRoot 'Run-InvokeMTTest.ps1'
    $script = @"
`$ErrorActionPreference = 'Stop'
Import-Module '$ModulePath' -Force
Set-Location -LiteralPath '$ProjectRoot'
Invoke-MTBuild
Invoke-MTTest
"@

    Set-Content -LiteralPath $scriptPath -Value $script -Encoding utf8

    try {
        $output = & pwsh -NoLogo -NoProfile -File $scriptPath 2>&1
        [pscustomobject]@{
            ExitCode = $LASTEXITCODE
            Output = @($output)
        }
    }
    finally {
        Remove-Item -LiteralPath $scriptPath -Force -ErrorAction SilentlyContinue
    }
}

function New-TestProjectWithMarkerTests {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$TestDriveRoot,
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][bool]$BuildRecursiveFolders
    )

    $root = New-TestProjectRoot -TestDriveRoot $TestDriveRoot -Name $Name
    $projectName = $Name

    Write-TestProjectJson -ProjectRoot $root -Options @{
        ProjectName = $projectName
        BuildRecursiveFolders = $BuildRecursiveFolders
        FailOnDuplicateFunctionNames = $false
    }

    Set-Content -LiteralPath (Join-Path $root 'src/public/PublicTop.ps1') -Value 'function Invoke-PublicTop { }' -Encoding utf8

    $topMarker = Join-Path $root 'top-level-ran.txt'
    $nestedMarker = Join-Path $root 'nested-ran.txt'
    $builtModulePath = Join-Path $root ("dist/{0}/{0}.psm1" -f $projectName)

    $topLevelTest = [pscustomobject]@{
        Name = 'TopLevel'
        MarkerPath = $topMarker
        ProjectName = $projectName
        BuiltModulePath = $builtModulePath
    }
    $nestedTest = [pscustomobject]@{
        Name = 'Nested'
        MarkerPath = $nestedMarker
        ProjectName = $projectName
        BuiltModulePath = $builtModulePath
    }

    Write-TestMarkerPesterFile -FilePath (Join-Path $root 'tests/TopLevel.Tests.ps1') -TestCase $topLevelTest
    Write-TestMarkerPesterFile -FilePath (Join-Path $root 'tests/nested/Nested.Tests.ps1') -TestCase $nestedTest

    [pscustomobject]@{
        Root = $root
        TopMarker = $topMarker
        NestedMarker = $nestedMarker
    }
}

