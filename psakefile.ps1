# PSake makes variables declared here available in other scriptblocks
# Init some things
Properties {
    # Modulue Name
    $ModuleName = 'Jenkins'

    # Prepare the folder variables
    $ProjectRoot = $ENV:BHProjectPath
    if (-not $ProjectRoot)
    {
        $ProjectRoot = $PSScriptRoot
    }

    # Determine the folder names for staging the module
    $StagingFolder = Join-Path -Path $ProjectRoot -ChildPath 'staging'
    $ModuleFolder = Join-Path -Path $StagingFolder -ChildPath $ModuleName

    $Timestamp = Get-Date -uformat "%Y%m%d-%H%M%S"
    $PSVersion = $PSVersionTable.PSVersion.Major
    $separator = '----------------------------------------------------------------------'
}

Task Default -Depends Build

Task Init {
    Set-Location -Path $ProjectRoot

    # Install any dependencies required for the Init stage
    Invoke-PSDepend `
        -Path $PSScriptRoot `
        -Force `
        -Import `
        -Install `
        -Tags 'Init'

    Set-BuildEnvironment -Force

    $separator
    'Build System Details:'
    Get-Item -Path ENV:BH*
    "`n"

    $separator
    'Other Environment Variables:'
    Get-ChildItem -Path ENV:
    "`n"

    $separator
    'PowerShell Details:'
    $PSVersionTable
    "`n"
}

Task PrepareTest -Depends Init {
    # Install any dependencies required for testing
    Invoke-PSDepend `
        -Path $PSScriptRoot `
        -Force `
        -Import `
        -Install `
        -Tags 'Test',('Test_{0}' -f $PSVersionTable.PSEdition)
}

Task Test -Depends UnitTest, IntegrationTest

Task UnitTest -Depends Init, PrepareTest {
    $separator

    # Execute tests
    $testScriptsPath = Join-Path -Path $ProjectRoot -ChildPath 'test\Unit'
    $testResultsFile = Join-Path -Path $testScriptsPath -ChildPath 'TestResults.unit.xml'
    $codeCoverageFile = Join-Path -Path $testScriptsPath -ChildPath 'CodeCoverage.xml'
    $codeCoverageSource = Get-ChildItem -Path (Join-Path -Path $ProjectRoot -ChildPath 'src\lib\*.ps1') -Recurse
    $testResults = Invoke-Pester `
        -Script $testScriptsPath `
        -OutputFormat NUnitXml `
        -OutputFile $testResultsFile `
        -PassThru `
        -ExcludeTag Incomplete `
        -CodeCoverage $codeCoverageSource `
        -CodeCoverageOutputFile $codeCoverageFile `
        -CodeCoverageOutputFileFormat JaCoCo

    # Prepare and uploade code coverage
    if ($testResults.CodeCoverage)
    {
        # Only bother generating code coverage in AppVeyor
        if ($ENV:BHBuildSystem -eq 'AppVeyor')
        {
            'Preparing CodeCoverage'
            Import-Module `
                -Name (Join-Path -Path $ProjectRoot -ChildPath '.codecovio\CodeCovio.psm1')

            $jsonPath = Export-CodeCovIoJson `
                -CodeCoverage $testResults.CodeCoverage `
                -RepoRoot $ProjectRoot

            'Uploading CodeCoverage to CodeCov.io'
            try
            {
                Invoke-UploadCoveCoveIoReport -Path $jsonPath
            }
            catch
            {
                # CodeCov currently reports an error when uploading
                # This is not fatal and can be ignored
                Write-Warning -Message $_
            }
        }
    }
    else
    {
        Write-Warning -Message 'Could not create CodeCov.io report because pester results object did not contain a CodeCoverage object'
    }

    # Upload tests
    if ($ENV:BHBuildSystem -eq 'AppVeyor')
    {
        'Publishing test results to AppVeyor'
        (New-Object 'System.Net.WebClient').UploadFile(
            "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)",
            (Resolve-Path $testResultsFile))

        'Publishing test results to AppVeyor as Artifact'
        Push-AppveyorArtifact $testResultsFile

        if ($testResults.FailedCount -gt 0)
        {
            throw "$($testResults.FailedCount) unit tests failed."
        }
    }
    else
    {
        if ($testResults.FailedCount -gt 0)
        {
            Write-Error -Exception "$($testResults.FailedCount) unit tests failed."
        }
    }

    "`n"
}

Task IntegrationTest -Depends Init, PrepareTest {
    $separator

    # Execute tests
    $testScriptsPath = Join-Path -Path $ProjectRoot -ChildPath 'test\Integration'
    if (-not (Test-Path -Path $testScriptsPath))
    {
        'Skipping integration tests because they do not exist.'
        return
    }

    $testResultsFile = Join-Path -Path $testScriptsPath -ChildPath 'TestResults.integration.xml'
    $testResults = Invoke-Pester `
        -Script $testScriptsPath `
        -OutputFormat NUnitXml `
        -OutputFile $testResultsFile `
        -PassThru `
        -ExcludeTag Incomplete

    # Upload tests
    if ($ENV:BHBuildSystem -eq 'AppVeyor')
    {
        'Publishing test results to AppVeyor'
        (New-Object 'System.Net.WebClient').UploadFile(
            "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)",
            (Resolve-Path $testResultsFile))

        'Publishing test results to AppVeyor as Artifact'
        Push-AppveyorArtifact $testResultsFile

        if ($testResults.FailedCount -gt 0)
        {
            throw "$($testResults.FailedCount) integration tests failed."
        }
    }
    else
    {
        if ($testResults.FailedCount -gt 0)
        {
            Write-Error -Exception "$($testResults.FailedCount) integration tests failed."
        }
    }

    "`n"
}

Task Build -Depends Test {
    $separator

    # Install any dependencies required for the Build stage
    Invoke-PSDepend `
        -Path $PSScriptRoot `
        -Force `
        -Import `
        -Install `
        -Tags 'Build'

    # Generate the next version by adding the build system build number to the manifest version
    $manifestPath = Join-Path -Path $ProjectRoot -ChildPath "src/$ModuleName.psd1"
    $newVersion = Get-NewVersionNumber `
        -ManifestPath $manifestPath `
        -Build $ENV:BHBuildNumber

    if ($ENV:BHBuildSystem -eq 'AppVeyor')
    {
        # Update AppVeyor build version number
        Update-AppveyorBuild -Version $newVersion
    }

    # Determine the folder names for staging the module
    $VersionFolder = Join-Path -Path $ModuleFolder -ChildPath $newVersion

    # Stage the module
    $null = New-Item -Path $StagingFolder -Type directory -ErrorAction SilentlyContinue
    $null = New-Item -Path $ModuleFolder -Type directory -ErrorAction SilentlyContinue
    Remove-Item -Path $VersionFolder -Recurse -Force -ErrorAction SilentlyContinue
    $null = New-Item -Path $VersionFolder -Type directory

    # Populate Version Folder
    $null = Copy-Item -Path (Join-Path -Path $ProjectRoot -ChildPath "src/$ModuleName.psd1") -Destination $VersionFolder
    $null = Copy-Item -Path (Join-Path -Path $ProjectRoot -ChildPath "src/$ModuleName.psm1") -Destination $VersionFolder
    $null = Copy-Item -Path (Join-Path -Path $ProjectRoot -ChildPath 'src/en-us') -Destination $VersionFolder -Recurse
    $null = Copy-Item -Path (Join-Path -Path $ProjectRoot -ChildPath 'LICENSE') -Destination $VersionFolder
    $null = Copy-Item -Path (Join-Path -Path $ProjectRoot -ChildPath 'README.md') -Destination $VersionFolder
    $null = Copy-Item -Path (Join-Path -Path $ProjectRoot -ChildPath 'CHANGELOG.md') -Destination $VersionFolder
    $null = Copy-Item -Path (Join-Path -Path $ProjectRoot -ChildPath 'RELEASENOTES.md') -Destination $VersionFolder

    # Load the Libs files into the PSM1
    $libFiles = Get-ChildItem `
        -Path (Join-Path -Path $ProjectRoot -ChildPath 'src/lib') `
        -Include '*.ps1' `
        -Recurse

    # Assemble all the libs content into a single string
    $libFilesStringBuilder = [System.Text.StringBuilder]::new()
    foreach ($libFile in $libFiles)
    {
        $libContent = Get-Content -Path $libFile -Raw
        $null = $libFilesStringBuilder.AppendLine($libContent)
    }

    <#
        Load the PSM1 file into an array of lines and step through each line
        adding it to a string builder if the line is not part of the ImportFunctions
        Region. Then add the content of the $libFilesStringBuilder string builder
        immediately following the end of the region.
    #>
    $modulePath = Join-Path -Path $versionFolder -ChildPath "$ModuleName.psm1"
    $moduleContent = Get-Content -Path $modulePath
    $moduleStringBuilder = [System.Text.StringBuilder]::new()
    $importFunctionsRegionFound = $false
    foreach ($moduleLine in $moduleContent)
    {
        if ($importFunctionsRegionFound)
        {
            if ($moduleLine -eq '#endregion')
            {
                $null = $moduleStringBuilder.AppendLine('#region Functions')
                $null = $moduleStringBuilder.AppendLine($libFilesStringBuilder)
                $null = $moduleStringBuilder.AppendLine('#endregion')
                $importFunctionsRegionFound = $false
            }
        }
        else
        {
            if ($moduleLine -eq '#region ImportFunctions')
            {
                $importFunctionsRegionFound = $true
            }
            else
            {
                $null = $moduleStringBuilder.AppendLine($moduleLine)
            }
        }
    }
    Set-Content -Path $modulePath -Value $moduleStringBuilder -Force

    # Prepare external help
    'Building external help file'
    New-ExternalHelp `
        -Path (Join-Path -Path $ProjectRoot -ChildPath 'docs\') `
        -OutputPath $VersionFolder `
        -Force

    # Set the new version number in the staged Module Manifest
    'Updating module manifest'
    $stagedManifestPath = Join-Path -Path $VersionFolder -ChildPath "$ModuleName.psd1"
    $stagedManifestContent = Get-Content -Path $stagedManifestPath -Raw
    $stagedManifestContent = $stagedManifestContent -replace '(?<=ModuleVersion\s+=\s+'')(?<ModuleVersion>.*)(?='')', $newVersion
    $stagedManifestContent = $stagedManifestContent -replace "## What is New in $ModuleName Unreleased", "## What is New in $ModuleName $newVersion"
    Set-Content -Path $stagedManifestPath -Value $stagedManifestContent -NoNewLine -Force

    # Set the new version number in the staged CHANGELOG.md
    'Updating CHANGELOG.MD'
    $stagedChangeLogPath = Join-Path -Path $VersionFolder -ChildPath 'CHANGELOG.md'
    $stagedChangeLogContent = Get-Content -Path $stagedChangeLogPath -Raw
    $stagedChangeLogContent = $stagedChangeLogContent -replace '# Unreleased', "# $newVersion"
    Set-Content -Path $stagedChangeLogPath -Value $stagedChangeLogContent -NoNewLine -Force

    # Set the new version number in the staged RELEASENOTES.md
    'Updating RELEASENOTES.MD'
    $stagedReleaseNotesPath = Join-Path -Path $VersionFolder -ChildPath 'RELEASENOTES.md'
    $stagedReleaseNotesContent = Get-Content -Path $stagedReleaseNotesPath -Raw
    $stagedReleaseNotesContent = $stagedReleaseNotesContent -replace "## What is New in $ModuleName Unreleased", "## What is New in $ModuleName $newVersion"
    Set-Content -Path $stagedReleaseNotesPath -Value $stagedReleaseNotesContent -NoNewLine -Force

    "`n"
}

Task Deploy -Depends Build {
    $separator

    # Generate the next version by adding the build system build number to the manifest version
    $manifestPath = Join-Path -Path $ProjectRoot -ChildPath "src/$ModuleName.psd1"
    $newVersion = Get-NewVersionNumber `
        -ManifestPath $manifestPath `
        -Build $ENV:BHBuildNumber

    # Determine the folder names for staging the module
    $VersionFolder = Join-Path -Path $ModuleFolder -ChildPath $newVersion

    # Copy the module to the PSModulePath
    $PSModulePath = ($ENV:PSModulePath -split ';')[0]

    "Copying Module to $PSModulePath"
    Copy-Item `
        -Path $ModuleFolder `
        -Destination $PSModulePath `
        -Recurse `
        -Force

    # Create zip artifact
    $zipFilePath = Join-Path `
        -Path $StagingFolder `
        -ChildPath "${ENV:BHProjectName}_${ENV:BHBuildNumber}.zip"
    $null = Add-Type -assemblyname System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::CreateFromDirectory($ModuleFolder, $zipFilePath)

    if ($ENV:BHBuildSystem -eq 'AppVeyor')
    {
        # If AppVeyor, publish the deploy artefacts for debug purposes
        "Pushing package $zipFilePath as Appveyor artifact"
        Push-AppveyorArtifact $zipFilePath
        Remove-Item -Path $zipFilePath -Force

        <#
            If this is a build of the Master branch and not a PR push
            then publish the Module to the PowerShell Gallery.
        #>
        if ($ENV:BHBranchName -eq 'master')
        {
            $commitMessage = $ENV:BHCommitMessage.TrimEnd()
            "Commit to Master branch detected with commit message: '$commitMessage'"

            if ($commitMessage -match ' Deploy!$')
            {
                # This was a deploy commit so no need to do anything
                'Skipping deployment because this was a commit triggered by a deployment'
            }
            elseif ($ENV:APPVEYOR_PULL_REQUEST_NUMBER)
            {
                # This is a PR so do nothing
                'Skipping deployment because this is a Pull Request'
            }
            else
            {
                # This is a commit to Master
                'Publishing Module to PowerShell Gallery'
                Get-PackageProvider `
                    -Name NuGet `
                    -ForceBootstrap
                Publish-Module `
                    -Name $ModuleName `
                    -RequiredVersion $newVersion `
                    -NuGetApiKey $ENV:PowerShellGalleryApiKey `
                    -Confirm:$false

                # This is not a PR so deploy
                'Beginning update to master branch with deployed information'

                # Pull the master branch, update the readme.md and manifest
                Set-Location -Path $ProjectRoot
                Invoke-Git -GitParameters @('config', '--global', 'credential.helper', 'store')

                Add-Content `
                    -Path "$env:USERPROFILE\.git-credentials" `
                    -Value "https://$($env:GitHubPushFromPlagueHO):x-oauth-basic@github.com`n"

                Invoke-Git -GitParameters @('config', '--global', 'user.email', 'plagueho@gmail.com')
                Invoke-Git -GitParameters @('config', '--global', 'user.name', 'Daniel Scott-Raynsford')
                Invoke-Git -GitParameters @('checkout', '-f', 'master')

                # Replace the manifest with the one that was published
                'Updating files changed during deployment.='
                Copy-Item `
                    -Path (Join-Path -Path $VersionFolder -ChildPath "$ModuleName.psd1") `
                    -Destination (Join-Path -Path $ProjectRoot -ChildPath 'src') `
                    -Force
                Copy-Item `
                    -Path (Join-Path -Path $VersionFolder -ChildPath 'CHANGELOG.MD') `
                    -Destination $ProjectRoot `
                    -Force
                Copy-Item `
                    -Path (Join-Path -Path $VersionFolder -ChildPath 'RELEASENOTES.MD') `
                    -Destination $ProjectRoot `
                    -Force

                # Update the master branch
                'Pushing deployment changes to Master'
                Invoke-Git -GitParameters @('add', '.')
                Invoke-Git -GitParameters @('commit', '-m', "$NewVersion Deploy!")
                Invoke-Git -GitParameters @('status')
                Invoke-Git -GitParameters @('push', 'origin', 'master')

                # Create the version tag and push it
                "Pushing $newVersion tag to Master"
                Invoke-Git -GitParameters @('tag', '-a', $newVersion, '-m', $newVersion)
                Invoke-Git -GitParameters @('push', 'origin', $newVersion)

                # Merge the changes to the Dev branch as well
                'Pushing deployment changes to Dev'
                Invoke-Git -GitParameters @('checkout', '-f', 'dev')
                Invoke-Git -GitParameters @('merge', 'master')
                Invoke-Git -GitParameters @('push', 'origin', 'dev')
            }
        }
    }
}

function Get-NewVersionNumber
{
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ManifestPath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Build
    )

    # Get version number from the existing manifest
    $manifestContent = Get-Content -Path $ManifestPath -Raw
    $regex = '(?<=ModuleVersion\s+=\s+'')(?<ModuleVersion>.*)(?='')'
    $matches = @([regex]::matches($manifestContent, $regex, 'IgnoreCase'))
    $version = $null
    if ($matches)
    {
        $version = $matches[0].Value
    }

    # Determine the new version number
    $versionArray = $version -split '\.'
    $newVersion = ''
    Foreach ($ver in (0..2))
    {
        $sem = $versionArray[$ver]
        if ([String]::IsNullOrEmpty($sem))
        {
            $sem = '0'
        }
        $newVersion += "$sem."
    }
    $newVersion += $Build
    return $newVersion
}

function Invoke-Git
{
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String[]]
        $GitParameters
    )

    try
    {
        "Executing 'git $($GitParameters -join ' ')'"
        exec { & git $GitParameters }
    }
    catch
    {
        Write-Warning -Message $_
    }
}
