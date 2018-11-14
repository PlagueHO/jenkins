$moduleManifestName = 'Jenkins.psd1'
$moduleRootPath = "$PSScriptRoot\..\..\src\"
$moduleManifestPath = Join-Path -Path $moduleRootPath -ChildPath $moduleManifestName

Import-Module -Name $ModuleManifestPath -Force
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelper') -Force

InModuleScope Jenkins {
    Describe 'Set-JenkinsTLSSupport' {
        It 'Should not throw' {
            { Set-JenkinsTLSSupport } | Should -Not -Throw
        }

        It 'Security Protocol Type should contain "Tls12"' {
            ([Net.ServicePointManager]::SecurityProtocol).ToString().Contains([Net.SecurityProtocolType]::Tls12) | Should -Be $true
        }
    }
}
