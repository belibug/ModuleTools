function Copy-ProjectResource {
    $data = Get-MTProjectInfo
    $resFolder = [System.IO.Path]::Join($data.ProjectRoot, 'src', 'resources')

    if (Test-Path $resFolder) {
        $items = Get-ChildItem -Path $resFolder -ErrorAction SilentlyContinue
        if ($items) {
            Write-Verbose 'Files found in resource folder, copying resource folder content'
            foreach ($item in $items) {
                Copy-Item -Path $item.FullName -Destination ($data.OutputModuleDir) -Recurse -Force -ErrorAction Stop
            }
        }
    }
}
