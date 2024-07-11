function Build-Module {
    Write-Verbose 'Buidling module psm1 file'
    $data = Get-MTProjectInfo
    Test-ProjectSchema -Schema Build | Out-Null

    $sb = [System.Text.StringBuilder]::new()

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

    <#
        In my scripts I'm using Requires to check for modules and for the Core-version of PowerShell (I only
        develop for PS7). Building the module is not possible, because all these requires are thrown in one
        psm1-file and multiple of them are not allowed. ;-)

        The following code picks up all requires, seperate them from the string, puts them at the beginning of the
        psm1-file and appends the "cleared" string (= all collected functions). This way it works like a charm and
        I can still continue to use requires instead of custom functions to check for modules and versions.
    #>

    # get content and filter out requires
    $require = Get-Content $data.ModuleFilePSM1 | Select-String -Pattern '#requires\s-' | Sort-Object
    $content = Get-Content $data.ModuleFilePSM1 | Select-String -Pattern '#requires\s-' -NotMatch

    # remove possible first spaces
    $require = $require -replace '^\s+'

    # remove possible duplicates
    $require = $require | Select-Object -Unique

    # replace file with cleared content
    Set-Content -Path $data.ModuleFilePSM1 -Value ($require | Out-String) -Encoding 'UTF8' -ErrorAction Stop
    Add-Content -Path $data.ModuleFilePSM1 -Value $content -ErrorAction Stop

}
