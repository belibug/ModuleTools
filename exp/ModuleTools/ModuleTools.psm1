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
    $Out['OutputDir'] = [System.IO.Path]::Join($ProjectRoot, 'dist')  
    $Out['OutputModuleDir'] = [System.IO.Path]::Join($Out.OutputDir, $ProjectName)  
    $Out['ModuleFilePSM1'] = [System.IO.Path]::Join($Out.OutputModuleDir, "$ProjectName.psm1")   
    $Out['ManifestFilePSD1'] = [System.IO.Path]::Join($Out.OutputModuleDir, "$ProjectName.psd1")  

    return $Out
}
<#
.SYNOPSIS
    Invokes the process to build a module in ModuleTools format.

.DESCRIPTION
    This function is used to build a module, dist folder is cleaned up and whole module is build from scracth. copies all necessary resource files.

.PARAMETER None
    This function does not accept any parameters.

.EXAMPLE
    Invoke-MTBuild
    Invokes the process to build a module.
#>
function Invoke-MTBuild {
    [CmdletBinding()]
    param (
    )
    $ErrorActionPreference = 'Stop'
    Reset-ProjectDist
    Build-Module
    Build-Manifest
    Copy-ProjectResource
}
<#
.SYNOPSIS
Runs Pester tests for using settings from project.json

.DESCRIPTION
This function runs Pester tests using the specified configuration and settings in project.json. Place all your tests in "tests" folder

.PARAMETER TagFilter
Array of tags to run, Provide the tag Pester should run

.PARAMETER ExcludeTagFilter
Array of tags to exclude, Provide the tag Pester should exclude

.EXAMPLE
Invoke-MTTest
Runs the Pester tests for the project.

.EXAMPLE
Invoke-MTTest -TagFilter "unit","integrate"
Runs the Pester tests for the project, that has tag unit or integrate

.EXAMPLE
Invoke-MTTest -ExcludeTagFilter "unit"
Runs the Pester tests for the project, excludes any test with tag unit
#>
function Invoke-MTTest {
    [CmdletBinding()]
    param (
        [string[]]$TagFilter,
        [string[]]$ExcludeTagFilter
    )
    Test-ProjectSchema Pester | Out-Null
    $Script:data = Get-MTProjectInfo 
    $pesterConfig = New-PesterConfiguration -Hashtable $data.Pester

    $testPath = './tests' 
    $pesterConfig.Run.Path = $testPath
    $pesterConfig.Run.PassThru = $true
    $pesterConfig.Run.Exit = $true
    $pesterConfig.Run.Throw = $true
    $pesterConfig.Filter.Tag = $TagFilter 
    $pesterConfig.Filter.ExcludeTag = $ExcludeTagFilter 
    $pesterConfig.TestResult.OutputPath = './dist/TestResults.xml'
    $TestResult = Invoke-Pester -Configuration $pesterConfig
    if ($TestResult.Result -ne 'Passed') {
        Write-Error 'Tests failed' -ErrorAction Stop 
        return $LASTEXITCODE
    }
}
<#
.SYNOPSIS
Create module scaffolding along with project.json file to easily build and manage modules

.DESCRIPTION
This command creates folder structure and project.json file easily. Use this to quikcly setup a ModuleTools compatible module. 

.PARAMETER Path
Path where module will be created. Provide root folder path, module folder will be created as subdirectory. Path should be valid.

.EXAMPLE
New-MTModule -Path c:\work
# Creates module inside c:\work folder

.NOTES
The structure of the ModuleTools module is meticulously designed according to PowerShell best practices for module development. While some design decisions may seem unconventional, they are made to ensure that ModuleTools and the process of building modules remain straightforward and easy to manage.
#>
function New-MTModule {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [string]$Path = (Get-Location).Path
    )
    $ErrorActionPreference = 'Stop'
    Push-Location
    if (-not(Test-Path $Path)) { Write-Error 'Not a valid path' }
    $Questions = [ordered]@{
        ProjectName           = @{
            Caption = 'Module Name'
            Message = 'Enter Module name of your choice, should be single word with no special characters'
            Prompt  = 'Name'
            Default = 'MANDATORY'
        }
        Description           = @{
            Caption = 'Module Description'
            Message = 'What does your module do? Describe in simple words'
            Prompt  = 'Description'
            Default = 'ModuleTools Module'
        }
        Version               = @{
            Caption = 'Semantic Version'
            Message = 'Starting Version of the module (Default: 0.0.1)'
            Prompt  = 'Version'
            Default = '0.0.1'
        }
        Author                = @{
            Caption = 'Module Author'
            Message = 'Enter Author or company name'
            Prompt  = 'Name'
            Default = 'PS'
        }
        PowerShellHostVersion = @{
            Caption = 'Supported PowerShell Version'
            Message = 'What is minimum supported version of PowerShell for this module (Default: 7.4)'
            Prompt  = 'Version'
            Default = '7.4'
        }
        EnableGit             = @{
            Caption = 'Git Version Control'
            Message = 'Do you want to enable version controlling using Git'
            Prompt  = 'EnableGit'
            Default = 'No'
            Choice  = @{
                Yes = 'Enable Git'
                No  = 'Skip Git initialization'
            }
        }
        EnablePester          = @{
            Caption = 'Pester Testing'
            Message = 'Do you want to enable basic Pester Testing'
            Prompt  = 'EnablePester'
            Default = 'No'
            Choice  = @{
                Yes = 'Enable pester to perform testing'
                No  = 'Skip pester testing'
            }
        }
    }
    $Answer = @{}
    $Questions.Keys | ForEach-Object {
        $Answer.$_ = Read-AwesomeHost -Ask $Questions.$_
    }

    # TODO check other components
    if ($Answer.ProjectName -notmatch '^[A-Za-z][A-Za-z0-9_.]*$') {
        Write-Error 'Module Name invalid. Module should be one word and contain only Letters,Numbers and ' 
    }
  
    $DirProject = Join-Path -Path $Path -ChildPath $Answer.ProjectName
    $DirSrc = Join-Path -Path $DirProject -ChildPath 'src'
    $DirPrivate = Join-Path -Path $DirSrc -ChildPath 'private'
    $DirPublic = Join-Path -Path $DirSrc -ChildPath 'public'
    $DirResources = Join-Path -Path $DirSrc -ChildPath 'resources'
    $DirTests = Join-Path -Path $DirProject -ChildPath 'tests'
    $ProjectJSONFile = Join-Path $DirProject -ChildPath 'project.json'

    if (Test-Path $DirProject) {
        Write-Error 'Project already exists, aborting' | Out-Null
    }
    # Setup Module

    Write-Message "`nStarted Module Scaffolding" -color Green
    Write-Message 'Setting up Directories'
    ($DirProject, $DirSrc, $DirPrivate, $DirPublic, $DirResources) | ForEach-Object {
        'Creating Directory: {0}' -f $_ | Write-Verbose
        New-Item -ItemType Directory -Path $_ | Out-Null
    }
    if ( $Answer.EnablePester -eq 'Yes') {
        Write-Message 'Include Pester Configs'
        New-Item -ItemType Directory -Path $DirTests | Out-Null
    }
    if ( $Answer.EnableGit -eq 'Yes') {
        Write-Message 'Initialize Git Repo'
        New-InitiateGitRepo -DirectoryPath $DirProject
    }

    ## Create ProjectJSON
    $JsonData = Get-Content "$PSScriptRoot\resources\ProjectTemplate.json" -Raw | ConvertFrom-Json -AsHashtable

    $JsonData.ProjectName = $Answer.ProjectName
    $JsonData.Description = $Answer.Description
    $JsonData.Version = $Answer.version
    $JsonData.Manifest.Author = $Answer.Author
    $JsonData.Manifest.PowerShellHostVersion = $Answer.PowerShellHostVersion
    $JsonData.Manifest.GUID = (New-Guid).GUID
    if ($Answer.EnablePester -eq 'No') { $JsonData.Remove('Pester') }

    Write-Verbose $JsonData
    $JsonData | ConvertTo-Json | Out-File $ProjectJSONFile

    'Module {0} scaffolding complete' -f $Answer.ProjectName | Write-Message -color Green
}
<#
.SYNOPSIS
Updates the version number of a module in project.json file.

.DESCRIPTION
This script updates the version number of a PowerShell module by modifying the project.json file, which gets written into module manifest file (.psd1).
It increments the version number based on the specified version part (Major, Minor, Patch).

.PARAMETER Label
The part of the version number to increment (Major, Minor, Patch). Default is patch.

.EXAMPLE
Update-MTModuleVersion -Label Major
Updates the Major version part of the module. Version 2.1.3 will become 3.1.3

.EXAMPLE
Update-MTModuleVersion
Updates the Patch version part of the module. Version 2.1.3 will become 2.1.4

.NOTES
Ensure you are in project directory when you run this command.
#>
function Update-MTModuleVersion {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [ValidateSet('Major', 'Minor', 'Patch')]
        [string]$Label = 'Patch'
    )
    Write-Verbose 'Running Version Update'

    $data = Get-MTProjectInfo
    $jsonContent = Get-Content -Path $data.ProjecJSON | ConvertFrom-Json

    $currentVersion = $jsonContent.Version
    $versionComponents = $currentVersion.Split('.')

    # Increment the last component
    switch ($Label) {
        'Major' { $versionComponents[0] = [int]$versionComponents[0] + 1 }
        'Minor' { $versionComponents[1] = [int]$versionComponents[1] + 1 }
        'Patch' { $versionComponents[2] = [int]$versionComponents[2] + 1 }
    }
    
    # Join the version components back into a string
    $newVersion = $versionComponents -join '.'

    # Update the version in the JSON object
    $jsonContent.Version = $newVersion
    Write-Host "Version bumped to : $newVersion"

    # Convert the JSON object back to JSON format
    $newJsonContent = $jsonContent | ConvertTo-Json

    # Write the updated JSON back to the file
    $newJsonContent | Set-Content -Path $data.ProjecJSON
}
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
}
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
function Get-FunctionNameFromFile {
    param($filePath)
    try {
        $moduleContent = Get-Content -Path $filePath -Raw
        $ast = [System.Management.Automation.Language.Parser]::ParseInput($moduleContent, [ref]$null, [ref]$null)
        $functionName = $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false) | ForEach-Object { $_.Name } 
        return $functionName
    }
    catch { return '' }
}
function New-InitiateGitRepo {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$DirectoryPath
    )

    # Check if Git is installed
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Warning 'Git is not installed. Please install Git and initialize repo manually' 
        return
    }
    Push-Location -StackName 'GitInit'
    # Navigate to the specified directory
    Set-Location $DirectoryPath

    # Check if a Git repository already exists
    if (Test-Path -Path '.git') {
        Write-Warning 'A Git repository already exists in this directory.'
        return
    }
    if ($PSCmdlet.ShouldProcess($DirectoryPath, ("Initiating git on $DirectoryPath"))) {
        try {
            git init | Out-Null
        } catch {
            Write-Error 'Failed to initialize Git repo'
        }
    }
    Write-Verbose 'Git repository initialized successfully'
    Pop-Location -StackName 'GitInit'
}

function Read-AwesomeHost {
    [CmdletBinding()]
    param (
        [Parameter()]
        [pscustomobject]
        $Ask
    )
    ## For standard questions
    if ($null -eq $Ask.Choice) {
        do {
            $response = $Host.UI.Prompt($Ask.Caption, $Ask.Message, $Ask.Prompt)
        } while ($Ask.Default -eq 'MANDATORY' -and [string]::IsNullOrEmpty($response.Values))

        if ([string]::IsNullOrEmpty($response.Values)) {
            $result = $Ask.Default
        } else {
            $result = $response.Values
        }
    }
    ## For Choice based
    if ($Ask.Choice) {
        $Cs = @()
        $Ask.Choice.Keys | ForEach-Object {
            $Cs += New-Object System.Management.Automation.Host.ChoiceDescription "&$_", $($Ask.Choice.$_)
        }
        $options = [System.Management.Automation.Host.ChoiceDescription[]]($Cs)
        $IndexOfDefault = $Cs.Label.IndexOf('&' + $Ask.Default)
        $response = $Host.UI.PromptForChoice($Ask.Caption, $Ask.Message, $options, $IndexOfDefault)
        $result = $Cs.Label[$response] -replace '&'
    }
    return $result
}
function Reset-ProjectDist {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
    )
    $ErrorActionPreference = 'Stop'
    $data = Get-MTProjectInfo
    try {
        Write-Verbose 'Running dist folder reset'
        if (Test-Path $data.OutputDir) {
            Remove-Item -Path $data.OutputDir -Recurse -Force
        }
        # Setup Folders
        New-Item -Path $data.OutputDir -ItemType Directory -Force | Out-Null # Dist folder
        New-Item -Path $data.OutputModuleDir -Type Directory -Force | Out-Null # Module Folder
    } catch {
        Write-Error 'Failed to reset Dist folder'
    }
}
function Test-ProjectSchema {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('Build', 'Pester')]
        [string]
        $Schema
    )
    Write-Verbose "Running Schema test against using $Schema schema"
    $SchemaPath = @{
        Build  = "$PSScriptRoot\resources\Schema-Build.json"
        Pester = "$PSScriptRoot\resources\Schema-Pester.json"
    }
    $result = switch ($Schema) {
        'Build' { Test-Json -Path 'project.json' -Schema (Get-Content $SchemaPath.Build -Raw) -ErrorAction Stop }
        'Pester' { Test-Json -Path 'project.json' -Schema (Get-Content $SchemaPath.Pester -Raw) -ErrorAction Stop }
        Default { $false }
    }
    return $result
}
function Write-Message {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [string]
        $Text,
        [ValidateSet('Yello', 'Blue', 'Green')]
        [string]
        $color = 'Blue'
    )
    PROCESS {
        Write-Host $Text -ForegroundColor $color
    }
}

