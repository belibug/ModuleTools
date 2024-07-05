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
    ($DirProject, $DirSrc, $DirPrivate, $DirPublic, $DirResources) | ForEach-Object {
        'Creating Directory: {0}' -f $_ | Write-Verbose
        New-Item -ItemType Directory -Path $_ | Out-Null
    }
    if ( $Answer.EnablePester -eq 'Yes') {
        New-Item -ItemType Directory -Path $DirTests | Out-Null
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

    'Module {0} scaffolding complete' -f $Answer.ProjectName | Write-Host -ForegroundColor Green
}