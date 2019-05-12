[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
[CmdletBinding()]
param (
)

if ($ENV:BHBuildSystem -eq 'AppVeyor')
{
    Write-Warning -Message 'Skipping Integration tests running in AppVeyor'
    return
}

$moduleManifestName = 'Jenkins.psd1'
$moduleRootPath = "$PSScriptRoot\..\..\src\"
$moduleManifestPath = Join-Path -Path $moduleRootPath -ChildPath $moduleManifestName

Import-Module -Name $ModuleManifestPath -Force
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelper') -Force

Describe 'Jenkins Module Integration tests' {
    BeforeEach {
        # Ensure Linux Docker engine is running
        & "$env:ProgramFiles\Docker\Docker\DockerCli.exe" -SwitchLinuxEngine

        # Set up a Linux Docker container running Jenkins
        $dockerFolder = Join-Path -Path $PSScriptRoot -ChildPath 'docker'
        $jenkinsPort = 49001
        $jenkinsContainerName = 'jenkinstest'
        $jenkinsImageTag = 'plagueho/jenkins'
        $jenkinsVolume = Join-Path -Path $TestDrive -ChildPath 'jenkinstestvolume'
        $null = New-Item -Path $jenkinsVolume -ItemType Directory -ErrorAction SilentlyContinue

        Write-Verbose -Message "Creating Docker jenkins image '$jenkinsImageTag'" -Verbose
        & docker ('image','build','-t',$jenkinsImageTag,$dockerFolder)

        Write-Verbose -Message "Starting Docker jenkins container '$jenkinsContainerName' from image '$jenkinsImageTag'" -Verbose
        & docker ('run','-d','-p',"${jenkinsPort}:8080",'-v',"${jenkinsVolume}:/var/jenkins_home:z",'--name',$jenkinsContainerName,$jenkinsImageTag)

        $jenkinsUri        = "http:\\localhost:${jenkinsPort}"
        $jenkinsUsername   = 'admin'
        $jenkinsPassword   = 'admin'
        $jenkinsCredential = New-Object `
            -TypeName System.Management.Automation.PSCredential `
            -ArgumentList $jenkinsUsername, (ConvertTo-SecureString -String $jenkinsPassword -AsPlainText -Force)

            Write-Output (Invoke-WebRequest -Uri $jenkinsUri).StatusCode
        while ((Invoke-WebRequest -Uri $jenkinsUri).StatusCode -ne '200')
        {
            Write-Verbose -Message "Waiting for Docker jenkins container '$jenkinsContainerName' to complete startup" -Verbose
            Start-Sleep -Seconds 1
        }
    }

    AfterEach {
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

        $crumb = Get-JenkinsCrumb @getJenkinsCrumb_Parameters

        It 'Should return a valid crumb' {
            $crumb | Should -BeNullOrEmpty
        }
    }
}
