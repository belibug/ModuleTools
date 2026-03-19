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
    $jsonContent = Get-Content -Path $data.ProjectJSON | ConvertFrom-Json

    [semver]$CurrentVersion = $jsonContent.Version
    $Major = $CurrentVersion.Major
    $Minor = $CurrentVersion.Minor
    
    if ($Label -eq 'Major') {
        $Major = $CurrentVersion.Major + 1
        $Minor = 0
        $Patch = 0
    } elseif ($Label -eq 'Minor') {
        $Minor = $CurrentVersion.Minor + 1
        $Patch = 0
    } elseif ($Label -eq 'Patch') {
        $Patch = $CurrentVersion.Patch + 1
    }

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
    $newJsonContent | Set-Content -Path $data.ProjectJSON
}