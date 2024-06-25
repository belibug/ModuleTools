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