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
    $TestHelperPath = $PSScriptRoot | Split-Path -Parent | Join-Path -ChildPath 'TestHelper'
    Import-Module -Name $testHelperPath -Force

    $testURI = 'https://jenkins.contoso.com'
    $testTokenName = 'TestTokenName'

    Describe 'New-JenkinsApiToken' {
        $NewApiTokenParameters = @{
            Uri        = $testURI
            TokenName  = $testTokenName
        }

        Context 'When uri passed, credentials passed, valid token response returned' {
            Mock -CommandName Invoke-JenkinsCommand -ModuleName Jenkins `
                -MockWith { [PSCustomObject]@{
                    status = 'OK'
                    data = [PSCustomObject]@{
                        tokenName  = $testTokenName
                        tokenValue = '1234567890'
                        tokenUuid  = '9b585257-67af-453a-8d5f-d20195609838'
                    }
                }
            }

            $Splat = $NewApiTokenParameters.Clone()
            $Result = New-JenkinsApiToken @Splat

            It "Should return '1234567890'" {
                $Result.tokenValue | Should -Be '1234567890'
            }

            It "Should return call expected mocks" {
                Assert-MockCalled -CommandName Invoke-JenkinsCommand -ModuleName Jenkins `
                    -ParameterFilter {
                        $Uri -eq $testURI -and `
                        $Command -eq 'me/descriptorByName/jenkins.security.ApiTokenProperty/generateNewToken' -and `
                        $Type -eq 'command' -and `
                        $Body -is [hashtable] -and `
                        ([hashtable] $Body).ContainsKey('newTokenName')
                    } -Exactly 1
            }
        }

        Context 'When uri passed, credentials passed, invalid name returned' {
            Mock -CommandName Invoke-JenkinsCommand -ModuleName Jenkins `
                -MockWith { [PSCustomObject]@{
                    status = 'OK'
                    data = [PSCustomObject]@{
                        tokenName  = 'IncorrectTokenName'
                        tokenValue = '1234567890'
                        tokenUuid  = '9b585257-67af-453a-8d5f-d20195609838'
                    }
                }
            }

            $Splat = $NewApiTokenParameters.Clone()

            It "Should throw exception" {
                { New-JenkinsApiToken @Splat } | Should -Throw 'API Token creation response has returned a token with an unexpected name ''IncorrectTokenName''.'
            }

            It "Should return call expected mocks" {
                Assert-MockCalled -CommandName Invoke-JenkinsCommand -ModuleName Jenkins `
                    -ParameterFilter {
                        $Uri -eq $testURI -and `
                        $Command -eq 'me/descriptorByName/jenkins.security.ApiTokenProperty/generateNewToken' -and `
                        $Type -eq 'command' -and `
                        $Body -is [hashtable] -and `
                        ([hashtable] $Body).ContainsKey('newTokenName')
                    } -Exactly 1
            }
        }

        Context 'When uri passed, credentials passed, invalid base response returned' {
            Mock -CommandName Invoke-JenkinsCommand -ModuleName Jenkins `
                -MockWith { [PSCustomObject]@{
                    status = 'OK'
                }
            }

            $Splat = $NewApiTokenParameters.Clone()

            It "Should throw exception" {
                { New-JenkinsApiToken @Splat } | Should -Throw 'API Token creation response is missing property ''data''.'
            }

            It "Should return call expected mocks" {
                Assert-MockCalled -CommandName Invoke-JenkinsCommand -ModuleName Jenkins `
                    -ParameterFilter {
                        $Uri -eq $testURI -and `
                        $Command -eq 'me/descriptorByName/jenkins.security.ApiTokenProperty/generateNewToken' -and `
                        $Type -eq 'command' -and `
                        $Body -is [hashtable] -and `
                        ([hashtable] $Body).ContainsKey('newTokenName')
                    } -Exactly 1
            }
        }

        Context 'When uri passed, credentials passed, invalid token response returned' {
            Mock -CommandName Invoke-JenkinsCommand -ModuleName Jenkins `
                -MockWith { [PSCustomObject]@{
                    status = 'OK'
                    data = [PSCustomObject]@{
                        tokenName  = 'IncorrectTokenName'
                        tokenValue = '1234567890'
                    }
                }
            }

            $Splat = $NewApiTokenParameters.Clone()

            It "Should throw exception" {
                { New-JenkinsApiToken @Splat } | Should -Throw 'API Token creation response has unexpected members: tokenName, tokenValue.'
            }

            It "Should return call expected mocks" {
                Assert-MockCalled -CommandName Invoke-JenkinsCommand -ModuleName Jenkins `
                    -ParameterFilter {
                        $Uri -eq $testURI -and `
                        $Command -eq 'me/descriptorByName/jenkins.security.ApiTokenProperty/generateNewToken' -and `
                        $Type -eq 'command' -and `
                        $Body -is [hashtable] -and `
                        ([hashtable] $Body).ContainsKey('newTokenName')
                    } -Exactly 1
            }
        }
    }
}
