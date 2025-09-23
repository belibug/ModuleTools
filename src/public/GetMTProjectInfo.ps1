<#
.SYNOPSIS
Retrieves information about a project by reading data from a project.json file in ModuleTools project folder.

.DESCRIPTION
The Get-MTProjectInfo function retrieves information about a project by reading data from a project.json file located in the current directory. Ensure you navigate to a module directory which has project.json in root directory. Most variables are already defined in output of this command which can be used in pester tests and other configs.

.PARAMETER None
This function does not accept any parameters.

.EXAMPLE
Get-MTProjectInfo
Retrieves project information from the project.json file in the current directory. Useful for debuggin and writing pester tests.

.OUTPUTS
hastable with all project data.

#>
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
    $Out['ClassesDir'] = [System.IO.Path]::Join($ProjectRoot, 'src', 'classes')
    $Out['ResourcesDir'] = [System.IO.Path]::Join($ProjectRoot, 'src', 'resources')
    $Out['OutputDir'] = [System.IO.Path]::Join($ProjectRoot, 'dist')  
    $Out['OutputModuleDir'] = [System.IO.Path]::Join($Out.OutputDir, $ProjectName)  
    $Out['ModuleFilePSM1'] = [System.IO.Path]::Join($Out.OutputModuleDir, "$ProjectName.psm1")   
    $Out['ManifestFilePSD1'] = [System.IO.Path]::Join($Out.OutputModuleDir, "$ProjectName.psd1")  

    $Output = [pscustomobject]$Out | Add-Member -TypeName MTProjectInfo -PassThru   
    return $Output
}