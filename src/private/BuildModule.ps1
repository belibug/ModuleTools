function Build-Module {
    $data = Get-MTProjectInfo
    $MTBuildVersion = (Get-Command Invoke-MTBuild).Version
    Write-Verbose "Running ModuleTols Version: $MTBuildVersion"
    Write-Verbose 'Buidling module psm1 file'
    Test-ProjectSchema -Schema Build | Out-Null

    $sb = [System.Text.StringBuilder]::new()

    $files = Get-ProjectScriptFile -ProjectInfo $data
    foreach ($file in $files) {
        $sb.AppendLine([IO.File]::ReadAllText($file.FullName)) | Out-Null
        $sb.AppendLine() | Out-Null
    }
    try {
        Set-Content -Path $data.ModuleFilePSM1 -Value $sb.ToString() -Encoding 'UTF8' -ErrorAction Stop # psm1 file
    } catch {
        Write-Error 'Failed to create psm1 file' -ErrorAction Stop
    }
}