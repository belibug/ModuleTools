function Copy-LibFolder {
    $data = Get-MTProjectInfo
    $libFolder = $data.LibDir
    if (Test-Path $libFolder -ErrorAction SilentlyContinue) {
        Write-Verbose 'Found lib folder, copying content to module'
        Copy-Item -Path $libFolder -Destination ($data.OutputModuleDir) -Recurse -Force -ErrorAction Stop
    }
}