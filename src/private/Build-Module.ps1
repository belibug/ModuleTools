function Build-Module {
    Write-Verbose 'Buidling module psm1 file'
    $data = Get-MTProjectInfo
    Test-ProjectSchema -Schema Build | Out-Null

    $sb = [System.Text.StringBuilder]::new()

    # Public Folder
    $files = Get-ChildItem -Recurse -Path $data.PublicDir -Filter *.ps1
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