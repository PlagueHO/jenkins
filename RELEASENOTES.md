# Release Notes

## What is New in Jenkins Unreleased

August 4, 2018

- Jenkins 2.107.1 returns XML 1.1, which .NET can not parse. `Get-JenkinsJob`
  changes the version in the XML declaration to be "version='1.0'" before
  returning it.
- Fixed: `Get-JenkinsObject` fails if using a forward slash "/" as the
  folder seperator.
- Added `Folder` parameter to `Rename-JenkinsJob`. It can now rename jobs
  in folders.
- Clean up markdown in readme.md.
- Split functions into separate files in the `lib` folder.
- Refactored module structure to improve deployability.
- Moved documentation into docs folder.
