<#
.SYNOPSIS
Runs Pester tests for using settings from project.json

.DESCRIPTION
This function runs Pester tests using the specified configuration and settings in project.json. Place all your tests in "tests" folder

.PARAMETER None
This function does not have any parameters.

.EXAMPLE
Invoke-MTTest
Runs the Pester tests for the project.
#>
function Invoke-MTTest {
    [CmdletBinding()]
    param ()
    Test-ProjectSchema Pester | Out-Null
    $Script:data = Get-MTProjectInfo 
    $pesterConfig = New-PesterConfiguration -Hashtable $data.Pester

    $testPath = './tests' 
    $pesterConfig.Run.Path = $testPath
    $pesterConfig.Run.PassThru = $true
    $pesterConfig.Run.Exit = $true
    $pesterConfig.Run.Throw = $true
    $pesterConfig.TestResult.OutputPath = './dist/TestResults.xml'
    $TestResult = Invoke-Pester -Configuration $pesterConfig
    if ($TestResult.Result -ne 'Passed') {
        Write-Error 'Tests failed' -ErrorAction Stop 
        return $LASTEXITCODE
    }
}