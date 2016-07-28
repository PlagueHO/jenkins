<#
.SYNOPSIS
Runs all tests on this module.
#>
$ScriptRoot = Split-Path `
    -Path $MyInvocation.MyCommand.Path `
    -Parent
Push-Location
Set-Location -Path $ScriptRoot
if (-not (Get-Module -Name Pester -ListAvailable -ErrorAction SilentlyContinue))
{
    Install-Module `
        -Name 'Pester' `
        -Confirm:$False
}
Import-Module `
    -Name 'Pester' `
    -ErrorAction Stop
Invoke-Pester
Pop-Location