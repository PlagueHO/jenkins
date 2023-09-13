# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Added New-JenkinsApiToken to create a new API token - fixes [issue #8](https://github.com/PlagueHO/jenkins/issues/8)

### Fixes

- Fixed GitVersion to prevent build failures.
- Convert build pipeline to use GitTools Azure DevOps extension tasks
  instead of deprecated GitVersion extension.
- Fix build problems preventing help from being compiled and added
  to the module.
- Fix CI pipeline deployment stage to ensure correctly detects running
  in Azure DevOps organization.

## [1.2.1] - 2020-10-04

- Updated build badges.

## [1.2.0] - 2020-10-04

### Added

- Added style guidelines - fixes [issue #109](https://github.com/PlagueHO/jenkins/issues/109).
- Added contributing - fixes [issue #102](https://github.com/PlagueHO/jenkins/issues/102).

### Changed

- Converted to Continuous Delivery using Azure DevOps pipeline
  and Sampler - fixes [issue #7](https://github.com/PlagueHO/jenkins/issues/7).
- Updated build badges.

### Fixes

- Fixed bug in `Invoke-JenkinsCommand` and `Get-JenkinsCrumb` when used in
  PowerShell 7 on Linux - fixes [issue #5](https://github.com/PlagueHO/jenkins/issues/7).

## [1.0.3.257] - 2019-05-25

### Changed

- Corrected documentation badge label in READE.MD - fixes [issue #95](https://github.com/PlagueHO/jenkins/issues/95).
- Added basic docker support for creation of integration tests.
- Renamed `Jenkins.depends.psd1` to `requirements.psd1` to make more generic.
- Updated PowerShell module dependencies to latest versions and removed
  PSDeploy dependency because it is not used.
- Fixed error calling `Invoke-JenkinsJob` with a parameterized job - fixes [issue #100](https://github.com/PlagueHO/jenkins/issues/100).
- Added basic integration tests that will run on Linux agents in Travis CI
  or on Windows 10 machines with Docker for Windows installed.

## [1.0.2.240] - 2018-11-14

### Changed

- Added `Disable-JenkinsJob` and `Enable-JenkinsJob` functions for disabling
  and enabling Jenkins jobs, respectively.
- Split unit tests into individual files and moved to `unit` subfolder.
- Converted `Resolve-JenkinsCommandUri` to be private function.
- Updated markdown documentation.
- Added Travis CI build pipeline for multi-platform builds/testing.

## [1.0.1.222] - 2018-02-27

### Changed

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

## [1.0.0.203] - 2018-02-27

### Changed

- Fixed enabling of TLS 1.2 to work with older .NET Framework versions.
- Updated tests to meet Pester V4 guidelines.
- Updated license year to 2018.

## [1.0.0.196] - 2017-11-10

### Changed

- Added support for Jenkins servers using TLS 1.2.

## [1.0.0.188] - 2017-10-12

### Changed

- Fixed Get-JenkinsObject to use passed attributes when folder is specified.

## [1.0.0.182] - 2017-07-25

### Changed

- Fix Markdown rule violations in README.MD.
- Changed Get-JenkinsCrumb cmdlet to accept alternate format crumb.

## [1.0.0.148] - 2017-01-01

### Changed

- Fixed Invoke-JenkinsJobReload to use invoke-jenkinscommand

## [1.0.0.140] - 2017-01-01

### Changed

- Fix error in New-JenkinsFolder.
- Added Cross Site Request Forgery Support.

## [1.0.0.133] - 2017-01-01

### Changed

- Updated Invoke-JenkinsJobReload to use the -UseBasicParsing switch

## [1.0.0.124] - 2017-01-01

### Changed

- Fixed readme
- Added the Invoke-JenkinsJobReload cmdlet

## [1.0.0.115] - 2017-01-01

### Changed

- Added Get-JenkinsPluginsList cmdlet to retrieve a list of installed plugins

## [1.0.0.108] - 2017-01-01

### Changed

- Added Initialize-JenkinsUpdateCache cmdlet to create or update a local Jenkins
  Update Cache

## [1.0.0.101] - 2017-01-01

### Changed

- Fix bug when pulling Jenkins items from more than 1 folder deep
- Added support for folder to be specified with / or \

## [1.0.0.94] - 2017-01-01

### Changed

- Update AppVeyor deployment process to tag releases

## [1.0.0.88] - 2017-01-01

### Changed

- Added New-JenkinsFolder cmdlet

## [1.0.0.82] - 2017-01-01

### Changed

- Added Invoke-JenkinsJob cmdlet

## [1.0.0.70] - 2017-01-01

### Changed

- Added Examples to Readme.md

## [1.0.0.46] - 2017-01-01

### Changed

- Appveyor build improvements
- Additional unit tests added

## [1.0.0.36] - 2017-01-01

### Changed

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
