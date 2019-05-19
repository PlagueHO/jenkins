[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
[CmdletBinding()]
param (
)

if ($ENV:BHBuildSystem -in 'Travis CI','Unknown','')
{
    Write-Verbose -Message "Running Integration tests in '$ENV:BHBuildSystem' build system."
}
else
{
    Write-Warning -Message "Skipping Integration tests in '$ENV:BHBuildSystem' build system."
    return
}

$moduleManifestName = 'Jenkins.psd1'
$moduleRootPath = "$PSScriptRoot\..\..\src\"
$moduleManifestPath = Join-Path -Path $moduleRootPath -ChildPath $moduleManifestName

Import-Module -Name $ModuleManifestPath -Force
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelper') -Force

Describe 'Jenkins Module Integration tests' {
    BeforeAll {
        # Ensure Linux Docker engine is running on Windows
        if ($null -eq $IsWindows -or $IsWindows)
        {
            Write-Verbose -Message 'Switching Docker Engine to Linux' -Verbose
            & $ENV:ProgramFiles\Docker\Docker\DockerCli.exe -SwitchLinuxEngine
        }

        # Set up a Linux Docker container running Jenkins
        $dockerFolder = Join-Path -Path $PSScriptRoot -ChildPath 'docker'
        $jenkinsPort = 49001
        $jenkinsContainerName = 'jenkinstest'
        $jenkinsImageTag = 'plagueho/jenkins'

        Write-Verbose -Message "Creating Docker jenkins image '$jenkinsImageTag'" -Verbose
        & docker ('image','build','-t',$jenkinsImageTag,$dockerFolder)

        Write-Verbose -Message "Starting Docker jenkins container '$jenkinsContainerName' from image '$jenkinsImageTag'" -Verbose
        & docker ('run','-d','-p',"${jenkinsPort}:8080",'--name',$jenkinsContainerName,$jenkinsImageTag)

        $jenkinsUri        = [System.UriBuilder]::new('http','localhost',$jenkinsPort)
        $jenkinsUsername   = 'admin'
        $jenkinsPassword   = 'admin'
        $jenkinsCredential = New-Object `
            -TypeName System.Management.Automation.PSCredential `
            -ArgumentList $jenkinsUsername, (ConvertTo-SecureString -String $jenkinsPassword -AsPlainText -Force)

        $webClient = New-Object -TypeName System.Net.WebClient
        $jenkinsHealthCheckUri = [System.UriBuilder]::new($jenkinsUri.Uri)
        $jenkinsHealthCheckUri.Path = 'robots.txt'

        # Wait for the Jenkins Container to become ready
        $jenkinsReady = $false

        while (-not $jenkinsReady)
        {
            try
            {
                $null = $webClient.DownloadString($jenkinsUri.Uri)
                $jenkinsReady = $true
            }
            catch
            {
                Write-Verbose -Message "Jenkins is not ready yet: $_"
            }

            Write-Verbose -Message "Waiting for Docker jenkins container '$jenkinsContainerName' to be ready. Trying again in 5 seconds." -Verbose
            Start-Sleep -Seconds 5
        }

        # Read all the Jenkins Job XML into a hash table
        $jenkinsJobXML = @{}
        $jenkinsJobXmlPath = Join-Path -Path $PSScriptRoot -ChildPath 'jobxml'
        $jenkinsJobXmlFiles = Get-ChildItem -Path $jenkinsJobXmlPath -Filter '*.xml'

        foreach ($jenkinsJobXmlFile in $jenkinsJobXmlFiles)
        {
            $jenkinsJobXML += @{ $jenkinsJobXmlFile.BaseName = (Get-Content -Path $jenkinsJobXmlFile.FullName -Raw) }
        }
    }

    AfterAll {
        Write-Verbose -Message "Stopping Docker jenkins container '$jenkinsContainerName'" -Verbose
        & docker ('stop',$jenkinsContainerName)

        Write-Verbose -Message "Removing Docker jenkins container '$jenkinsContainerName'" -Verbose
        & docker ('rm',$jenkinsContainerName)

        Write-Verbose -Message "Removing Docker jenkins image '$jenkinsImageTag'" -Verbose
        & docker ('rmi',$jenkinsImageTag)
    }

    Context 'When getting Jenkins Crumb' {
        $getJenkinsCrumb_Parameters = @{
            Uri        = $jenkinsUri
            Credential = $jenkinsCredential
            Verbose    = $true
        }

        $script:jenkinsCrumb = Get-JenkinsCrumb @getJenkinsCrumb_Parameters

        It 'Should return a valid crumb' {
            $script:jenkinsCrumb | Should -Not -BeNullOrEmpty
        }
    }

    Context 'When creating a new Jenkins Job in the root folder' {
        $newJenkinsJob_Parameters = @{
            Uri        = $jenkinsUri
            Name       = 'Test'
            XML        = $jenkinsJobXML['testjobwithparameter']
            Credential = $jenkinsCredential
            Crumb      = $script:jenkinsCrumb
            Verbose    = $true
        }

        $result = New-JenkinsJob @newJenkinsJob_Parameters
        Write-Verbose -Message ($result | Out-String) -Verbose

        It 'Should return a valid crumb' {
            $script:jenkinsCrumb | Should -Not -BeNullOrEmpty
        }
    }
}
