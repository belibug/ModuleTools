function Get-LocalModulePath {
    $sep = [IO.Path]::PathSeparator
    
    $ModulePaths = $env:PSModulePath -split $sep | ForEach-Object { $_.Trim() } | Select-Object -Unique

    if ($IsWindows) {
        $MatchPattern = '\\Documents\\PowerShell\\Modules'
        $Result = $ModulePaths | Where-Object { $_ -match $MatchPattern } | Select-Object -First 1
        if ($Result -and (Test-Path $Result)) { 
            return $Result 
        } else { 
            throw "No windows module path matching $MatchPattern found" 
        }
    } else {
        # For Mac and Linux
        $MatchPattern = '/\.local/share/powershell/Modules$'
        $Result = $ModulePaths | Where-Object { $_ -match $MatchPattern } | Select-Object -First 1
        if ($Result -and (Test-Path $Result)) {
            return $Result 
        } else {
            throw "No macOS/Linux module path matching $MatchPattern found in PSModulePath."
        }
    }
}