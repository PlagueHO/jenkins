[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
[CmdletBinding()]
param ()

$ProjectPath = "$PSScriptRoot\..\.." | Convert-Path
$ProjectName = ((Get-ChildItem -Path $ProjectPath\*\*.psd1).Where{
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(try
            { Test-ModuleManifest $_.FullName -ErrorAction Stop
            }
            catch
            { $false
            } )
    }).BaseName

Import-Module -Name $ProjectName -Force

InModuleScope $ProjectName {
    $testHelperPath = $PSScriptRoot | Split-Path -Parent | Join-Path -ChildPath 'TestHelper'
    Import-Module -Name $testHelperPath -Force

    Describe 'Set-JenkinsTLSSupport' {
        It 'Should not throw' {
            { Set-JenkinsTLSSupport } | Should -Not -Throw
        }

        It 'Security Protocol Type should contain "Tls12"' -Skip:($IsCoreClr -eq $true) {
            ([Net.ServicePointManager]::SecurityProtocol).ToString().Contains([Net.SecurityProtocolType]::Tls12) | Should -Be $true
        }
    }
}
