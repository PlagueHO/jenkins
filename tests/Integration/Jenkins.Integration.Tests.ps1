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

$testHelperPath = "$PSScriptRoot\..\TestHelper"
Import-Module -Name $testHelperPath -Force

Describe 'Jenkins Module Integration tests' {
    BeforeAll {
        # Ensure Linux Docker engine is running on Windows
        if ($null -eq $IsWindows -or $IsWindows)
        {
            Write-Verbose -Message 'Switching Docker Engine to Linux' -Verbose
            & $ENV:ProgramFiles\Docker\Docker\DockerCli.exe -SwitchLinuxEngine
        }

        # Set up a Linux Docker container running Jenkins
        $script:dockerFolder = Join-Path -Path $PSScriptRoot -ChildPath 'docker'
        $script:jenkinsPort = 49001
        $script:jenkinsContainerName = 'jenkinstest'
        $script:jenkinsImageTag = 'plagueho/jenkins'
        $script:jenkinsUri = [System.UriBuilder]::new('http', 'localhost', $script:jenkinsPort)
        $script:jenkinsUsername = 'admin'
        $script:jenkinsPassword = 'admin'
        $script:jenkinsCredential = New-Object `
            -TypeName System.Management.Automation.PSCredential `
            -ArgumentList $script:jenkinsUsername, (ConvertTo-SecureString -String $script:jenkinsPassword -AsPlainText -Force)

        # Read all the Jenkins Job XML into a hash table
        $script:jenkinsJobXML = @{ }
        $script:jenkinsJobXMLPath = Join-Path -Path $PSScriptRoot -ChildPath 'jobxml'
        $script:jenkinsJobXMLFiles = Get-ChildItem -Path $script:jenkinsJobXMLPath -Filter '*.xml'

        foreach ($script:jenkinsJobXMLFile in $script:jenkinsJobXMLFiles)
        {
            $script:jenkinsJobXML += @{
                $script:jenkinsJobXMLFile.BaseName = (Get-Content -Path $script:jenkinsJobXMLFile.FullName -Raw)
            }
        }

        Write-Verbose -Message "Creating Docker jenkins image '$script:jenkinsImageTag'" -Verbose
        & docker ('image', 'build', '-t', $script:jenkinsImageTag, $script:dockerFolder)

        Write-Verbose -Message "Starting Docker jenkins container '$script:jenkinsContainerName' from image '$script:jenkinsImageTag'" -Verbose
        & docker ('run', '-d', '-p', "$($script:jenkinsPort):8080", '--name', $script:jenkinsContainerName, $script:jenkinsImageTag)

        $webClient = New-Object -TypeName System.Net.WebClient
        $jenkinsHealthCheckUri = [System.UriBuilder]::new($script:jenkinsUri.Uri)
        $jenkinsHealthCheckUri.Path = 'robots.txt'

        # Wait for the Jenkins Container to become ready
        $jenkinsReady = $false

        while (-not $jenkinsReady)
        {
            try
            {
                $null = $webClient.DownloadString($script:jenkinsUri.Uri)
                $jenkinsReady = $true
            }
            catch
            {
                Write-Verbose -Message "Jenkins is not ready yet: $_"
            }

            Write-Verbose -Message "Waiting for Docker jenkins container '$script:jenkinsContainerName' to be ready. Trying again in 5 seconds." -Verbose
            Start-Sleep -Seconds 5
        }
    }

    AfterAll {
        Write-Verbose -Message "Stopping Docker jenkins container '$script:jenkinsContainerName'" -Verbose
        & docker ('stop', $script:jenkinsContainerName)

        Write-Verbose -Message "Removing Docker jenkins container '$script:jenkinsContainerName'" -Verbose
        & docker ('rm', $script:jenkinsContainerName)

        Write-Verbose -Message "Removing Docker jenkins image '$script:jenkinsImageTag'" -Verbose
        & docker ('rmi', $script:jenkinsImageTag)
    }

    Context 'When getting Jenkins Crumb' {
        $getJenkinsCrumb_Parameters = @{
            Uri        = $script:jenkinsUri
            Credential = $script:jenkinsCredential
            Verbose    = $true
        }

        $script:jenkinsCrumb = Get-JenkinsCrumb @getJenkinsCrumb_Parameters

        It 'Should return a valid crumb' {
            $script:jenkinsCrumb | Should -Not -BeNullOrEmpty
        }
    }

    Context 'When creating a new Jenkins Job in the root folder' {
        $newJenkinsJob_Parameters = @{
            Uri        = $script:jenkinsUri
            Name       = 'Test'
            XML        = $script:jenkinsJobXML['testjob']
            Credential = $script:jenkinsCredential
            Crumb      = $script:jenkinsCrumb
            Verbose    = $true
        }

        It 'Should not throw an exception' {
            {
                New-JenkinsJob @newJenkinsJob_Parameters
            } | Should -Not -Throw
        }
    }

    Context 'When getting a Jenkins Job from the root folder' {
        $getJenkinsJob_Parameters = @{
            Uri        = $script:jenkinsUri
            Name       = 'Test'
            Credential = $script:jenkinsCredential
            Crumb      = $script:jenkinsCrumb
            Verbose    = $true
        }

        It 'Should return the expected Job XML' {
            $xmlString = Get-JenkinsJob @getJenkinsJob_Parameters
            $xml = [System.Xml.XmlDocument]::new()
            $xml.LoadXml($xmlString)
            $xml.project.description | Should -Be 'Test Job'
        }
    }

    Context 'When invoking a Jenkins Job from the root folder' {
        $invokeJenkinsJob_Parameters = @{
            Uri        = $script:jenkinsUri
            Name       = 'Test'
            Credential = $script:jenkinsCredential
            Crumb      = $script:jenkinsCrumb
            Verbose    = $true
        }

        It 'Should not throw an exception' {
            {
                Invoke-JenkinsJob @invokeJenkinsJob_Parameters
            } | Should -Not -Throw
        }
    }

    Context 'When removing a Jenkins Job from the root folder' {
        $removeJenkinsJob_Parameters = @{
            Uri        = $script:jenkinsUri
            Name       = 'Test'
            Credential = $script:jenkinsCredential
            Crumb      = $script:jenkinsCrumb
            Force      = $true
            Verbose    = $true
        }

        It 'Should not throw an exception' {
            {
                Remove-JenkinsJob @removeJenkinsJob_Parameters
            } | Should -Not -Throw
        }
    }

    Context 'When creating a new Jenkins Job with Parameters in the root folder' {
        $newJenkinsJob_Parameters = @{
            Uri        = $script:jenkinsUri
            Name       = 'Test'
            XML        = $script:jenkinsJobXML['testjobwithparameter']
            Credential = $script:jenkinsCredential
            Crumb      = $script:jenkinsCrumb
            Verbose    = $true
        }

        It 'Should not throw an exception' {
            {
                New-JenkinsJob @newJenkinsJob_Parameters
            } | Should -Not -Throw
        }
    }

    Context 'When getting a Jenkins Job with Parameters from the root folder' {
        $getJenkinsJob_Parameters = @{
            Uri        = $script:jenkinsUri
            Name       = 'Test'
            Credential = $script:jenkinsCredential
            Crumb      = $script:jenkinsCrumb
            Verbose    = $true
        }

        It 'Should return the expected Job XML' {
            $xmlString = Get-JenkinsJob @getJenkinsJob_Parameters
            $xml = [System.Xml.XmlDocument]::new()
            $xml.LoadXml($xmlString)
            $xml.project.description | Should -Be 'Test Job With Parameter'
        }
    }

    Context 'When invoking a Jenkins Job with Parameters from the root folder' {
        $invokeJenkinsJob_Parameters = @{
            Uri        = $script:jenkinsUri
            Name       = 'Test'
            Credential = $script:jenkinsCredential
            Crumb      = $script:jenkinsCrumb
            Parameters = @{
                testparameter = 'testvalue'
            }
            Verbose    = $true
        }

        It 'Should not throw an exception' {
            {
                Invoke-JenkinsJob @invokeJenkinsJob_Parameters
            } | Should -Not -Throw
        }
    }

    Context 'When removing a Jenkins Job with Parameters from the root folder' {
        $removeJenkinsJob_Parameters = @{
            Uri        = $script:jenkinsUri
            Name       = 'Test'
            Credential = $script:jenkinsCredential
            Crumb      = $script:jenkinsCrumb
            Force      = $true
            Verbose    = $true
        }

        It 'Should not throw an exception' {
            {
                Remove-JenkinsJob @removeJenkinsJob_Parameters
            } | Should -Not -Throw
        }
    }
}
