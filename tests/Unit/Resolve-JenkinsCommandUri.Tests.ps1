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

    Describe 'Resolve-JenkinsCommandUri.when ony an endpoint' {
        It 'should resolve' {
            Resolve-JenkinsCommandUri -Command 'Fubar Snafu' | Should -Be 'Fubar Snafu'
        }
    }

    Describe 'Resolve-JenkinsCommandUri.when folders seperated by forward slash' {
        It 'should resolve' {
            Resolve-JenkinsCommandUri -Command 'create' -Folder 'Fizz Buzz/Buzz Fizz' |
            Should -Be 'job/Fizz Buzz/job/Buzz Fizz/create'
        }
    }

    Describe 'Resolve-JenkinsCommandUri.when folders seperated by backward slash' {
        It 'should resolve' {
            Resolve-JenkinsCommandUri -Command 'create' -Folder 'Fizz Buzz\Buzz Fizz' |
            Should -Be 'job/Fizz Buzz/job/Buzz Fizz/create'
        }
    }

    Describe 'Resolve-JenkinsCommandUri.when passing a job name' {
        It 'should resolve' {
            Resolve-JenkinsCommandUri -Folder 'one/two/three' -JobName 'Fubar Snafu' -Command 'config.xml' | Should -Be 'job/one/job/two/job/three/job/Fubar Snafu/config.xml'
        }
    }

    Describe 'Resolve-JenkinsCommandUri.when folder and job name are null' {
        It 'should resolve' {
            Resolve-JenkinsCommandUri -Folder $null -JobName $null -Command 'config.xml' | Should -Be 'config.xml'
        }
    }
}
