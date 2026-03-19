function Get-MTProjectInfo {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Path = (Get-Location).Path
    )
    $ProjectRoot = (Resolve-Path -LiteralPath $Path).Path
    $ProjectJson = [System.IO.Path]::Join($ProjectRoot, 'project.json')
    
    if (-not (Test-Path -LiteralPath $projectJson)) {
        throw "Not a project folder. project.json not found: $projectJson"
    }
    
    $jsonData = Get-Content -LiteralPath $projectJson -Raw | ConvertFrom-Json -AsHashtable

    $Out = @{}
    $Out['ProjectJSON'] = Join-Path -Path $ProjectRoot -ChildPath 'project.json'

    foreach ($key in $jsonData.Keys) {
        $Out[$key] = $jsonData[$key]
    }
    $Out.ProjectJson = $projectJson
    $Out.PSTypeName = 'MTProjectInfo'

    ## Folders
    $Out['ProjectRoot'] = $ProjectRoot
    $Out['PublicDir'] = [System.IO.Path]::Join($ProjectRoot, 'src', 'public')
    $Out['PrivateDir'] = [System.IO.Path]::Join($ProjectRoot, 'src', 'private')
    $Out['ClassesDir'] = [System.IO.Path]::Join($ProjectRoot, 'src', 'classes')
    $Out['ResourcesDir'] = [System.IO.Path]::Join($ProjectRoot, 'src', 'resources')
    $Out['DocsDir'] = [System.IO.Path]::Join($ProjectRoot, 'docs')
    $Out['OutputDir'] = [System.IO.Path]::Join($ProjectRoot, 'dist')  
    $Out['OutputModuleDir'] = [System.IO.Path]::Join($Out.OutputDir, $ProjectName)  
    $Out['ModuleFilePSM1'] = [System.IO.Path]::Join($Out.OutputModuleDir, "$ProjectName.psm1")   
    $Out['ManifestFilePSD1'] = [System.IO.Path]::Join($Out.OutputModuleDir, "$ProjectName.psd1")  

    return [pscustomobject]$out
}