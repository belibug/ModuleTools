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
