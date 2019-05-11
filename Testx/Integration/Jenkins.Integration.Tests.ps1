[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
[CmdletBinding()]
param (
)

$moduleManifestName = 'Jenkins.psd1'
$moduleRootPath = "$PSScriptRoot\..\..\src\"
$moduleManifestPath = Join-Path -Path $moduleRootPath -ChildPath $moduleManifestName

Import-Module -Name $ModuleManifestPath -Force
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelper') -Force

$testURI        = 'http:\\localhost'
$testUsername   = 'DummyUser'
$testPassword   = 'DummyPassword'
$testCredential = New-Object `
    -TypeName System.Management.Automation.PSCredential `
    -ArgumentList $testUsername, (ConvertTo-SecureString -String $testPassword -AsPlainText -Force)
$Bytes          = [System.Text.Encoding]::UTF8.GetBytes($testUsername + ':' + $testPassword)
$Base64Bytes    = [System.Convert]::ToBase64String($Bytes)
$testAuthHeader = "Basic $Base64Bytes"
$testJobName    = 'TestJob'

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

        $Splat = $inokeJenkinsJob_Parameters.Clone()
        $result = Invoke-JenkinsJob @Splat

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

        $Splat = $inokeJenkinsJob_Parameters.Clone()
        $Splat.Folder = 'test'
        $result = Invoke-JenkinsJob @Splat

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

        $Splat = $inokeJenkinsJob_Parameters.Clone()
        $Splat.Folder = 'test1\test2'
        $result = Invoke-JenkinsJob @Splat

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

        $Splat = $inokeJenkinsJob_Parameters.Clone()
        $Splat.Folder = 'test1/test2'
        $result = Invoke-JenkinsJob @Splat

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

        $Splat = $inokeJenkinsJob_Parameters.Clone()
        $Splat.Folder = 'test1\test2/test3'
        $result = Invoke-JenkinsJob @Splat

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

        $Splat = $inokeJenkinsJob_Parameters.Clone()
        $Splat.Parameters = @{
            parameter1 = 'value1'
            parameter2 = 'value2'
        }
        $result = Invoke-JenkinsJob @Splat

        It 'Should return expected XML' {
            $result | Should -Be 'Invoke Result'
        }

        It 'Should return call expected mocks' {
            Assert-MockCalled `
                -CommandName Invoke-JenkinsCommand `
                -ModuleName Jenkins `
                -ParameterFilter {
                    $Command -eq "job/$testJobName/build" -and `
                    $body.parameter.value -contains 'value1' -and `
                    $body.parameter.name -contains 'parameter1' -and `
                    $body.parameter.value -contains 'value2' -and `
                    $body.parameter.name -contains 'parameter2'
                } `
                -Exactly -Times 1
        }
    }
}
