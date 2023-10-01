[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/PlagueHO/Jenkins/blob/dev/LICENSE)
[![Documentation](https://img.shields.io/badge/Docs-Jenkins-blue.svg)](https://github.com/PlagueHO/Jenkins/wiki)
[![PowerShell Gallery](https://img.shields.io/badge/PowerShell%20Gallery-Jenkins-blue.svg)](https://www.powershellgallery.com/packages/Jenkins)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/Jenkins.svg)](https://www.powershellgallery.com/packages/Jenkins)
[![Minimum Supported Windows PowerShell Version](https://img.shields.io/badge/WindowsPowerShell-5.1-blue.svg)](https://github.com/PlagueHO/Jenkins)
[![Minimum Supported PowerShell Core Version](https://img.shields.io/badge/PSCore-6.0-blue.svg)](https://github.com/PlagueHO/Jenkins)
[![Minimum Supported PowerShell Version](https://img.shields.io/badge/PS-7.0-blue.svg)](https://github.com/PlagueHO/Jenkins)

# Jenkins

PowerShell module for interacting with a CloudBees Jenkins server using the
[Jenkins Rest API](https://www.jenkins.io/doc/book/using/remote-access-api).

## Module Build Status

| Branch | Azure Pipelines                    | Automated Tests                    | Code Quality                       |
| ------ | ---------------------------------- | -----------------------------------| ---------------------------------- |
| main   | [![ap-image-main][]][ap-site-main] | [![ts-image-main][]][ts-site-main] | [![cq-image-main][]][cq-site-main] |

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Compatibility and Testing](#compatibility-and-testing)
- [Automated Integration Tests](#automated-integration-tests)
- [Cross Site Request Forgery (CSRF) Support](#cross-site-request-forgery-csrf-support)
- [Cmdlets](#cmdlets)
- [Known Issues](#known-issues)
- [Recommendations](#recommendations)
- [Examples](#examples)
- [Links](#links)

## Requirements

This module requires the following:

- Windows PowerShell 4.x and above or
- PowerShell Core 6.x on:
  - Windows
  - Linux
  - macOS

## Installation

> If Windows Management Framework 5.0 or above is installed or the PowerShell
> Package management module is available:

The easiest way to download and install the Jenkins module is using PowerShell
Get to download it from the PowerShell Gallery:

```powershell
Install-Module -Name Jenkins
```

> If Windows Management Framework 5.0 or above is not available and the
> PowerShell Package management module is not available:

Unzip the file containing this Module to your `c:\Program Files\WindowsPowerShell\Modules`
folder.

## Compatibility and Testing

This PowerShell module is automatically tested and validated to run
on the following systems:

- Windows Server 2016 (using Windows PowerShell 5.1)
- Windows Server 2019 (using Windows PowerShell 5.1)
- Ubuntu 16.04 (using PowerShell Core 6)
- Ubuntu 16.04 (using PowerShell Core 7.x)
- Ubuntu 18.04 (using PowerShell Core 7.x)
- macOS 10.14 (using PowerShell Core 6)

This module should function correctly on other systems and configurations
but is not automatically tested with them in every change.

### Automated Integration Tests

This project contains automated integration tests that use Docker to
run a Jenkins master server in a Docker Linux container.
These tests can run on Windows 10 with Docker for Windows 2.0.4 or
above installed.
The tests also run automatically in Travis CI in the Linux build.

## Cross Site Request Forgery (CSRF) Support

If a Jenkins Server has the CSRF setting enabled, then a "Crumb" will
first need to be obtained and passed to each subsequent call to Jenkins
in the Crumb parameter.
If you receive errors regarding crumbs then your Jenkins Server has CSRF
enabled and you will to ensure you are passing a valid "Crumb" obtained
by calling the ```Get-JenkinsCrumb``` cmdlet.

To work with a Jenkins Master that has CSRF enabled:

```powershell
$Crumb = Get-JenkinsCrumb `
    -Uri 'https://jenkins.contoso.com' `
    -Credential $Credential

New-JenkinsFolder `
    -Uri 'https://jenkins.contoso.com' `
    -Credential $Credential `
    -Crumb $Crumb `
    -Name 'Management' `
    -Verbose
```

## Cmdlets

The full details of the cmdlets contained in this module can also be
found in the [wiki](https://github.com/PlagueHO/Jenkins/wiki).

- `Disable-JenkinsJob`: Disables a Jenkins job.
- `Enable-JenkinsJob`: Enables a Jenkins job.
- `Get-JenkinsCrumb`: Gets a Jenkins Crumb.
- `Get-JenkinsFolderList`: Get a list of folders in a Jenkins master server.
- `Get-JenkinsJob`: Get a Jenkins Job Definition.
- `Get-JenkinsJobList`: Get a list of jobs in a Jenkins master server.
- `Get-JenkinsObject`: Get a list of objects in a Jenkins master server.
- `Get-JenkinsPluginsList`: Retrieves a list of installed plugins.
- `Get-JenkinsViewList`: Get a list of views in a Jenkins master server.
- `Initialize-JenkinsUpdateCache`: Creates or updates a local Jenkins Update cache.
- `Invoke-JenkinsCommand`: Execute a Jenkins command or request via the Jenkins Rest API.
- `Invoke-JenkinsJob`: Run a parameterized or non-parameterized Jenkins Job.
- `Invoke-JenkinsJobReload`: Reloads a job config on a given URL.
- `New-JenkinsFolder`: Create a new Jenkins Folder.
- `New-JenkinsJob`: Create a new Jenkins Job.
- `Remove-JenkinsJob`: Remove an existing Jenkins Job.
- `Rename-JenkinsJob`: Rename an existing Jenkins Job.
- `Set-JenkinsJob`: Set a Jenkins Job definition.
- `Test-JenkinsFolder`: Determines if a Jenkins Folder exists.
- `Test-JenkinsJob`: Determines if a Jenkins Job exists.
- `Test-JenkinsView`: Determines if a Jenkins View exists.

## Known Issues

- Remove-JenkinsJob: An IE window pops up after deleting the job for some
  reason requesting authentication.
- Initialize-JenkinsUpdateCache: Does not correctly set the signature
  information in the update-center.json file that is created.

## Recommendations

- If your Jenkins Server has security enabled then you should ensure that
  you are only connecting to it via HTTPS.
- If your Jenkins Server has security enabled, the Credentials parameter
  that can accept either the password for the Jenkins account or the API Token.
  It is strongly recommended that you use the API Token for the account as the
  password rather than the Jenkins account, even if you have implemented HTTPS.

## Examples

### Get a Crumb from a CSRF enabled Jenkins Server

```powershell
Import-Module -Name Jenkins
$Crumb = Get-JenkinsCrumb `
    -Uri 'https://jenkins.contoso.com' `
    -Credential $Credential
```

### Get a list of jobs from a Jenkins Server

```powershell
Import-Module -Name Jenkins
$Jobs = Get-JenkinsJobList `
    -Uri 'https://jenkins.contoso.com' `
    -Credential (Get-Credential)
```

### Get a list of jobs from the 'Misc' folder a Jenkins Server

```powershell
Import-Module -Name Jenkins
$Jobs = Get-JenkinsJobList `
    -Uri 'https://jenkins.contoso.com' `
    -Credential (Get-Credential) `
    -Folder 'Misc'
```

### Get a list of 'Freestyle' jobs from a Jenkins Server

```powershell
Import-Module -Name Jenkins
$Jobs = Get-JenkinsJobList `
    -Uri 'https://jenkins.contoso.com' `
    -Credential (Get-Credential) `
    -IncludeClass 'hudson.model.FreeStyleProject'
```

### Get a list of job folders from a Jenkins Server

```powershell
Import-Module -Name Jenkins
$Folders = Get-JenkinsFolderList `
    -Uri 'https://jenkins.contoso.com' `
    -Credential (Get-Credential)
```

### Get the job definition for 'My App Build' from a Jenkins Server

```powershell
Import-Module -Name Jenkins
$MyAppBuildConfig = Get-JenkinsJob `
    -Uri 'https://jenkins.contoso.com' `
    -Credential (Get-Credential) `
    -Name 'My App Build'
```

### Update the job definition for 'My App Build' on a Jenkins Server

```powershell
Import-Module -Name Jenkins
Set-JenkinsJob `
    -Uri 'https://jenkins.contoso.com' `
    -Credential (Get-Credential) `
    -Name 'My App Build' `
    -XML $MyAppBuildConfig
```

### Test if a job exists on a Jenkins Server

```powershell
Import-Module -Name Jenkins
if (Test-JenkinsJob `
        -Uri 'https://jenkins.contoso.com' `
        -Credential (Get-Credential) `
        -Name 'My App Build') {
    # ... Jenkins Job was found
}
```

### Create a new job called 'My App Build' on a Jenkins Server

```powershell
Import-Module -Name Jenkins
New-JenkinsJob `
    -Uri 'https://jenkins.contoso.com' `
    -Credential (Get-Credential) `
    -Name 'My App Build' `
    -XML $MyAppBuildConfig
```

### Rename an existing job called 'My App Build' to 'Other Build' on a Jenkins Server

```powershell
Import-Module -Name Jenkins
Rename-JenkinsJob `
    -Uri 'https://jenkins.contoso.com' `
    -Credential (Get-Credential) `
    -Name 'My App Build'
    -NewName 'Other Build'
```

### Remove a job called 'My App Build' from a Jenkins Server

```powershell
Import-Module -Name Jenkins
Remove-JenkinsJob `
    -Uri 'https://jenkins.contoso.com' `
    -Credential (Get-Credential) `
    -Name 'My App Build'
```

### Invoke a job called 'My App Build' on a Jenkins Server

```powershell
Import-Module -Name Jenkins
Invoke-JenkinsJob `
    -Uri 'https://jenkins.contoso.com' `
    -Credential (Get-Credential) `
    -Name 'My App Build'
```

### Invoke a parameterized job called 'My App Build' on a Jenkins Server

```powershell
Import-Module -Name Jenkins
Invoke-JenkinsJob `
    -Uri 'https://jenkins.contoso.com' `
    -Credential (Get-Credential) `
    -Name 'My App Build' `
    -Parameters @{ verbosity = 'full'; buildtitle = 'test build' }
```

### Get a list of installed plugins installed on a Jenkins Server

```powershell
$Plugins = Get-JenkinsPluginsList `
        -Uri 'https://jenkins.contoso.com' `
        -Credential (Get-Credential) `
        -Verbose
```

### Reload a job

```powershell
Invoke-JenkinsJobReload `
        -Uri 'https://jenkins.contoso.com' `
        -Credential (Get-Credential) `
        -Verbose
    Triggers a reload of the jenkins server 'https://jenkins.contoso.com'
```

For further examples, please see module help for individual cmdlets.

## Links

- [Project site on GitHub](https://github.com/PlagueHO/Jenkins)
- [Blog](https://dscottraynsford.wordpress.com/)

[ap-image-main]: https://dev.azure.com/dscottraynsford/GitHub/_apis/build/status/PlagueHO.Jenkins.main?branchName=main
[ap-site-main]: https://dev.azure.com/dscottraynsford/GitHub/_build?definitionId=46&_a=summary
[ts-image-main]: https://img.shields.io/azure-devops/tests/dscottraynsford/GitHub/4/main
[ts-site-main]: https://dev.azure.com/dscottraynsford/GitHub/_build/latest?definitionId=46&branchName=main
[cq-image-main]: https://api.codacy.com/project/badge/Grade/8c0e8f7306a54afabb2b71e0b6d16e9b
[cq-site-main]: https://www.codacy.com/manual/PlagueHO/jenkins/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=PlagueHO/jenkins&amp;utm_campaign=Badge_Grade
