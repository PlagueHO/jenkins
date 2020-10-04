[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
[CmdletBinding()]
param (
)

$moduleManifestName = 'Jenkins.psd1'
$moduleRootPath = "$PSScriptRoot\..\..\src\"
$moduleManifestPath = Join-Path -Path $moduleRootPath -ChildPath $moduleManifestName

Import-Module -Name $ModuleManifestPath -Force
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelper') -Force

$testURI        = 'https://jenkins.contoso.com'
$testUsername   = 'DummyUser'
$testPassword   = 'DummyPassword'
$testCredential = New-Object -TypeName System.Management.Automation.PSCredential `
    -ArgumentList $testUsername, ( ConvertTo-SecureString -String $testPassword -AsPlainText -Force)
$testCommand    = 'CommandTest'
$bytes          = [System.Text.Encoding]::UTF8.GetBytes($testUsername + ':' + $testPassword)
$base64Bytes    = [System.Convert]::ToBase64String($bytes)
$testAuthHeader = "Basic $base64Bytes"
$testJobName    = 'TestJob'

Describe 'Get-JenkinsObject' {
    Context 'When jobs type, attribute name, no folder, credentials passed' {
        $getJenkinsObjectSplat = @{
            Uri        = $testURI
            Credential = $testCredential
            Type       = 'jobs'
            Attribute = @('name')
        }

        Mock -CommandName Invoke-JenkinsCommand -ModuleName Jenkins `
            -MockWith { Throw "Invoke-RestMethod called with incorrect parameters" }
        Mock -CommandName Invoke-JenkinsCommand -ModuleName Jenkins `
            -ParameterFilter {
                $Command -eq '?tree=jobs[name]'
            } `
            -MockWith { @{
                        jobs = @(
                            @{ name = 'test1' },
                            @{ name = 'test2' }
                        )
                    }
                }
        $splat = $getJenkinsObjectSplat.Clone()
        $result = Get-JenkinsObject @splat

        It 'Should return expected objects' {
            $result.Count | Should -Be 2
            $result[0].Name | Should -Be 'test1'
            $result[1].Name | Should -Be 'test2'
        }

        It 'Should return call expected mocks' {
            Assert-MockCalled -CommandName Invoke-JenkinsCommand -ModuleName Jenkins `
                -ParameterFilter {
                    $Command -eq '?tree=jobs[name]'
                } `
                -Exactly 1
        }
    } # Context

    Context 'When jobs type, attribute name, folder, credentials passed' {
        foreach( $slash in @( '/', '\') )
        {
            Context "When slash in folder path is '$slash'" {
                $getJenkinsObjectSplat = @{
                    Uri        = $testURI
                    Credential = $testCredential
                    Folder     = ('test{0}folder' -f $slash)
                    Type       = 'jobs'
                    Attribute = @('name')
                }

                Mock -CommandName Invoke-JenkinsCommand -ModuleName Jenkins `
                    -MockWith { Throw "Invoke-RestMethod called with incorrect parameters" }
                Mock -CommandName Invoke-JenkinsCommand -ModuleName Jenkins `
                    -ParameterFilter {
                        $Command -eq '?tree=jobs[name,jobs[name,jobs[name]]]'
                    } `
                    -MockWith { @{
                                jobs = @(
                                    @{ name = 'test1' },
                                    @{ name = 'test2' }
                                )
                            }
                        }
                $splat = $getJenkinsObjectSplat.Clone()
                $result = Get-JenkinsObject @splat

                It 'Should return expected objects' {
                    $result.Count | Should -Be 2
                    $result[0].Name | Should -Be 'test1'
                    $result[1].Name | Should -Be 'test2'
                }

                It 'Should return call expected mocks' {
                    Assert-MockCalled -CommandName Invoke-JenkinsCommand -ModuleName Jenkins `
                        -ParameterFilter {
                            $Command -eq '?tree=jobs[name,jobs[name,jobs[name]]]'
                        } `
                        -Exactly 1
                }
            } # Context
        } # foreach
    } # Context
}
