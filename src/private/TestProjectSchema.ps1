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