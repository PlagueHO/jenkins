<#
    .SYNOPSIS
        Helper function that just creates an exception record for testing.
#>
function Get-ExceptionRecord
{
    [CmdLetBinding()]
    param
    (
        [Parameter(Mandatory)]
        [System.String]
        $ErrorId,

        [Parameter(Mandatory)]
        [System.Management.Automation.ErrorCategory]
        $ErrorCategory,

        [Parameter(Mandatory)]
        [System.String]
        $ErrorMessage,

        [Switch]
        $terminate
    )

    $exception = New-Object -TypeName System.Exception `
        -ArgumentList $ErrorMessage
    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
        -ArgumentList $exception, $ErrorId, $ErrorCategory, $null

    return $errorRecord
} # function
