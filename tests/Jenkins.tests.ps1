[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
[CmdletBinding()]
param (
)

$moduleManifestName = 'Jenkins.psd1'
$moduleRootPath = "$PSScriptRoot\..\src\"
$moduleManifestPath = Join-Path -Path $moduleRootPath -ChildPath $moduleManifestName

Describe 'Module Manifest Tests' {
    It 'Passes Test-ModuleManifest' {
        Test-ModuleManifest -Path $moduleManifestPath | Should -Not -BeNullOrEmpty
        $? | Should -Be $true
    }
}

Describe 'PSScriptAnalyzer' -Tag 'PSScriptAnalyzer' {
    Import-Module -Name 'PSScriptAnalyzer'

    Context 'Jenkins Module code and Jenkins Lib Functions' {
        It 'Passes Invoke-ScriptAnalyzer' {
            # Perform PSScriptAnalyzer scan.
            $PSScriptAnalyzerResult = Invoke-ScriptAnalyzer `
                -path "$moduleRootPath\Jenkins.psm1" `
                -Severity Warning `
                -ErrorAction SilentlyContinue
            $PSScriptAnalyzerResult += Invoke-ScriptAnalyzer `
                -path "$moduleRootPath\lib\*.ps1" `
                -excluderule "PSAvoidUsingUserNameAndPassWordParams" `
                -Severity Warning `
                -ErrorAction SilentlyContinue
            $PSScriptAnalyzerErrors = $PSScriptAnalyzerResult | Where-Object { $_.Severity -eq 'Error' }
            $PSScriptAnalyzerWarnings = $PSScriptAnalyzerResult | Where-Object { $_.Severity -eq 'Warning' }

            if ($PSScriptAnalyzerErrors -ne $null)
            {
                Write-Warning -Message 'There are PSScriptAnalyzer errors that need to be fixed:'
                @($PSScriptAnalyzerErrors).Foreach( {
                    Write-Warning -Message "$($_.Scriptname) (Line $($_.Line)): $($_.Message)"
                } )
                Write-Warning -Message  'For instructions on how to run PSScriptAnalyzer on your own machine, please go to https://github.com/powershell/psscriptAnalyzer/'
                $PSScriptAnalyzerErrors.Count | Should -Be $null
            }

            if ($PSScriptAnalyzerWarnings -ne $null)
            {
                Write-Warning -Message 'There are PSScriptAnalyzer warnings that should be fixed:'
                @($PSScriptAnalyzerWarnings).Foreach( {
                    Write-Warning -Message "$($_.Scriptname) (Line $($_.Line)): $($_.Message)"
                } )
            }
        }
    }
}

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
        [String]
        $ErrorId,

        [Parameter(Mandatory)]
        [System.Management.Automation.ErrorCategory]
        $ErrorCategory,

        [Parameter(Mandatory)]
        [String]
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

$testURI        = 'https://jenkins.contoso.com'
$testUsername   = 'DummyUser'
$testPassword   = 'DummyPassword'
$testCredential = New-Object -TypeName System.Management.Automation.PSCredential `
    -ArgumentList $testUsername, ( ConvertTo-SecureString -String $testPassword -AsPlainText -Force)
$testCommand    = 'CommandTest'
$Bytes          = [System.Text.Encoding]::UTF8.GetBytes($testUsername + ':' + $testPassword)
$Base64Bytes    = [System.Convert]::ToBase64String($Bytes)
$testAuthHeader = "Basic $Base64Bytes"
$testJobName    = 'TestJob'

InModuleScope 'Jenkins' {
    Describe 'Set-JenkinsTLSSupport' {
        It "Should not throw" {
            { Set-JenkinsTLSSupport } | Should -Not -Throw
        }

        It "Security Protocol Type should contain 'Tls12'" {
            ([Net.ServicePointManager]::SecurityProtocol).ToString().Contains([Net.SecurityProtocolType]::Tls12) | Should -Be $true
        }
    }

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
    } # Describe
} # InModuleScope

Describe 'Get-JenkinsCrumb' {
    $GetJenkinsCrumbSplat = @{
        Uri        = $testURI
        Credential = $testCredential
    }

    Context 'When uri passed, credentials passed, standard crumb returned' {
        Mock -CommandName Set-JenkinsTLSSupport -ModuleName Jenkins

        Mock -CommandName Invoke-WebRequest -ModuleName Jenkins `
            -MockWith { Throw 'Invoke-RestMethod called with incorrect parameters' }

        Mock -CommandName Invoke-WebRequest -ModuleName Jenkins `
            -ParameterFilter {
                $Uri -eq ('{0}/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)' -f $testURI) -and `
                $Headers.Count -eq 1 -and `
                $Headers['Authorization'] -eq $testAuthHeader
            } `
            -MockWith { [pscustomobject] @{ Content = 'Jenkins-Crumb:1234567890' } }
        $Splat = $GetJenkinsCrumbSplat.Clone()
        $Result = Get-JenkinsCrumb @Splat
        It "Should return '1234567890'" {
            $Result | Should -Be '1234567890'
        }
        It "Should return call expected mocks" {
            Assert-MockCalled -CommandName Set-JenkinsTLSSupport -ModuleName Jenkins -Exactly 1

            Assert-MockCalled -CommandName Invoke-WebRequest -ModuleName Jenkins `
                -ParameterFilter {
                    $Uri -eq ('{0}/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)' -f $testURI) -and `
                    $Headers.Count -eq 1 -and `
                    $Headers['Authorization'] -eq $testAuthHeader
                } `
                -Exactly 1
        }
    } # Context

    Context 'When uri passed, credentials passed, internal crumb returned' {
        Mock -CommandName Set-JenkinsTLSSupport -ModuleName Jenkins

        Mock -CommandName Invoke-WebRequest -ModuleName Jenkins `
            -MockWith { Throw 'Invoke-RestMethod called with incorrect parameters' }

        Mock -CommandName Invoke-WebRequest -ModuleName Jenkins `
            -ParameterFilter {
                $Uri -eq ('{0}/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)' -f $testURI) -and `
                $Headers.Count -eq 1 -and `
                $Headers['Authorization'] -eq $testAuthHeader
            } `
            -MockWith { [pscustomobject] @{ Content = '.crumb:1234567890' } }
        $Splat = $GetJenkinsCrumbSplat.Clone()
        $Result = Get-JenkinsCrumb @Splat
        It "Should return '1234567890'" {
            $Result | Should -Be '1234567890'
        }
        It "Should return call expected mocks" {
            Assert-MockCalled -CommandName Set-JenkinsTLSSupport -ModuleName Jenkins -Exactly 1

            Assert-MockCalled -CommandName Invoke-WebRequest -ModuleName Jenkins `
                -ParameterFilter {
                    $Uri -eq ('{0}/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)' -f $testURI) -and `
                    $Headers.Count -eq 1 -and `
                    $Headers['Authorization'] -eq $testAuthHeader
                } `
                -Exactly 1
        }
    } # Context

    Context 'When uri passed, credentials passed, invalid crumb returned' {
        Mock -CommandName Set-JenkinsTLSSupport -ModuleName Jenkins

        Mock -CommandName Invoke-WebRequest -ModuleName Jenkins `
            -MockWith { Throw 'Invoke-RestMethod called with incorrect parameters' }

        Mock -CommandName Invoke-WebRequest -ModuleName Jenkins `
            -ParameterFilter {
                $Uri -eq ('{0}/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)' -f $testURI) -and `
                $Headers.Count -eq 1 -and `
                $Headers['Authorization'] -eq $testAuthHeader
            } `
            -MockWith { [pscustomobject] @{ Content = 'Invalid Crumb' } }
        $Splat = $GetJenkinsCrumbSplat.Clone()
        It "Should throw exception" {
            { $Result = Get-JenkinsCrumb @Splat } | Should -Throw 'Invalid Crumb'
        }
        It "Should return call expected mocks" {
            Assert-MockCalled -CommandName Set-JenkinsTLSSupport -ModuleName Jenkins -Exactly 1

            Assert-MockCalled -CommandName Invoke-WebRequest -ModuleName Jenkins `
                -ParameterFilter {
                    $Uri -eq ('{0}/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)' -f $testURI) -and `
                    $Headers.Count -eq 1 -and `
                    $Headers['Authorization'] -eq $testAuthHeader
                } `
                -Exactly 1
        }
    } # Context
} # Describe 'Get-JenkinsJob'

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
} # Describe 'Invoke-JenkinsCommand'

Describe 'Get-JenkinsObject' {
    Context 'When jobs type, attribute name, no folder, credentials passed' {
        $GetJenkinsObjectSplat = @{
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
        $Splat = $GetJenkinsObjectSplat.Clone()
        $Result = Get-JenkinsObject @Splat
        It "Should return expected objects" {
            $Result.Count | Should -Be 2
            $Result[0].Name | Should -Be 'test1'
            $Result[1].Name | Should -Be 'test2'
        }
        It "Should return call expected mocks" {
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
            Context $slash {
                $GetJenkinsObjectSplat = @{
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
                $Splat = $GetJenkinsObjectSplat.Clone()
                $Result = Get-JenkinsObject @Splat
                It "Should return expected objects" {
                    $Result.Count | Should -Be 2
                    $Result[0].Name | Should -Be 'test1'
                    $Result[1].Name | Should -Be 'test2'
                }
                It "Should return call expected mocks" {
                    Assert-MockCalled -CommandName Invoke-JenkinsCommand -ModuleName Jenkins `
                        -ParameterFilter {
                            $Command -eq '?tree=jobs[name,jobs[name,jobs[name]]]'
                        } `
                        -Exactly 1
                }
            } # Context
        } # foreach
    } # Context
} # Describe 'Get-JenkinsObject'

Describe 'Get-JenkinsJob' {
    $GetJenkinsJobSplat = @{
        Uri        = $testURI
        Credential = $testCredential
        Name       = $testJobName
    }

    Context 'When Name is set, no folder is passed' {
        Mock -CommandName Invoke-JenkinsCommand -ModuleName Jenkins `
            -MockWith { Throw "Invoke-RestMethod called with incorrect parameters" }
        Mock -CommandName Invoke-JenkinsCommand -ModuleName Jenkins `
            -ParameterFilter {
                $Command -eq "job/$testJobName/config.xml"
            } `
            -MockWith { @{ Content = 'JobXML'} }
        $Splat = $GetJenkinsJobSplat.Clone()
        $Result = Get-JenkinsJob @Splat
        It "Should return expected XML" {
            $Result | Should -Be 'JobXML'
        }
        It "Should return call expected mocks" {
            Assert-MockCalled -CommandName Invoke-JenkinsCommand -ModuleName Jenkins `
                -ParameterFilter {
                    $Command -eq "job/$testJobName/config.xml"
                } `
                -Exactly 1
        }
    }

    Context 'When Name is set, single folder is passed' {
        Mock -CommandName Invoke-JenkinsCommand -ModuleName Jenkins `
            -MockWith { Throw "Invoke-RestMethod called with incorrect parameters" }
        Mock -CommandName Invoke-JenkinsCommand -ModuleName Jenkins `
            -ParameterFilter {
                $Command -eq "job/test/job/$testJobName/config.xml"
            } `
            -MockWith { @{ Content = 'JobXML'} }
        $Splat = $GetJenkinsJobSplat.Clone()
        $Splat.Folder = 'test'
        $Result = Get-JenkinsJob @Splat
        It "Should return expected XML" {
            $Result | Should -Be 'JobXML'
        }
        It "Should return call expected mocks" {
            Assert-MockCalled -CommandName Invoke-JenkinsCommand -ModuleName Jenkins `
                -ParameterFilter {
                    $Command -eq "job/test/job/$testJobName/config.xml"
                } `
                -Exactly 1
        }
    } # Context

    Context 'When Name is set, two folders are passed separated by \' {
        Mock -CommandName Invoke-JenkinsCommand -ModuleName Jenkins `
            -MockWith { Throw "Invoke-RestMethod called with incorrect parameters" }
        Mock -CommandName Invoke-JenkinsCommand -ModuleName Jenkins `
            -ParameterFilter {
                $Command -eq "job/test1/job/test2/job/$testJobName/config.xml"
            } `
            -MockWith { @{ Content = 'JobXML'} }
        $Splat = $GetJenkinsJobSplat.Clone()
        $Splat.Folder = 'test1\test2'
        $Result = Get-JenkinsJob @Splat
        It "Should return expected XML" {
            $Result | Should -Be 'JobXML'
        }
        It "Should return call expected mocks" {
            Assert-MockCalled -CommandName Invoke-JenkinsCommand -ModuleName Jenkins `
                -ParameterFilter {
                    $Command -eq "job/test1/job/test2/job/$testJobName/config.xml"
                } `
                -Exactly 1
        }
    } # Context

    Context 'When Name is set, two folders are passed separated by /' {
        Mock -CommandName Invoke-JenkinsCommand -ModuleName Jenkins `
            -MockWith { Throw "Invoke-RestMethod called with incorrect parameters" }
        Mock -CommandName Invoke-JenkinsCommand -ModuleName Jenkins `
            -ParameterFilter {
                $Command -eq "job/test1/job/test2/job/$testJobName/config.xml"
            } `
            -MockWith { @{ Content = 'JobXML'} }
        $Splat = $GetJenkinsJobSplat.Clone()
        $Splat.Folder = 'test1/test2'
        $Result = Get-JenkinsJob @Splat
        It "Should return expected XML" {
            $Result | Should -Be 'JobXML'
        }
        It "Should return call expected mocks" {
            Assert-MockCalled -CommandName Invoke-JenkinsCommand -ModuleName Jenkins `
                -ParameterFilter {
                    $Command -eq "job/test1/job/test2/job/$testJobName/config.xml"
                } `
                -Exactly 1
        }
    } # Context

    Context 'When Name is set, two folders are passed separated by \ and /' {
        Mock -CommandName Invoke-JenkinsCommand -ModuleName Jenkins `
            -MockWith { Throw "Invoke-RestMethod called with incorrect parameters" }
        Mock -CommandName Invoke-JenkinsCommand -ModuleName Jenkins `
            -ParameterFilter {
                $Command -eq "job/test1/job/test2/job/test3/job/$testJobName/config.xml"
            } `
            -MockWith { @{ Content = 'JobXML'} }
        $Splat = $GetJenkinsJobSplat.Clone()
        $Splat.Folder = 'test1\test2/test3'
        $Result = Get-JenkinsJob @Splat
        It "Should return expected XML" {
            $Result | Should -Be 'JobXML'
        }
        It "Should return call expected mocks" {
            Assert-MockCalled -CommandName Invoke-JenkinsCommand -ModuleName Jenkins `
                -ParameterFilter {
                    $Command -eq "job/test1/job/test2/job/test3/job/$testJobName/config.xml"
                } `
                -Exactly 1
        }
    } # Context

    Context 'When Jenkins returns Xml 1.1' {
        Mock -CommandName Invoke-JenkinsCommand -ModuleName Jenkins `
            -MockWith { [pscustomobject]@{ Content = @'
<?xml version='1.1' encoding='UTF-8'?>
<project />
'@ } }
        $Splat = $GetJenkinsJobSplat.Clone()
        $Splat.Folder = 'test1\test2/test3'
        $Result = Get-JenkinsJob @Splat
        It 'should return XML parseable by .NET' {
            { [xml]$Result } | Should -Not -Throw
        }
    } # Context
} # Describe 'Get-JenkinsJob'
