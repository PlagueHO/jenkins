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

    Describe 'Invoke-JenkinsCommand' {
        $InvokeJenkinsCommandSplat = @{
            Uri        = $testURI
            Credential = $testCredential
            Command    = $testCommand
        }

        Context 'When default type, default api, credentials passed' {
            Mock -CommandName Set-JenkinsTLSSupport -ModuleName Jenkins

            Mock -CommandName Invoke-RestMethod -ModuleName Jenkins `
                -MockWith { Throw 'Invoke-RestMethod called with incorrect parameters' }

            Mock -CommandName Invoke-RestMethod -ModuleName Jenkins `
                -ParameterFilter {
                    $Uri -eq "$testURI/api/json/$testCommand" -and `
                    $Headers.Count -eq 1 -and `
                    $Headers['Authorization'] -eq $testAuthHeader
                } `
                -MockWith { 'Invoke-RestMethod Result' }
            $Splat = $InvokeJenkinsCommandSplat.Clone()
            $Result = Invoke-JenkinsCommand @Splat
            It "Should return 'Invoke-RestMethod Result'" {
                $Result | Should -Be 'Invoke-RestMethod Result'
            }
            It "Should return call expected mocks" {
                Assert-MockCalled -CommandName Set-JenkinsTLSSupport -ModuleName Jenkins -Exactly 1

                Assert-MockCalled -CommandName Invoke-RestMethod -ModuleName Jenkins `
                    -ParameterFilter {
                        $Uri -eq "$testURI/api/json/$testCommand" -and `
                        $Headers.Count -eq 1 -and `
                        $Headers['Authorization'] -eq $testAuthHeader
                    } `
                    -Exactly 1
            }
        } # Context

        Context 'When default type, default api, no credentials passed' {
            Mock -CommandName Set-JenkinsTLSSupport -ModuleName Jenkins

            Mock -CommandName Invoke-RestMethod -ModuleName Jenkins `
                -MockWith { Throw 'Invoke-RestMethod called with incorrect parameters' }

            Mock -CommandName Invoke-RestMethod -ModuleName Jenkins `
                -ParameterFilter {
                    $Uri -eq "$testURI/api/json/$testCommand" -and `
                    $Headers.Count -eq 0
                } `
                -MockWith { 'Invoke-RestMethod Result' }

            $Splat = $InvokeJenkinsCommandSplat.Clone()
            $Splat.Remove('Credential')
            $Result = Invoke-JenkinsCommand @Splat
            It "Should return 'Invoke-RestMethod Result'" {
                $Result | Should -Be 'Invoke-RestMethod Result'
            }
            It "Should return call expected mocks" {
                Assert-MockCalled -CommandName Set-JenkinsTLSSupport -ModuleName Jenkins -Exactly 1

                Assert-MockCalled -CommandName Invoke-RestMethod -ModuleName Jenkins `
                    -ParameterFilter {
                    $Uri -eq "$testURI/api/json/$testCommand" -and `
                    $Headers.Count -eq 0
                    } `
                    -Exactly 1
            }
        } # Context

        Context 'When default type, xml api, credentials passed' {
            Mock -CommandName Set-JenkinsTLSSupport -ModuleName Jenkins

            Mock -CommandName Invoke-RestMethod -ModuleName Jenkins `
                -MockWith { Throw 'Invoke-RestMethod called with incorrect parameters' }

            Mock -CommandName Invoke-RestMethod -ModuleName Jenkins `
                -ParameterFilter {
                    $Uri -eq "$testURI/api/xml/$testCommand" -and `
                    $Headers.Count -eq 1 -and `
                    $Headers['Authorization'] -eq $testAuthHeader
                } `
                -MockWith { 'Invoke-RestMethod Result' }
            $Splat = $InvokeJenkinsCommandSplat.Clone()
            $Splat.api = 'xml'
            $Result = Invoke-JenkinsCommand @Splat
            It "Should return 'Invoke-RestMethod Result'" {
                $Result | Should -Be 'Invoke-RestMethod Result'
            }
            It "Should return call expected mocks" {
                Assert-MockCalled -CommandName Set-JenkinsTLSSupport -ModuleName Jenkins -Exactly 1

                Assert-MockCalled -CommandName Invoke-RestMethod -ModuleName Jenkins `
                    -ParameterFilter {
                        $Uri -eq "$testURI/api/xml/$testCommand" -and `
                        $Headers.Count -eq 1 -and `
                        $Headers['Authorization'] -eq $testAuthHeader
                    } `
                    -Exactly 1
            }
        } # Context

        Context 'When default type, xml api, credentials passed, header passed' {
            Mock -CommandName Set-JenkinsTLSSupport -ModuleName Jenkins

            Mock -CommandName Invoke-RestMethod -ModuleName Jenkins `
                -MockWith { Throw 'Invoke-RestMethod called with incorrect parameters' }

            Mock -CommandName Invoke-RestMethod -ModuleName Jenkins `
                -ParameterFilter {
                    $Uri -eq "$testURI/api/xml/$testCommand" -and `
                    $Headers.Count -eq 2 -and `
                    $Headers['Authorization'] -eq $testAuthHeader -and `
                    $Headers['Test'] -eq 'test'
                } `
                -MockWith { 'Invoke-RestMethod Result' }
            $Splat = $InvokeJenkinsCommandSplat.Clone()
            $Splat.api = 'xml'
            $Splat.headers = @{ test = 'test' }
            $Result = Invoke-JenkinsCommand @Splat
            It "Should return 'Invoke-RestMethod Result'" {
                $Result | Should -Be 'Invoke-RestMethod Result'
            }
            It "Should return call expected mocks" {
                Assert-MockCalled -CommandName Set-JenkinsTLSSupport -ModuleName Jenkins -Exactly 1

                Assert-MockCalled -CommandName Invoke-RestMethod -ModuleName Jenkins `
                    -ParameterFilter {
                        $Uri -eq "$testURI/api/xml/$testCommand" -and `
                        $Headers.Count -eq 2 -and `
                        $Headers['Authorization'] -eq $testAuthHeader -and `
                        $Headers['Test'] -eq 'test'
                    } `
                    -Exactly 1
            }
        } # Context

        Context 'When default type, xml api, credentials passed, header passed, get method' {
            Mock -CommandName Set-JenkinsTLSSupport -ModuleName Jenkins

            Mock -CommandName Invoke-RestMethod -ModuleName Jenkins `
                -MockWith { Throw 'Invoke-RestMethod called with incorrect parameters' }

            Mock -CommandName Invoke-RestMethod -ModuleName Jenkins `
                -ParameterFilter {
                    $Uri -eq "$testURI/api/xml/$testCommand" -and `
                    $Headers.Count -eq 2 -and `
                    $Headers['Authorization'] -eq $testAuthHeader -and `
                    $Headers['Test'] -eq 'test' -and `
                    $Method -eq 'get'
                } `
                -MockWith { 'Invoke-RestMethod Result' }
            $Splat = $InvokeJenkinsCommandSplat.Clone()
            $Splat.api = 'xml'
            $Splat.headers = @{ test = 'test' }
            $Splat.method = 'get'
            $Result = Invoke-JenkinsCommand @Splat
            It "Should return 'Invoke-RestMethod Result'" {
                $Result | Should -Be 'Invoke-RestMethod Result'
            }
            It "Should return call expected mocks" {
                Assert-MockCalled -CommandName Set-JenkinsTLSSupport -ModuleName Jenkins -Exactly 1

                Assert-MockCalled -CommandName Invoke-RestMethod -ModuleName Jenkins `
                    -ParameterFilter {
                        $Uri -eq "$testURI/api/xml/$testCommand" -and `
                        $Headers.Count -eq 2 -and `
                        $Headers['Authorization'] -eq $testAuthHeader -and `
                        $Headers['Test'] -eq 'test' -and
                        $Method -eq 'get'
                    } `
                    -Exactly 1
            }
        } # Context

        Context 'When default type, xml api, credentials passed, body passed' {
            Mock -CommandName Set-JenkinsTLSSupport -ModuleName Jenkins

            Mock -CommandName Invoke-RestMethod -ModuleName Jenkins `
                -MockWith { Throw 'Invoke-RestMethod called with incorrect parameters' }

            Mock -CommandName Invoke-RestMethod -ModuleName Jenkins `
                -ParameterFilter {
                    $Uri -eq "$testURI/api/xml/$testCommand" -and `
                    $Headers.Count -eq 1 -and `
                    $Headers['Authorization'] -eq $testAuthHeader -and `
                    $Body -eq 'body'
                } `
                -MockWith { 'Invoke-RestMethod Result' }
            $Splat = $InvokeJenkinsCommandSplat.Clone()
            $Splat.api = 'xml'
            $Splat.body = 'body'
            $Result = Invoke-JenkinsCommand @Splat
            It "Should return 'Invoke-RestMethod Result'" {
                $Result | Should -Be 'Invoke-RestMethod Result'
            }
            It "Should return call expected mocks" {
                Assert-MockCalled -CommandName Set-JenkinsTLSSupport -ModuleName Jenkins -Exactly 1

                Assert-MockCalled -CommandName Invoke-RestMethod -ModuleName Jenkins `
                    -ParameterFilter {
                        $Uri -eq "$testURI/api/xml/$testCommand" -and `
                        $Headers.Count -eq 1 -and `
                        $Headers['Authorization'] -eq $testAuthHeader -and `
                        $Body -eq 'body'
                    } `
                    -Exactly 1
            }
        } # Context

        Context 'When command type, default api, credentials passed' {
            Mock -CommandName Set-JenkinsTLSSupport -ModuleName Jenkins

            Mock -CommandName Invoke-WebRequest -ModuleName Jenkins `
                -MockWith { Throw 'Invoke-WebRequest called with incorrect parameters' }

            Mock -CommandName Invoke-WebRequest -ModuleName Jenkins `
                -ParameterFilter {
                    $Uri -eq "$testURI/$testCommand" -and `
                    $Headers.Count -eq 1 -and `
                    $Headers['Authorization'] -eq $testAuthHeader
                } `
                -MockWith { 'Invoke-WebRequest Result' }
            $Splat = $InvokeJenkinsCommandSplat.Clone()
            $Splat.Type = 'command'
            $Result = Invoke-JenkinsCommand @Splat
            It "Should return 'Invoke-WebRequest Result'" {
                $Result | Should -Be 'Invoke-WebRequest Result'
            }
            It "Should return call expected mocks" {
                Assert-MockCalled -CommandName Set-JenkinsTLSSupport -ModuleName Jenkins -Exactly 1

                Assert-MockCalled -CommandName Invoke-WebRequest -ModuleName Jenkins `
                    -ParameterFilter {
                        $Uri -eq "$testURI/$testCommand" -and `
                        $Headers.Count -eq 1 -and `
                        $Headers['Authorization'] -eq $testAuthHeader
                    } `
                    -Exactly 1
            }
        } # Context

        Context 'When pluginmanager type, default api, credentials passed' {
            Mock -CommandName Set-JenkinsTLSSupport -ModuleName Jenkins

            Mock -CommandName Invoke-WebRequest -ModuleName Jenkins `
                -MockWith { Throw 'Invoke-WebRequest called with incorrect parameters' }

            Mock -CommandName Invoke-WebRequest -ModuleName Jenkins `
                -ParameterFilter {
                    $Uri -eq "$testURI/pluginManager/api/json/?$testCommand" -and `
                    $Headers.Count -eq 1 -and `
                    $Headers['Authorization'] -eq $testAuthHeader
                } `
                -MockWith { 'Invoke-WebRequest Result' }
            $Splat = $InvokeJenkinsCommandSplat.Clone()
            $Splat.Type = 'pluginmanager'

            $Result = Invoke-JenkinsCommand @Splat
            It "Should return 'Invoke-WebRequest Result'" {
                $Result | Should -Be 'Invoke-WebRequest Result'
            }
            It "Should return call expected mocks" {
                Assert-MockCalled -CommandName Set-JenkinsTLSSupport -ModuleName Jenkins -Exactly 1

                Assert-MockCalled -CommandName Invoke-WebRequest -ModuleName Jenkins `
                    -ParameterFilter {
                        $Uri -eq "$testURI/pluginManager/api/json/?$testCommand" -and `
                        $Headers.Count -eq 1 -and `
                        $Headers['Authorization'] -eq $testAuthHeader
                    } `
                    -Exactly 1
            }
        } # Context

        Context 'When pluginmanager type, xml api, credentials passed' {
            Mock -CommandName Set-JenkinsTLSSupport -ModuleName Jenkins

            Mock -CommandName Invoke-WebRequest -ModuleName Jenkins `
                -MockWith { Throw 'Invoke-WebRequest called with incorrect parameters' }

            Mock -CommandName Invoke-WebRequest -ModuleName Jenkins `
                -ParameterFilter {
                    $Uri -eq "$testURI/pluginManager/api/xml/?$testCommand" -and `
                    $Headers.Count -eq 1 -and `
                    $Headers['Authorization'] -eq $testAuthHeader
                } `
                -MockWith { 'Invoke-WebRequest Result' }
            $Splat = $InvokeJenkinsCommandSplat.Clone()
            $Splat.Type = 'pluginmanager'
            $Splat.api = 'xml'

            $Result = Invoke-JenkinsCommand @Splat
            It "Should return 'Invoke-WebRequest Result'" {
                $Result | Should -Be 'Invoke-WebRequest Result'
            }
            It "Should return call expected mocks" {
                Assert-MockCalled -CommandName Set-JenkinsTLSSupport -ModuleName Jenkins -Exactly 1

                Assert-MockCalled -CommandName Invoke-WebRequest -ModuleName Jenkins `
                    -ParameterFilter {
                        $Uri -eq "$testURI/pluginManager/api/xml/?$testCommand" -and `
                        $Headers.Count -eq 1 -and `
                        $Headers['Authorization'] -eq $testAuthHeader
                    } `
                    -Exactly 1
            }
        } # Context
    }
}
