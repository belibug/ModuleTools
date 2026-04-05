function Invoke-MTTest {
    [CmdletBinding()]
    param (
        [string[]]$TagFilter,
        [string[]]$ExcludeTagFilter
    )
    Test-ProjectSchema Pester | Out-Null
    $Script:data = Get-MTProjectInfo
    $pesterConfig = New-PesterConfiguration -Hashtable $data.Pester

    $testPath = if ($data.BuildRecursiveFolders) {
        $data.TestsDir
    }
    else {
        [System.IO.Path]::Join($data.TestsDir, '*.Tests.ps1')
    }

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