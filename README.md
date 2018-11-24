[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/IAG-NZ/Jenkins/blob/dev/LICENSE)
[![Documentation - Jenkins](https://img.shields.io/badge/Documentation-Jenkins-blue.svg)](https://github.com/IAG-NZ/Jenkins/wiki)
[![PowerShell Gallery - Jenkins](https://img.shields.io/badge/PowerShell%20Gallery-Jenkins-blue.svg)](https://www.powershellgallery.com/packages/Jenkins)
[![Minimum Supported PowerShell Version](https://img.shields.io/badge/PowerShell-4.0-blue.svg)](https://github.com/IAG-NZ/Jenkins)
[![Minimum Supported PowerShell Core Version](https://img.shields.io/badge/PowerShell_Core-6.0-blue.svg)](https://github.com/IAG-NZ/Jenkins)

# Jenkins

PowerShell module for interacting with a CloudBees Jenkins server using the
[Jenkins Rest API](https://wiki.jenkins-ci.org/display/JENKINS/Remote+access+API).
Created by IAG NZ Ltd.

## Module Build Status

| Branch | AzurePipelines CI | AppVeyor CI | Travis CI | Code Coverage |
| --- | --- | --- | --- | --- |
| dev | Comming Soon | [![av-image-dev][]][av-site-dev] | [![tv-image-dev][]][tv-site-dev] | [![cc-image-dev][]][cc-site-dev] |
| master | Comming Soon | [![av-image-master][]][av-site-master] | [![tv-image-master][]][tv-site-master] | [![cc-image-master][]][cc-site-master] |

[av-image-dev]: https://ci.appveyor.com/api/projects/status/tp0scpm2rk0vej86/branch/dev?svg=true
[av-site-dev]: https://ci.appveyor.com/project/IAG-NZ/jenkins/branch/dev
[tv-image-dev]: https://travis-ci.org/IAG-NZ/jenkins.svg?branch=dev
[tv-site-dev]: https://travis-ci.org/IAG-NZ/jenkins/branches
[cc-image-dev]: https://codecov.io/gh/IAG-NZ/jenkins/branch/dev/graph/badge.svg
[cc-site-dev]: https://codecov.io/gh/IAG-NZ/jenkins/branch/dev

[av-image-master]: https://ci.appveyor.com/api/projects/status/tp0scpm2rk0vej86/branch/master?svg=true
[av-site-master]: https://ci.appveyor.com/project/IAG-NZ/jenkins/branch/master
[tv-image-master]: https://travis-ci.org/IAG-NZ/jenkins.svg?branch=master
[tv-site-master]: https://travis-ci.org/IAG-NZ/jenkins/branches
[cc-image-master]: https://codecov.io/gh/IAG-NZ/jenkins/branch/master/graph/badge.svg
[cc-site-master]: https://codecov.io/gh/IAG-NZ/jenkins/branch/master

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

## Cmdlets

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

- [IAG NZ Web Site](http://www.iag.co.nz)
- [IAG NZ GitHub Organization](https://github.com/IAG-NZ)
- [Project site on GitHub](https://github.com/IAG-NZ/Jenkins)
