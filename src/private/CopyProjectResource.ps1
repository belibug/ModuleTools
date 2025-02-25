function Copy-ProjectResource {
    $data = Get-MTProjectInfo
    $resFolder = [System.IO.Path]::Join($data.ProjectRoot, 'src', 'resources')
    if (Test-Path $resFolder) {
        if ($data.ResourceCopyMode -eq 'Content') {
            # Copy the resources folder content to the OutputModuleDir
            $items = Get-ChildItem -Path $resFolder -ErrorAction SilentlyContinue
            if ($items) {
                Write-Verbose 'Files found in resource folder, copying resource folder content'
                foreach ($item in $items) {
                    Copy-Item -Path $item.FullName -Destination ($data.OutputModuleDir) -Recurse -Force -ErrorAction Stop
                }
            }
        } else {
            # Copy the resources folder to the OutputModuleDir
            if (Get-ChildItem $resFolder -ErrorAction SilentlyContinue) {
                Write-Verbose 'Files found in resource folder, Copying resource folder'
                Copy-Item -Path $resFolder -Destination ($data.OutputModuleDir) -Recurse -Force -ErrorAction Stop
            }
        }
    }
}