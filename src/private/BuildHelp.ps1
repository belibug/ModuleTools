function Build-Help {
    [CmdletBinding()]
    param(
    )
    Write-Verbose 'Running Help update'

    $data = Get-MTProjectInfo
    $helpMarkdownFiles = Get-ChildItem -Path $data.DocsDir -Filter '*.md' -Recurse 

    if (-not $helpMarkdownFiles) {
        Write-Verbose 'No help markdown files in docs directory, skipping building help' 
        return
    }
    
    #region Check PlatyPS version requirement
    $minVersion = [version]'1.0.1'
    $module = Get-Module -ListAvailable -Name Microsoft.PowerShell.PlatyPS | Sort-Object Version -Descending | Select-Object -First 1
    if (-not $module -or $module.Version -lt $minVersion) {
        throw 'Microsoft.PowerShell.PlatyPS version 1.0.1 or higher is required.'
    }
    #endregion

    $AllCommandHelpFiles = $helpMarkdownFiles | Measure-PlatyPSMarkdown | Where-Object FileType -Match CommandHelp

    # Export to Dist folder    
    $AllCommandHelpFiles | Import-MarkdownCommandHelp -Path { $_.FilePath } |
    Export-MamlCommandHelp -OutputFolder $data.OutputModuleDir | Out-Null

    # Rename the directory to match locale
    $HelpDirOld = Join-Path $data.OutputModuleDir $Data.ProjectName
    #TODO: hardcoded locale to en-US, change it based on Doc type
    $languageLocale = 'en-US'
    $HelpDirNew = Join-Path $data.OutputModuleDir $languageLocale
    Write-Verbose "Renamed folder to locale: $languageLocale"

    Rename-Item -Path $HelpDirOld -NewName $HelpDirNew
}