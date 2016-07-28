$Global:ModuleRoot = Resolve-Path -Path "$($Script:MyInvocation.MyCommand.Path)..\..\..\..\"
$Global:Module = 'Jenkins'
$Global:ModulePath = Join-Path -Path $Global:ModuleRoot -ChildPath "$($Global:Module).psm1"

Push-Location
try
{
    Set-Location -Path $Global:ModuleRoot
    Import-Module `
        -Name $Global:ModulePath `
        -Force `
        -DisableNameChecking

    # Perform PS Script Analyzer tests on module code only
    if (-not (Get-Module -Name PSScriptAnalyzer -ListAvailable -ErrorAction SilentlyContinue))
    {
        Install-Module `
            -Name 'PSScriptAnalyzer' `
            -Confirm:$False
    } # if
    Import-Module `
        -Name 'PSScriptAnalyzer' `
        -ErrorAction Stop

    Describe 'PSScriptAnalyzer' {
        Context "$($Global:Module).psm1" {
            It 'Passes Invoke-ScriptAnalyzer' {
                # Perform PSScriptAnalyzer scan.
                $PSScriptAnalyzerResult = Invoke-ScriptAnalyzer `
                    -path $Global:ModulePath `
                    -Severity Warning `
                    -ErrorAction SilentlyContinue
                $PSScriptAnalyzerErrors = $PSScriptAnalyzerResult | Where-Object { $_.Severity -eq 'Error' }
                $PSScriptAnalyzerWarnings = $PSScriptAnalyzerResult | Where-Object { $_.Severity -eq 'Warning' }
                if ($PSScriptAnalyzerErrors -ne $null)
                {
                    Write-Warning -Message 'There are PSScriptAnalyzer errors that need to be fixed:'
                    @($PSScriptAnalyzerErrors).Foreach( { Write-Warning -Message "$($_.Scriptname) (Line $($_.Line)): $($_.Message)" } )
                    Write-Warning -Message  'For instructions on how to run PSScriptAnalyzer on your own machine, please go to https://github.com/powershell/psscriptAnalyzer/'
                    $PSScriptAnalyzerErrors.Count | Should Be $null
                }
                if ($PSScriptAnalyzerWarnings -ne $null)
                {
                    Write-Warning -Message 'There are PSScriptAnalyzer warnings that should be fixed:'
                    @($PSScriptAnalyzerWarnings).Foreach( { Write-Warning -Message "$($_.Scriptname) (Line $($_.Line)): $($_.Message)" } )
                }
            }
        }
    }

    InModuleScope $($Global:Module) {
    <#
    .SYNOPSIS
    Helper function that just creates an exception record for testing.
    #>
        function GetException
        {
            [CmdLetBinding()]
            param
            (
                [Parameter(Mandatory)]
                [String] $errorId,

                [Parameter(Mandatory)]
                [System.Management.Automation.ErrorCategory] $errorCategory,

                [Parameter(Mandatory)]
                [String] $errorMessage,

                [Switch]
                $terminate
            )

            $exception = New-Object -TypeName System.Exception `
                -ArgumentList $errorMessage
            $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                -ArgumentList $exception, $errorId, $errorCategory, $null
            return $errorRecord
        }
    }
}
catch
{
    throw $_
}
finally
{
    Pop-Location
}