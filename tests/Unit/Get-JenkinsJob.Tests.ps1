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
}
