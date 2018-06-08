# Jenkins

[![Build status](https://ci.appveyor.com/api/projects/status/tp0scpm2rk0vej86/branch/master?svg=true)](https://ci.appveyor.com/project/IAG-NZ/jenkins/branch/master)

PowerShell module for interacting with a CloudBees Jenkins server using the [Jenkins Rest API](https://wiki.jenkins-ci.org/display/JENKINS/Remote+access+API). Created by IAG NZ Ltd.

## Installation

> If Windows Management Framework 5.0 or above is installed or the PowerShell Package management module is available:

The easiest way to download and install the Jenkins module is using PowerShell Get to download it from the PowerShell Gallery:

```powershell
Install-Module -Name Jenkins
```

> If Windows Management Framework 5.0 or above is not available and and the PowerShell Package management module is not available:

```text
Unzip the file containing this Module to your c:\Program Files\WindowsPowerShell\Modules folder.
```

## Cmdlets

- Get-JenkinsCrumb: Gets a Jenkins Crumb.
- Invoke-JenkinsCommand: Execute a Jenkins command or request via the Jenkins Rest API.
- Get-JenkinsObject: Get a list of objects in a Jenkins master server.
- Get-JenkinsJobList: Get a list of jobs in a Jenkins master server.
- Get-JenkinsJob: Get a Jenkins Job Definition.
- Set-JenkinsJob: Set a Jenkins Job definition.
- Test-JenkinsJob: Determines if a Jenkins Job exists.
- New-JenkinsJob: Create a new Jenkins Job.
- Rename-JenkinsJob: Rename an existing Jenkins Job.
- Remove-JenkinsJob: Remove an existing Jenkins Job.
- Invoke-JenkinsJob: Run a parameterized or non-parameterized Jenkins Job.
- Get-JenkinsViewList: Get a list of views in a Jenkins master server.
- Test-JenkinsView: Determines if a Jenkins View exists.
- Get-JenkinsFolderList: Get a list of folders in a Jenkins master server.
- Test-JenkinsFolder: Determines if a Jenkins Folder exists.
- Initialize-JenkinsUpdateCache: Creates or updates a local Jenkins Update cache.
- Get-JenkinsPluginsList: Retrieves a list of installed plugins.
- Invoke-JenkinsJobReload: Reloads a job config on a given URL.

## Cross Site Request Forgery (CSRF) Support

If a Jenkins Server has the CSRF setting enabled, then a "Crumb" will first need to be obtained and passed to each subsequent call to Jenkins in the Crumb parameter.
If you receive errors regarding crumbs then your Jenkins Server has CSRF enabled and you will to ensure you are passing a valid "Crumb" obtained by calling the ```Get-JenkinsCrumb``` cmdlet.

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

- Remove-JenkinsJob: An IE window pops up after deleting the job for some reason requesting authentication.
- Initialize-JenkinsUpdateCache: Does not correctly set the signature information in the update-center.json file that is created.

## Recommendations

- If your Jenkins Server has security enabled then you should ensure that you are only connecting to it via HTTPS.
- If your Jenkins Server has security enabled, the Credentials parameter that can accept either the password for the Jenkins account or the API Token.
  It is strongly recommended that you use the API Token for the account as the password rather than the Jenkins account, even if you have implemented HTTPS.

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

## Versions

### 1.0.0.203

- Fixed enabling of TLS 1.2 to work with older .NET Framework versions.
- Updated tests to meet Pester V4 guidelines.
- Updated license year to 2018.

### 1.0.0.196

- Added support for Jenkins servers using TLS 1.2.

### 1.0.0.188

- Fixed Get-JenkinsObject to use passed attributes when folder is specified.

### 1.0.0.182

- Fix Markdown rule violations in README.MD.
- Changed Get-JenkinsCrumb cmdlet to accept alternate format crumb.

### 1.0.0.148

- Fixed Invoke-JenkinsJobReload to use invoke-jenkinscommand

### 1.0.0.140

- Fix error in New-JenkinsFolder.
- Added Cross Site Request Forgery Support.

### 1.0.0.133

- Updated Invoke-JenkinsJobReload to use the -UseBasicParsing switch

### 1.0.0.124

- Fixed readme
- Added the Invoke-JenkinsJobReload cmdlet

### 1.0.0.115

- Added Get-JenkinsPluginsList cmdlet to retrieve a list of installed plugins

### 1.0.0.108

- Added Initialize-JenkinsUpdateCache cmdlet to create or update a local Jenkins Update Cache

### 1.0.0.101

- Fix bug when pulling Jenkins items from more than 1 folder deep
- Added support for folder to be specified with / or \

### 1.0.0.94

- Update AppVeyor deployment process to tag releases

### 1.0.0.88

- Added New-JenkinsFolder cmdlet

### 1.0.0.82

- Added Invoke-JenkinsJob cmdlet

### 1.0.0.70

- Added Examples to Readme.md

### 1.0.0.46

- Appveyor build improvements
- Additional unit tests added

### 1.0.0.36

- Initial Release containing:
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

## Links

- [IAG NZ Web Site](http://www.iag.co.nz)
- [IAG NZ GitHub Organization](https://github.com/IAG-NZ)
- [Project site on GitHub](https://github.com/IAG-NZ/Jenkins)





