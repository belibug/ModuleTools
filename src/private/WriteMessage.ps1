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