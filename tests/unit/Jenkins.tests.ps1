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
            -Confirm:$False `
            -Scope CurrentUser
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
        Describe 'Get-JenkinsTreeRequest' {
            Context 'default depth, default type, default attribute' {
                It "should return '?tree=jobs[name,buildable,url,color]'" {
                    Get-JenkinsTreeRequest |
                        Should Be '?tree=jobs[name,buildable,url,color]'
                }
            }
            Context 'depth 2, default type, default attribute' {
                It "should return '?tree=jobs[name,buildable,url,color,jobs[name,buildable,url,color]]'" {
                    Get-JenkinsTreeRequest -Depth 2 |
                        Should Be '?tree=jobs[name,buildable,url,color,jobs[name,buildable,url,color]]'
                }
            }
            Context 'depth 2, type views, default attribute' {
                It "should return '?tree=Views[name,buildable,url,color,Views[name,buildable,url,color]]'" {
                    Get-JenkinsTreeRequest -Depth 2 -Type 'Views' |
                        Should Be '?tree=Views[name,buildable,url,color,Views[name,buildable,url,color]]'
                }
            }
            Context 'depth 3, type views, attribute name,url' {
                It "should return '?tree=Views[name,url,Views[name,url,Views[name,url]]]'" {
                    Get-JenkinsTreeRequest -Depth 3 -Type 'Views' -Attribute @('name','url') |
                        Should Be '?tree=Views[name,url,Views[name,url,Views[name,url]]]'
                }
            }
        } # Describe
    } # InModuleScope

    Describe 'Get-JenkinsCrumb' {
        $GetJenkinsCrumbSplat = @{
            Uri        = $testURI
            Credential = $testCredential
        }

        Context 'uri passed, credentials passed, standard crumb returned' {
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
            It "should return '1234567890'" {
                $Result | Should Be '1234567890'
            }
            It "should return call expected mocks" {
                Assert-MockCalled -CommandName Invoke-WebRequest -ModuleName Jenkins `
                    -ParameterFilter {
                        $Uri -eq ('{0}/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)' -f $testURI) -and `
                        $Headers.Count -eq 1 -and `
                        $Headers['Authorization'] -eq $testAuthHeader
                    } `
                    -Exactly 1
            }
        } # Context

        Context 'uri passed, credentials passed, internal crumb returned' {
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
            It "should return '1234567890'" {
                $Result | Should Be '1234567890'
            }
            It "should return call expected mocks" {
                Assert-MockCalled -CommandName Invoke-WebRequest -ModuleName Jenkins `
                    -ParameterFilter {
                        $Uri -eq ('{0}/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)' -f $testURI) -and `
                        $Headers.Count -eq 1 -and `
                        $Headers['Authorization'] -eq $testAuthHeader
                    } `
                    -Exactly 1
            }
        } # Context

        Context 'uri passed, credentials passed, invalid crumb returned' {
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
            It "should throw exception" {
                { $Result = Get-JenkinsCrumb @Splat } | Should Throw 'Invalid Crumb'
            }
            It "should return call expected mocks" {
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

        Context 'default type, default api, credentials passed' {
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
            It "should return 'Invoke-RestMethod Result'" {
                $Result | Should Be 'Invoke-RestMethod Result'
            }
            It "should return call expected mocks" {
                Assert-MockCalled -CommandName Invoke-RestMethod -ModuleName Jenkins `
                    -ParameterFilter {
                        $Uri -eq "$testURI/api/json/$testCommand" -and `
                        $Headers.Count -eq 1 -and `
                        $Headers['Authorization'] -eq $testAuthHeader
                    } `
                    -Exactly 1
            }
        } # Context

        Context 'default type, default api, no credentials passed' {
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
            It "should return 'Invoke-RestMethod Result'" {
                $Result | Should Be 'Invoke-RestMethod Result'
            }
            It "should return call expected mocks" {
                Assert-MockCalled -CommandName Invoke-RestMethod -ModuleName Jenkins `
                    -ParameterFilter {
                    $Uri -eq "$testURI/api/json/$testCommand" -and `
                    $Headers.Count -eq 0
                    } `
                    -Exactly 1
            }
        } # Context

        Context 'default type, xml api, credentials passed' {
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
            It "should return 'Invoke-RestMethod Result'" {
                $Result | Should Be 'Invoke-RestMethod Result'
            }
            It "should return call expected mocks" {
                Assert-MockCalled -CommandName Invoke-RestMethod -ModuleName Jenkins `
                    -ParameterFilter {
                        $Uri -eq "$testURI/api/xml/$testCommand" -and `
                        $Headers.Count -eq 1 -and `
                        $Headers['Authorization'] -eq $testAuthHeader
                    } `
                    -Exactly 1
            }
        } # Context

        Context 'default type, xml api, credentials passed, header passed' {
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
            It "should return 'Invoke-RestMethod Result'" {
                $Result | Should Be 'Invoke-RestMethod Result'
            }
            It "should return call expected mocks" {
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

        Context 'default type, xml api, credentials passed, header passed, get method' {
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
            It "should return 'Invoke-RestMethod Result'" {
                $Result | Should Be 'Invoke-RestMethod Result'
            }
            It "should return call expected mocks" {
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

        Context 'default type, xml api, credentials passed, body passed' {
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
            It "should return 'Invoke-RestMethod Result'" {
                $Result | Should Be 'Invoke-RestMethod Result'
            }
            It "should return call expected mocks" {
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

        Context 'command type, default api, credentials passed' {
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
            It "should return 'Invoke-WebRequest Result'" {
                $Result | Should Be 'Invoke-WebRequest Result'
            }
            It "should return call expected mocks" {
                Assert-MockCalled -CommandName Invoke-WebRequest -ModuleName Jenkins `
                    -ParameterFilter {
                        $Uri -eq "$testURI/$testCommand" -and `
                        $Headers.Count -eq 1 -and `
                        $Headers['Authorization'] -eq $testAuthHeader
                    } `
                    -Exactly 1
            }
        } # Context

        Context 'pluginmanager type, default api, credentials passed' {
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
            It "should return 'Invoke-WebRequest Result'" {
                $Result | Should Be 'Invoke-WebRequest Result'
            }
            It "should return call expected mocks" {
                Assert-MockCalled -CommandName Invoke-WebRequest -ModuleName Jenkins `
                    -ParameterFilter {
                        $Uri -eq "$testURI/pluginManager/api/json/?$testCommand" -and `
                        $Headers.Count -eq 1 -and `
                        $Headers['Authorization'] -eq $testAuthHeader
                    } `
                    -Exactly 1
            }
        } # Context

        Context 'pluginmanager type, xml api, credentials passed' {
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
            It "should return 'Invoke-WebRequest Result'" {
                $Result | Should Be 'Invoke-WebRequest Result'
            }
            It "should return call expected mocks" {
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
        $GetJenkinsObjectSplat = @{
            Uri        = $testURI
            Credential = $testCredential
            Type       = 'jobs'
            Attribute = @('name')
        }

        Context 'jobs type, attribute name, no folder, credentials passed' {
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
            It "should return expected objects" {
                $Result.Count | Should Be 2
                $Result[0].Name | Should Be 'test1'
                $Result[1].Name | Should Be 'test2'
            }
            It "should return call expected mocks" {
                Assert-MockCalled -CommandName Invoke-JenkinsCommand -ModuleName Jenkins `
                    -ParameterFilter {
                        $Command -eq '?tree=jobs[name]'
                    } `
                    -Exactly 1
            }
        } # Context
    } # Describe 'Get-JenkinsObject'

    Describe 'Get-JenkinsJob' {
        $GetJenkinsJobSplat = @{
            Uri        = $testURI
            Credential = $testCredential
            Name       = $testJobName
        }

        Context 'Name is set, no folder is passed' {
            Mock -CommandName Invoke-JenkinsCommand -ModuleName Jenkins `
                -MockWith { Throw "Invoke-RestMethod called with incorrect parameters" }
            Mock -CommandName Invoke-JenkinsCommand -ModuleName Jenkins `
                -ParameterFilter {
                    $Command -eq "job/$testJobName/config.xml"
                } `
                -MockWith { @{ Content = 'JobXML'} }
            $Splat = $GetJenkinsJobSplat.Clone()
            $Result = Get-JenkinsJob @Splat
            It "should return expected XML" {
                $Result | Should Be 'JobXML'
            }
            It "should return call expected mocks" {
                Assert-MockCalled -CommandName Invoke-JenkinsCommand -ModuleName Jenkins `
                    -ParameterFilter {
                        $Command -eq "job/$testJobName/config.xml"
                    } `
                    -Exactly 1
            }
        }

        Context 'Name is set, single folder is passed' {
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
            It "should return expected XML" {
                $Result | Should Be 'JobXML'
            }
            It "should return call expected mocks" {
                Assert-MockCalled -CommandName Invoke-JenkinsCommand -ModuleName Jenkins `
                    -ParameterFilter {
                        $Command -eq "job/test/job/$testJobName/config.xml"
                    } `
                    -Exactly 1
            }
        } # Context

        Context 'Name is set, two folders are passed separated by \' {
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
            It "should return expected XML" {
                $Result | Should Be 'JobXML'
            }
            It "should return call expected mocks" {
                Assert-MockCalled -CommandName Invoke-JenkinsCommand -ModuleName Jenkins `
                    -ParameterFilter {
                        $Command -eq "job/test1/job/test2/job/$testJobName/config.xml"
                    } `
                    -Exactly 1
            }
        } # Context

        Context 'Name is set, two folders are passed separated by /' {
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
            It "should return expected XML" {
                $Result | Should Be 'JobXML'
            }
            It "should return call expected mocks" {
                Assert-MockCalled -CommandName Invoke-JenkinsCommand -ModuleName Jenkins `
                    -ParameterFilter {
                        $Command -eq "job/test1/job/test2/job/$testJobName/config.xml"
                    } `
                    -Exactly 1
            }
        } # Context

        Context 'Name is set, two folders are passed separated by \ and /' {
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
            It "should return expected XML" {
                $Result | Should Be 'JobXML'
            }
            It "should return call expected mocks" {
                Assert-MockCalled -CommandName Invoke-JenkinsCommand -ModuleName Jenkins `
                    -ParameterFilter {
                        $Command -eq "job/test1/job/test2/job/test3/job/$testJobName/config.xml"
                    } `
                    -Exactly 1
            }
        } # Context
    } # Describe 'Get-JenkinsJob'
}
catch
{
    throw $_
}
finally
{
    Pop-Location
}