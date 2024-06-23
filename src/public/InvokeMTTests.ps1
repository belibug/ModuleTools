function Invoke-MTTest {
    [CmdletBinding()]
    param ()
    Test-ProjectSchema Pester
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