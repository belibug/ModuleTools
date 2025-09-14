<#
.SYNOPSIS
Updates the version number of a module in project.json file. Uses [semver] object type.

.DESCRIPTION
This script updates the version number of a PowerShell module by modifying the project.json file, which gets written into module manifest file (.psd1). [semver] is supported only powershell 7 and above.
It increments the version number based on the specified version part (Major, Minor, Patch). Can also attach preview/stable release to Release property of

.PARAMETER Label
The part of the version number to increment (Major, Minor, Patch). Default is patch.

.PARAMETER PreviewRelease
Use this to use semantic version and attach release name as 'preview' which is supported by PowerShell gallery, to remove it use stable release parameter

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
        [string]$Label = 'Patch',
        [switch]$PreviewRelease,
        [switch]$StableRelease
    )
    Write-Verbose 'Running Version Update'

    $data = Get-MTProjectInfo
    $jsonContent = Get-Content -Path $data.ProjecJSON | ConvertFrom-Json

    [semver]$CurrentVersion = $jsonContent.Version

    $Major = ($Label -eq 'Major') ? ($CurrentVersion.Major + 1) : $CurrentVersion.Major
    $Minor = ($Label -eq 'Minor') ? ($CurrentVersion.Minor + 1) : $CurrentVersion.Minor
    $Patch = ($Label -eq 'Patch') ? ($CurrentVersion.Patch + 1) : $CurrentVersion.Patch
    
    if ($PreviewRelease) {
        $ReleaseType = 'preview' 
    } elseif ($StableRelease) { 
        $ReleaseType = $null
    } else {
        $ReleaseType = $CurrentVersion.PreReleaseLabel
    }
    
    $newVersion = [semver]::new($Major, $Minor, $Patch, $ReleaseType, $null)

    # Update the version in the JSON object
    $jsonContent.Version = $newVersion.ToString()
    Write-Host "Version bumped to : $newVersion"

    # Convert the JSON object back to JSON format
    $newJsonContent = $jsonContent | ConvertTo-Json

    # Write the updated JSON back to the file
    $newJsonContent | Set-Content -Path $data.ProjecJSON
}