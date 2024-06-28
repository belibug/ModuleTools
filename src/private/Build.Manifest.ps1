function Build-Manifest {
    Write-Verbose 'Building psd1 data file Manifest'
    $data = Get-MTProjectInfo

    ## TODO - DO schema check

    $PubFunctionFiles = Get-ChildItem -Path $data.PublicDir -Filter *.ps1
    $functionToExport = @()
    $PubFunctionFiles | ForEach-Object {
        $functionToExport += Get-FunctionNameFromFile -filePath $_.FullName
    }

    $ParmsManifest = @{
        Path                  = $data.ManifestFilePSD1
        Author                = $data.Manifest.Author
        Description           = $data.Description
        FunctionsToExport     = $functionToExport
        RootModule            = "$($data.ProjectName).psm1"
        ModuleVersion         = $data.Version
        PowerShellHostVersion = $data.Manifest.PowerShellHostVersion
        Guid                  = $data.Manifest.GUID
    }
    if ($data.Manifest.Tags) { $ParmsManifest.add('Tags', $data.Manifest.Tags ) }
    if ($data.Manifest.ProjecUri) { $ParmsManifest.add('ProjectUri', $data.Manifest.ProjecUri) }
    if ($data.Manifest.LicenseUri) { $ParmsManifest.add('LicenseUri', $data.Manifest.LicenseUri) }
    if ($data.Manifest.IconUri) { $ParmsManifest.add('IconUri', $data.Manifest.IconUri) }

    try {
        New-ModuleManifest @ParmsManifest -ErrorAction Stop
    } catch {
        'Failed to create Manifest: {0}' -f $_.Exception.Message | Write-Error -ErrorAction Stop
    }
}