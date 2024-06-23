function Get-MTProjectInfo {
    $Out = @{}
    $ProjectRoot = Get-Location | Convert-Path
    $Out['ProjecJSON'] = Join-Path -Path $ProjectRoot -ChildPath 'project.json'
    
    if (-not (Test-Path $Out.ProjecJSON)) { 
        Write-Error 'Not a Project folder, project.json not found' -ErrorAction Stop
    }

    ## Metadata, Import all json data
    $jsonData = Get-Content -Path $Out.ProjecJSON | ConvertFrom-Json -AsHashtable
    foreach ($key in $jsonData.Keys) {
        $Out[$key] = $jsonData[$key]
    }
    $ProjectName = $Out.ProjectName
    ## Folders
    $Out['ProjectRoot'] = $ProjectRoot
    $Out['PublicDir'] = [System.IO.Path]::Join($ProjectRoot, 'src', 'public')
    $Out['PrivateDir'] = [System.IO.Path]::Join($ProjectRoot, 'src', 'private')
    $Out['OutputDir'] = [System.IO.Path]::Join($ProjectRoot, 'dist')  
    $Out['OutputModuleDir'] = [System.IO.Path]::Join($Out.OutputDir, $ProjectName)  
    $Out['ModuleFilePSM1'] = [System.IO.Path]::Join($Out.OutputModuleDir, "$ProjectName.psm1")   
    $Out['ManifestFilePSD1'] = [System.IO.Path]::Join($Out.OutputModuleDir, "$ProjectName.psd1")  

    return $Out
}