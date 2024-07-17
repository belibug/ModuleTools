function Build-Manifest {
    Write-Verbose 'Building psd1 data file Manifest'
    $data = Get-MTProjectInfo

    ## TODO - DO schema check

    $PubFunctionFiles = Get-ChildItem -Path $data.PublicDir -Filter *.ps1
    $functionToExport = @()
    $PubFunctionFiles | ForEach-Object {
        $functionToExport += Get-FunctionNameFromFile -filePath $_.FullName
    }

    $ManfiestAllowedParams = (Get-Command New-ModuleManifest).Parameters.Keys

    $ParmsManifest = @{
        Path              = $data.ManifestFilePSD1
        Description       = $data.Description
        FunctionsToExport = $functionToExport
        RootModule        = "$($data.ProjectName).psm1"
        ModuleVersion     = $data.Version
    }

    # Accept only valid Manifest Parameters
    $data.Manifest.Keys | ForEach-Object {
        if ( $ManfiestAllowedParams -contains $_) {
            $ParmsManifest.add($_, $data.Manifest.$_ )
        } else {
            Write-Warning "Unknown parameter $_ in Manifest"
        }
    }

    try {
        New-ModuleManifest @ParmsManifest -ErrorAction Stop
    } catch {
        'Failed to create Manifest: {0}' -f $_.Exception.Message | Write-Error -ErrorAction Stop
    }
}