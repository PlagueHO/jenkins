@{

# Script module or binary module file associated with this manifest.
RootModule = 'Jenkins.psm1'

# Version number of this module.
ModuleVersion = '1.0.0.210'

# ID used to uniquely identify this module
GUID = 'd4de78f0-e143-4e58-8fb2-a543eacc1682'

# Author of this module
Author = 'Daniel Scott-Raynsford, Liam Binns-Conroy'

# Company or vendor of this module
CompanyName = 'IAG NZ Ltd.'

# Copyright statement for this module
Copyright = '(c) 2018 IAG NZ Ltd. All rights reserved.'

# Description of the functionality provided by this module
Description = 'PowerShell module for interacting with a CloudBees Jenkins server using the Jenkins Rest API created by IAG NZ Ltd.'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '4.0'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module
FunctionsToExport = @(
    'Get-JenkinsCrumb'
    'Invoke-JenkinsCommand'
    'Get-JenkinsPluginsList'
    'Get-JenkinsObject'
    'Get-JenkinsJobList'
    'Get-JenkinsJob'
    'Set-JenkinsJob'
    'Test-JenkinsJob'
    'New-JenkinsJob'
    'Rename-JenkinsJob'
    'Remove-JenkinsJob'
    'Invoke-JenkinsJob'
    'Get-JenkinsViewList'
    'Test-JenkinsView'
    'Get-JenkinsFolderList'
    'New-JenkinsFolder'
    'Test-JenkinsFolder'
    'Initialize-JenkinsUpdateCache'
    'Invoke-JenkinsJobReload'
)

# Cmdlets to export from this module
CmdletsToExport = '*'

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module
AliasesToExport = '*'

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('Jenkins','CI','ContinuousIntegration','DevOps','PSEdition_Desktop')

        # A URL to the license for this module.
            LicenseUri = 'https://github.com/IAG-NZ/jenkins/blob/dev/LICENSE'

        # A URL to the main website for this project.
            ProjectUri = 'https://github.com/IAG-NZ/jenkins'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        #   ReleaseNotes = ''

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

