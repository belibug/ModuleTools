function Build-Module {
    $data = Get-MTProjectInfo
    $MTBuildVersion = (Get-Command Invoke-MTBuild).Version
    Write-Verbose "Running ModuleTols Version: $MTBuildVersion"
    Write-Verbose 'Buidling module psm1 file'
    Test-ProjectSchema -Schema Build | Out-Null

    $sb = [System.Text.StringBuilder]::new()

    # Classes Folder
    $files = Get-ChildItem -Path $data.ClassesDir -Filter *.ps1 -ErrorAction SilentlyContinue
    $files | ForEach-Object {
        $sb.AppendLine([IO.File]::ReadAllText($_.FullName)) | Out-Null
    }

    # Public Folder
    $files = Get-ChildItem -Path $data.PublicDir -Filter *.ps1
    $files | ForEach-Object {
        $sb.AppendLine([IO.File]::ReadAllText($_.FullName)) | Out-Null
    }

    # Private Folder
    $files = Get-ChildItem -Path $data.PrivateDir -Filter *.ps1 -ErrorAction SilentlyContinue
    if ($files) {
        $files | ForEach-Object {
            $sb.AppendLine([IO.File]::ReadAllText($_.FullName)) | Out-Null
        }
    }
    try {
        Set-Content -Path $data.ModuleFilePSM1 -Value $sb.ToString() -Encoding 'UTF8' -ErrorAction Stop # psm1 file
    } catch {
        Write-Error 'Failed to create psm1 file' -ErrorAction Stop
    }
}