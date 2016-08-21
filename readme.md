# Jenkins
[![Build status](https://ci.appveyor.com/api/projects/status/tp0scpm2rk0vej86/branch/master?svg=true)](https://ci.appveyor.com/project/IAG-NZ/jenkins/branch/master)

PowerShell module for interacting with a CloudBees Jenkins server using the [Jenkins Rest API](https://wiki.jenkins-ci.org/display/JENKINS/Remote+access+API) created by IAG NZ Ltd.

# Installation
> If Windows Management Framework 5.0 or above is installed or the PowerShell Package management module is available:

The easiest way to download and install the LabBuilder module is using PowerShell Get to download it from the PowerShell Gallery:
```powershell
Install-Module -Name Jenkins
```

> If Windows Management Framework 5.0 or above is not available and and the PowerShell Package management module is not available:

```
Unzip the file containing this Module to your c:\Program Files\WindowsPowerShell\Modules folder.
```

# Cmdlets
 - Invoke-JenkinsCommand: Execute a Jenkins command or request via the Jenkins Rest API.
 - Get-JenkinsObject: Get a list of objects in a Jenkins master server.
 - Get-JenkinsJobList: Get a list of jobs in a Jenkins master server.
 - Get-JenkinsJob: Get a Jenkins Job Definition.
 - Set-JenkinsJob: Set a Jenkins Job definition.
 - Test-JenkinsJob: Determines if a Jenkins Job exists.
 - New-JenkinsJob: Create a new Jenkins Job.
 - Remove-JenkinsJob: Remove an existing Jenkins Job.
 - Invoke-JenkinsJob: Run a parameterized or non-parameterized Jenkins Job.
 - Get-JenkinsViewList: Get a list of views in a Jenkins master server.
 - Test-JenkinsView: Determines if a Jenkins View exists.
 - Get-JenkinsFolderList: Get a list of folders in a Jenkins master server.
 - Test-JenkinsFolder: Determines if a Jenkins Folder exists.
 - Initialize-JenkinsUpdateCache: Creates or updates a local Jenkins Update cache.
 - Get-JenkinsPluginsList: Retreives a list of installed plugins

# Future features
 - Add support for servers with Cross Site Request Forgery security optional enabled.

# Known Issues
 - Prevent Cross Site Request Forgery security option in Jenkins is not yet supported.
This feature will be added in a future release.
If you recieve errors regarding crumbs then your Jenkins Server has CSRF enabled and it will need to be disabled in the "Configure Global Security" section in Jenkins.
 - Remove-JenkinsJob: An IE window pops up after deleting the job for some reason requesting authentication.

# Recommendations
 - If your Jenkins Server has security enabled then you should ensure that you are only connecting to it via HTTPS.
 - If your Jenkins Server has security enabled, the Credentials parameter that can accept either the password for the Jenkins account or the API Token.
It is strongly recommended that you use the API Token for the account as the password rather than the Jenkins account, even if you have implemented HTTPS.

# Examples
## Get a list of jobs from a Jenkins Server
```powershell
Import-Module -Name Jenkins
$Jobs = Get-JenkinsJobList `
    -Uri 'https://jenkins.contoso.com' `
    -Credential (Get-Credential)
```

## Get a list of jobs from the 'Misc' folder a Jenkins Server
```powershell
Import-Module -Name Jenkins
$Jobs = Get-JenkinsJobList `
    -Uri 'https://jenkins.contoso.com' `
    -Credential (Get-Credential) `
    -Folder 'Misc'
```

## Get a list of 'Freestyle' jobs from a Jenkins Server
```powershell
Import-Module -Name Jenkins
$Jobs = Get-JenkinsJobList `
    -Uri 'https://jenkins.contoso.com' `
    -Credential (Get-Credential) `
    -IncludeClass 'hudson.model.FreeStyleProject'
```

## Get a list of job folders from a Jenkins Server
```powershell
Import-Module -Name Jenkins
$Folders = Get-JenkinsFolderList `
    -Uri 'https://jenkins.contoso.com' `
    -Credential (Get-Credential)
```

## Get the job definition for 'My App Build' from a Jenkins Server
```powershell
Import-Module -Name Jenkins
$MyAppBuildConfig = Get-JenkinsJob `
    -Uri 'https://jenkins.contoso.com' `
    -Credential (Get-Credential) `
    -Name 'My App Build'
```

## Update the job definition for 'My App Build' on a Jenkins Server
```powershell
Import-Module -Name Jenkins
Set-JenkinsJob `
    -Uri 'https://jenkins.contoso.com' `
    -Credential (Get-Credential) `
    -Name 'My App Build' `
    -XML $MyAppBuildConfig
```

## Test if a job exists on a Jenkins Server
```powershell
Import-Module -Name Jenkins
if (Test-JenkinsJob `
        -Uri 'https://jenkins.contoso.com' `
        -Credential (Get-Credential) `
        -Name 'My App Build') {
    # ... Jenkins Job was found
}
```

## Create a new job called 'My App Build' on a Jenkins Server
```powershell
Import-Module -Name Jenkins
New-JenkinsJob `
    -Uri 'https://jenkins.contoso.com' `
    -Credential (Get-Credential) `
    -Name 'My App Build' `
    -XML $MyAppBuildConfig
```

## Remove a job called 'My App Build' from a Jenkins Server
```powershell
Import-Module -Name Jenkins
Remove-JenkinsJob `
    -Uri 'https://jenkins.contoso.com' `
    -Credential (Get-Credential) `
    -Name 'My App Build'
```

## Invoke a job called 'My App Build' on a Jenkins Server
```powershell
Import-Module -Name Jenkins
Invoke-JenkinsJob `
    -Uri 'https://jenkins.contoso.com' `
    -Credential (Get-Credential) `
    -Name 'My App Build'
```

## Invoke a parameterized job called 'My App Build' on a Jenkins Server
```powershell
Import-Module -Name Jenkins
Invoke-JenkinsJob `
    -Uri 'https://jenkins.contoso.com' `
    -Credential (Get-Credential) `
    -Name 'My App Build' `
    -Parameters @{ verbosity = 'full'; buildtitle = 'test build' }
```

## Get a list of installed plugins installed on a Jenkins Server
```powershell
$Plugins = Get-JenkinsPluginsList `
        -Uri 'https://jenkins.contoso.com' `
        -Credential (Get-Credential) `
        -Verbose
```

For further examples, please see module help for individual cmdlets.

# Versions

### 1.0.0.115
* Added Get-JenkinsPluginsList cmdlet to retreive a list of installed plugins

### 1.0.0.108
* Added Initialize-JenkinsUpdateCache cmdlet to create or update a local Jenkins Update Cache

### 1.0.0.101
* Fix bug when pulling Jenkins items from more than 1 folder deep
* Added support for folder to be specified with / or \

### 1.0.0.94
* Update AppVeyor deployment process to tag releases

### 1.0.0.88
* Added New-JenkinsFolder cmdlet

### 1.0.0.82
* Added Invoke-JenkinsJob cmdlet

### 1.0.0.70
* Added Examples to Readme.md

### 1.0.0.46
* Appveyor build improvements
* Additional unit tests added

### 1.0.0.36
* Initial Release containing:
  - Invoke-JenkinsCommand
  - Get-JenkinsObject
  - Get-JenkinsJobList
  - Get-JenkinsJob
  - Set-JenkinsJob
  - Test-JenkinsJob
  - New-JenkinsJob
  - Remove-JenkinsJob
  - Get-JenkinsViewList
  - Test-JenkinsView
  - Get-JenkinsFolderList
  - Test-JenkinsFolder

# Links
* [IAG NZ Web Site](http://www.iag.co.nz)
* [IAG NZ GitHub Organization](https://github.com/IAG-NZ)
* [Project site on GitHub](https://github.com/IAG-NZ/Jenkins)













