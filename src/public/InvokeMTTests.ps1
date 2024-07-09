<#
.SYNOPSIS
Runs Pester tests for using settings from project.json

.DESCRIPTION
This function runs Pester tests using the specified configuration and settings in project.json. Place all your tests in "tests" folder

.PARAMETER TagFilter
Array of tags to run, Provide the tag Pester should run

.PARAMETER ExcludeTagFilter
Array of tags to exclude, Provide the tag Pester should exclude

.EXAMPLE
Invoke-MTTest
Runs the Pester tests for the project.

.EXAMPLE
Invoke-MTTest -TagFilter "unit","integrate"
Runs the Pester tests for the project, that has tag unit or integrate

.EXAMPLE
Invoke-MTTest -ExcludeTagFilter "unit"
Runs the Pester tests for the project, excludes any test with tag unit
#>
function Invoke-MTTest {
    [CmdletBinding()]
    param (
        [string[]]$TagFilter,
        [string[]]$ExcludeTagFilter
    )
    Test-ProjectSchema Pester | Out-Null
    $Script:data = Get-MTProjectInfo 
    $pesterConfig = New-PesterConfiguration -Hashtable $data.Pester

    $testPath = './tests' 
    $pesterConfig.Run.Path = $testPath
    $pesterConfig.Run.PassThru = $true
    $pesterConfig.Run.Exit = $true
    $pesterConfig.Run.Throw = $true
    $pesterConfig.Filter.Tag = $TagFilter 
    $pesterConfig.Filter.ExcludeTag = $ExcludeTagFilter 
    $pesterConfig.TestResult.OutputPath = './dist/TestResults.xml'
    $TestResult = Invoke-Pester -Configuration $pesterConfig
    if ($TestResult.Result -ne 'Passed') {
        Write-Error 'Tests failed' -ErrorAction Stop 
        return $LASTEXITCODE
    }
}