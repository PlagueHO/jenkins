# Change Log

## Unreleased

- Jenkins 2.107.1 returns XML 1.1, which .NET can not parse. `Get-JenkinsJob`
  changes the version in the XML declaration to be "version=1.0" before
  returning it.
- Fixed: `Get-JenkinsObject` fails if using a forward slash "/" as the
  folder seperator.
- Added `Folder` parameter to `Rename-JenkinsJob`. It can now rename jobs
  in folders.
- Clean up markdown in readme.md.
- Split functions into separate files in the `lib` folder.
- Refactored module structure to improve deployability.
- Moved documentation into docs folder.

## 1.0.0.203

- Fixed enabling of TLS 1.2 to work with older .NET Framework versions.
- Updated tests to meet Pester V4 guidelines.
- Updated license year to 2018.

## 1.0.0.196

- Added support for Jenkins servers using TLS 1.2.

## 1.0.0.188

- Fixed Get-JenkinsObject to use passed attributes when folder is specified.

## 1.0.0.182

- Fix Markdown rule violations in README.MD.
- Changed Get-JenkinsCrumb cmdlet to accept alternate format crumb.

## 1.0.0.148

- Fixed Invoke-JenkinsJobReload to use invoke-jenkinscommand

## 1.0.0.140

- Fix error in New-JenkinsFolder.
- Added Cross Site Request Forgery Support.

## 1.0.0.133

- Updated Invoke-JenkinsJobReload to use the -UseBasicParsing switch

## 1.0.0.124

- Fixed readme
- Added the Invoke-JenkinsJobReload cmdlet

## 1.0.0.115

- Added Get-JenkinsPluginsList cmdlet to retrieve a list of installed plugins

## 1.0.0.108

- Added Initialize-JenkinsUpdateCache cmdlet to create or update a local Jenkins
  Update Cache

## 1.0.0.101

- Fix bug when pulling Jenkins items from more than 1 folder deep
- Added support for folder to be specified with / or \

## 1.0.0.94

- Update AppVeyor deployment process to tag releases

## 1.0.0.88

- Added New-JenkinsFolder cmdlet

## 1.0.0.82

- Added Invoke-JenkinsJob cmdlet

## 1.0.0.70

- Added Examples to Readme.md

## 1.0.0.46

- Appveyor build improvements
- Additional unit tests added

## 1.0.0.36

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
