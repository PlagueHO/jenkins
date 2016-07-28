#Requires -RunAsAdministrator
<#
.SYNOPSIS
Removes the existing Module from the Windows PowerShell Module folder and copies the parent
folder in. It then imports the module, ready for use.
#>
[CmdletBinding()]
param (
)
$ModuleRoot = Split-Path `
    -Path $PSScriptRoot `
    -Parent
$Path  = 'c:\program files\windowspowershell\modules'
$Module = (Get-Item -Path (Resolve-Path "$ModuleRoot\*" -Relative) -Include *.psm1).BaseName

if (Get-Module -Name $Module)
{
    Remove-Module `
        -Name $Module `
        -Force
} # if
$Destination = Join-Path -Path $Path -ChildPath $Module
if (Test-Path -Path $Destination)
{
    Remove-Item `
        -Path $Destination `
        -Force `
        -Recurse
} # if
Copy-Item `
    -Path $ModuleRoot `
    -Destination $Destination `
    -Force `
    -Recurse
Remove-Item `
    -Path "$Destination\.*" `
    -Recurse `
    -Force
Remove-Item `
    -Path "$Destination\Deploy" `
    -Recurse `
    -Force
Import-Module `
    -Name $Module `
    -Force
