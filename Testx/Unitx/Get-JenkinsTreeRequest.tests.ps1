$moduleManifestName = 'Jenkins.psd1'
$moduleRootPath = "$PSScriptRoot\..\..\src\"
$moduleManifestPath = Join-Path -Path $moduleRootPath -ChildPath $moduleManifestName

Import-Module -Name $ModuleManifestPath -Force
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelper') -Force

InModuleScope Jenkins {
    Describe 'Get-JenkinsTreeRequest' {
        Context 'When default depth, default type, default attribute' {
            It "Should return '?tree=jobs[name,buildable,url,color]'" {
                Get-JenkinsTreeRequest |
                    Should -Be '?tree=jobs[name,buildable,url,color]'
            }
        }
        Context 'When depth 2, default type, default attribute' {
            It "Should return '?tree=jobs[name,buildable,url,color,jobs[name,buildable,url,color]]'" {
                Get-JenkinsTreeRequest -Depth 2 |
                    Should -Be '?tree=jobs[name,buildable,url,color,jobs[name,buildable,url,color]]'
            }
        }
        Context 'When depth 2, type views, default attribute' {
            It "Should return '?tree=Views[name,buildable,url,color,Views[name,buildable,url,color]]'" {
                Get-JenkinsTreeRequest -Depth 2 -Type 'Views' |
                    Should -Be '?tree=Views[name,buildable,url,color,Views[name,buildable,url,color]]'
            }
        }
        Context 'When depth 3, type views, attribute name,url' {
            It "Should return '?tree=Views[name,url,Views[name,url,Views[name,url]]]'" {
                Get-JenkinsTreeRequest -Depth 3 -Type 'Views' -Attribute @('name','url') |
                    Should -Be '?tree=Views[name,url,Views[name,url,Views[name,url]]]'
            }
        }
        Context 'When depth 2, type jobs, attribute name,lastBuild[number]' {
            It "Should return '?tree=Jobs[name,lastBuild[number],Jobs[name,lastBuild[number]]]'" {
                Get-JenkinsTreeRequest -Depth 2 -Type 'Jobs' -Attribute @('name','lastBuild[number]') |
                    Should -Be '?tree=Jobs[name,lastBuild[number],Jobs[name,lastBuild[number]]]'
            }
        }
    }
}
