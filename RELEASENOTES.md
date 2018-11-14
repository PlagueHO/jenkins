# Release Notes

## What is New in Jenkins Unreleased

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
