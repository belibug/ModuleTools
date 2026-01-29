<#
.SYNOPSIS
Creates module documentation from the Comment-based Help.
 
.DESCRIPTION
Creates Markdown module documentation, from the Comment-based Help provided in each public function.
Markdown documentation will be saved in a docs directory at the project root.
 
.EXAMPLE
Invoke-MTDocs
 
Generate Markdown documentation.
#>
function Invoke-MTDocs {
    [CmdletBinding()]
    param ()
 
    if (!(Get-Module -Name Microsoft.PowerShell.PlatyPS -ListAvailable)) {
        throw 'The module Microsoft.PowerShell.PlatyPS must be installed for Markdown documentation to be generated.'
    }
 
    $data = Get-MTProjectInfo
 
    if (!(Test-Path -Path $data.OutputModuleDir)) {
        throw 'The module must be built using Invoke-MTBuild, before documentation can be generated.'
    }
 
    $docsPath = Join-Path $data.ProjectRoot -ChildPath 'docs'
 
    if (Test-Path -Path $docsPath) {
        Remove-Item -Path $docsPath -Include '*.md' -Recurse -Force | Out-Null
    } else {
        New-Item -Path $docsPath -ItemType Directory -Force | Out-Null
    }
 
    Write-Verbose 'Importing required modules.'
    Import-Module $data.ManifestFilePSD1 -Force
    Import-Module -Name Microsoft.PowerShell.PlatyPS -Force
 
    Write-Verbose 'Generating Markdown documentation...'
    $moduleCommands = Get-Command -Module $data.ProjectName
    $moduleCommandHelp = @()
 
    foreach ($command in $moduleCommands) {
        Write-Verbose "Processing command: $($command.Name)"
        $commandHelp = New-CommandHelp $command
 
        Export-MarkdownCommandHelp -Metadata @{ Locale = 'en-US' } -CommandHelp $commandHelp -OutputFolder $docsPath | Out-Null
        $moduleCommandHelp += $commandHelp
    }
 
    # Generate module file
    $newMarkdownCommandHelpSplat = @{
        HelpVersion  = $data.Version
        Locale       = 'en-US'
        CommandHelp  = $moduleCommandHelp
        OutputFolder = $docsPath
        Force        = $true
    }
 
    New-MarkdownModuleFile @newMarkdownCommandHelpSplat | Out-Null
 
    # Replace placeholders with actual values in module documentation
    $moduleDocPath = [System.IO.Path]::Join($docsPath, $data.ProjectName, "$($data.ProjectName).md")
    if (Test-Path $moduleDocPath) {
        $moduleDocContent = Get-Content $moduleDocPath -Raw
        $moduleDocContent = $moduleDocContent -replace '\{\{ Fill in the Description \}\}', $data.Description
 
        # Ensure single trailing newline
        $moduleDocContent = $moduleDocContent.TrimEnd() + "`n"
        Set-Content -Path $moduleDocPath -Value $moduleDocContent -NoNewline
    }
 
    # Clean up remaining placeholders in command documentation files
    $commandDocFiles = Get-ChildItem -Path $docsPath -Filter '*.md' -Recurse | Where-Object { $_.Name -ne "$($data.ProjectName).md" }
    foreach ($docFile in $commandDocFiles) {
        Write-Verbose "Cleaning up placeholders in: $($docFile.Name)"
        $content = Get-Content $docFile.FullName -Raw
 
        # Remove entire ALIASES section if it contains placeholder
        $content = $content -replace '(?s)## ALIASES\s*\r?\n\s*This cmdlet has the following aliases,\s*\r?\n\s*\{\{Insert list of aliases\}\}\s*\r?\n', ''
 
        # Remove entire RELATED LINKS section if it contains placeholder
        $content = $content -replace '(?s)## RELATED LINKS\s*\r?\n\s*\{\{ Fill in the related links here \}\}\s*\r?\n?', ''
 
        # Remove placeholder output descriptions
        $content = $content -replace '\{\{ Fill in the Description \}\}', ''
 
        # Remove any other parameter description placeholders
        $content = $content -replace '\{\{ Fill \w+ Description \}\}', ''
 
        # Fix EXAMPLES section formatting - ensure blank line between command and description
        $content = $content -replace '(### EXAMPLE \d+\s*\r?\n\s*)([^\r\n]+)(\r?\n)([^\r\n]+)', '$1$2$3$3$4'
        # Clean up excessive line breaks that result from removals
        $content = $content -replace '(\r?\n){3,}', "`n`n"
 
        # Ensure single trailing newline
        $content = $content.TrimEnd() + "`n"
 
        Set-Content -Path $docFile.FullName -Value $content -NoNewline
    }
 
    Write-Verbose 'Markdown Documentation generation complete.'
}
