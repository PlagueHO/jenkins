# Jenkins
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

# Known Issues
 - Prevent Cross Site Request Forgery security option in Jenkins is not yet supported.
This feature will be added in a future release.
If you recieve errors regarding crumbs then your Jenkins Server has CSRF enabled and it will need to be disabled in the "Configure Global Security" section in Jenkins.

# Recommendations
 - If your Jenkins Server has security enabled then you should ensure that you are only connecting to it via HTTPS.
 - If your Jenkins Server has security enabled, the Credentials parameter that can accept either the password for the Jenkins account or the API Token.
It is strongly recommended that you use the API Token for the account as the password rather than the Jenkins account, even if you have implemented HTTPS.

# Examples

# Versions

### Unreleased
* Initial Release containing:
  - Invoke-JenkinsCommand
  - Get-JenkinsObject
  - Get-JenkinsJob
  - Get-JenkinsView

# Links
* [IAG NZ Web Site](http://www.iag.co.nz)
* [IAG NZ GitHub Organization](https://github.com/IAG-NZ)
* [Project site on GitHub](https://github.com/IAG-NZ/Jenkins)
