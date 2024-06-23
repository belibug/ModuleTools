function Copy-ProjectResource {
    $data = Get-MTProjectInfo
    $resFolder = [System.IO.Path]::Join($data.ProjectRoot, 'src', 'resources')

    if (Test-Path $resFolder) {
        if (Get-ChildItem $resFolder -ErrorAction SilentlyContinue) {
            Write-Verbose 'Files found in resource folder, Copying resource folder content'
            Copy-Item -Path $resFolder -Destination ($data.OutputModuleDir) -Recurse -Force -ErrorAction Stop
        }
    }
}