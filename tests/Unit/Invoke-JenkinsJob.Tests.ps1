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

    $testURI = 'https://jenkins.contoso.com'
    $testUsername = 'DummyUser'
    $testPassword = 'DummyPassword'
    $testCredential = New-Object `
        -TypeName System.Management.Automation.PSCredential `
        -ArgumentList $testUsername, (ConvertTo-SecureString -String $testPassword -AsPlainText -Force)
    $Bytes = [System.Text.Encoding]::UTF8.GetBytes($testUsername + ':' + $testPassword)
    $Base64Bytes = [System.Convert]::ToBase64String($Bytes)
    $testAuthHeader = "Basic $Base64Bytes"
    $testJobName = 'TestJob'

    Describe 'Invoke-JenkinsJob' {
        $inokeJenkinsJob_Parameters = @{
            Uri        = $testURI
            Credential = $testCredential
            Name       = $testJobName
            Verbose    = $true
        }

        Context 'When Name is set, no folder is passed and no parameters passed' {
            Mock `
                -CommandName Invoke-JenkinsCommand `
                -ModuleName Jenkins `
                -MockWith { 'Invoke Result' }

            $splat = $inokeJenkinsJob_Parameters.Clone()
            $result = Invoke-JenkinsJob @splat

            It 'Should return expected XML' {
                $result | Should -Be 'Invoke Result'
            }

            It 'Should return call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-JenkinsCommand `
                    -ModuleName Jenkins `
                    -ParameterFilter {
                    $bodyObject = ConvertTo-Json -InputObject $Body
                    $Command -eq "job/$testJobName/build" -and `
                        $bodyObject.json -eq $null
                } `
                    -Exactly -Times 1
            }
        }

        Context 'When Name is set, single folder is passed and no parameters passed' {
            Mock `
                -CommandName Invoke-JenkinsCommand `
                -ModuleName Jenkins `
                -MockWith { 'Invoke Result' }

            $splat = $inokeJenkinsJob_Parameters.Clone()
            $splat.Folder = 'test'
            $result = Invoke-JenkinsJob @splat

            It 'Should return expected XML' {
                $result | Should -Be 'Invoke Result'
            }

            It 'Should return call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-JenkinsCommand `
                    -ModuleName Jenkins `
                    -ParameterFilter {
                    $bodyObject = ConvertTo-Json -InputObject $Body
                    $Command -eq "job/test/job/$testJobName/build" -and `
                        $bodyObject.json -eq $null
                } `
                    -Exactly -Times 1
            }
        }

        Context 'When Name is set, two folders are passed separated by \ and no parameters passed' {
            Mock `
                -CommandName Invoke-JenkinsCommand `
                -ModuleName Jenkins `
                -MockWith { 'Invoke Result' }

            $splat = $inokeJenkinsJob_Parameters.Clone()
            $splat.Folder = 'test1\test2'
            $result = Invoke-JenkinsJob @splat

            It 'Should return expected XML' {
                $result | Should -Be 'Invoke Result'
            }

            It 'Should return call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-JenkinsCommand `
                    -ModuleName Jenkins `
                    -ParameterFilter {
                    $bodyObject = ConvertTo-Json -InputObject $Body
                    $Command -eq "job/test1/job/test2/job/$testJobName/build" -and `
                        $bodyObject.json -eq $null
                } `
                    -Exactly -Times 1
            }
        }

        Context 'When Name is set, two folders are passed separated by / and no parameters passed' {
            Mock `
                -CommandName Invoke-JenkinsCommand `
                -ModuleName Jenkins `
                -MockWith { 'Invoke Result' }

            $splat = $inokeJenkinsJob_Parameters.Clone()
            $splat.Folder = 'test1/test2'
            $result = Invoke-JenkinsJob @splat

            It 'Should return expected XML' {
                $result | Should -Be 'Invoke Result'
            }

            It 'Should return call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-JenkinsCommand `
                    -ModuleName Jenkins `
                    -ParameterFilter {
                    $bodyObject = ConvertTo-Json -InputObject $Body
                    $Command -eq "job/test1/job/test2/job/$testJobName/build" -and `
                        $bodyObject.json -eq $null
                } `
                    -Exactly -Times 1
            }
        }

        Context 'When Name is set, two folders are passed separated by \ and / and no parameters passed' {
            Mock `
                -CommandName Invoke-JenkinsCommand `
                -ModuleName Jenkins `
                -MockWith { 'Invoke Result' }

            $splat = $inokeJenkinsJob_Parameters.Clone()
            $splat.Folder = 'test1\test2/test3'
            $result = Invoke-JenkinsJob @splat

            It 'Should return expected XML' {
                $result | Should -Be 'Invoke Result'
            }

            It 'Should return call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-JenkinsCommand `
                    -ModuleName Jenkins `
                    -ParameterFilter {
                    $bodyObject = ConvertTo-Json -InputObject $Body
                    $Command -eq "job/test1/job/test2/job/test3/job/$testJobName/build" -and `
                        $bodyObject.json -eq $null
                } `
                    -Exactly -Times 1
            }
        }

        Context 'When Name is set, no folder is passed and parameters are passed' {
            Mock `
                -CommandName Invoke-JenkinsCommand `
                -ModuleName Jenkins `
                -MockWith { 'Invoke Result' }

            $splat = $inokeJenkinsJob_Parameters.Clone()
            $splat.Parameters = @{
                parameter1 = 'value1'
                parameter2 = 'value2'
            }
            $result = Invoke-JenkinsJob @splat

            It 'Should return expected XML' {
                $result | Should -Be 'Invoke Result'
            }

            It 'Should return call expected mocks' {
                Assert-MockCalled `
                    -CommandName Invoke-JenkinsCommand `
                    -ModuleName Jenkins `
                    -ParameterFilter {
                    $parameters = ConvertFrom-Json -InputObject $body.json;
                    $Command -eq "job/$testJobName/build" -and `
                        $parameters.parameter.value -contains 'value1' -and `
                        $parameters.parameter.name -contains 'parameter1' -and `
                        $parameters.parameter.value -contains 'value2' -and `
                        $parameters.parameter.name -contains 'parameter2'
                } `
                    -Exactly -Times 1
            }
        }
    }
}
