# Release Notes

## What is New in Jenkins 1.0.3.257

May 26, 2019

- Corrected documentation badge label in READE.MD - fixes [issue #95](https://github.com/IAG-NZ/jenkins/issues/95).
- Added basic docker support for creation of integration tests.
- Renamed `Jenkins.depends.psd1` to `requirements.psd1` to make more generic.
- Updated PowerShell module dependencies to latest versions and removed
  PSDeploy dependency because it is not used.
- Fixed error calling `Invoke-JenkinsJob` with a parameterized job - fixes [issue #100](https://github.com/IAG-NZ/jenkins/issues/100).
- Added basic integration tests that will run on Linux agents in Travis CI
  or on Windows 10 machines with Docker for Windows installed.

## What is New in Jenkins 1.0.2.240

November 14, 2018

- Added `Disable-JenkinsJob` and `Enable-JenkinsJob` functions for disabling
  and enabling Jenkins jobs, respectively.
- Split unit tests into individual files and moved to `unit` subfolder.
- Converted `Resolve-JenkinsCommandUri` to be private function.
- Updated markdown documentation.
- Added Travis CI build pipeline for multi-platform builds/testing.

## What is New in Jenkins 1.0.1.222

August 4, 2018

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
