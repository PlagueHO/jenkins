@{

    # Script module or binary module file associated with this manifest.
    RootModule        = 'Jenkins.psm1'

    # Version number of this module.
    ModuleVersion     = '0.0.1'

    # ID used to uniquely identify this module
    GUID              = 'd4de78f0-e143-4e58-8fb2-a543eacc1682'

    # Author of this module
    Author            = 'Daniel Scott-Raynsford, Ashley Tok, Liam Binns-Conroy, Tobey Hung'

    # Company or vendor of this module
    CompanyName       = 'None'

    # Copyright statement for this module
    Copyright         = '(c) Daniel Scott-Raynsford, Ashley Tok, Liam Binns-Conroy, Tobey Hung. All rights reserved.'

    # Description of the functionality provided by this module
    Description       = 'PowerShell module for interacting with a Jenkins server using the Jenkins Rest API.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.0'

    # Functions to export from this module
    FunctionsToExport = @(
        'Disable-JenkinsJob'
        'Enable-JenkinsJob'
        'Get-JenkinsCrumb'
        'Get-JenkinsFolderList'
        'Get-JenkinsJob'
        'Get-JenkinsJobList'
        'Get-JenkinsObject'
        'Get-JenkinsPluginsList'
        'Get-JenkinsViewList'
        'Initialize-JenkinsUpdateCache'
        'Invoke-JenkinsCommand'
        'Invoke-JenkinsJob'
        'Invoke-JenkinsJobReload'
        'New-JenkinsFolder'
        'New-JenkinsJob'
        'Remove-JenkinsJob'
        'Rename-JenkinsJob'
        'Resolve-JenkinsCommandUri'
        'Set-JenkinsJob'
        'Test-JenkinsFolder'
        'Test-JenkinsJob'
        'Test-JenkinsView'
    )

    # Cmdlets to export from this module
    CmdletsToExport   = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module
    AliasesToExport   = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess
    PrivateData       = @{
        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags         = @('Jenkins', 'Cloudbees', 'PSEdition_Core', 'PSEdition_Desktop')

            # A URL to the license for this module.
            LicenseUri   = 'https://github.com/PlagueHO/jenkins/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri   = 'https://github.com/PlagueHO/jenkins'

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            ReleaseNotes = ''
        } # End of PSData hashtable
    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    # HelpInfoURI = ''

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''
}
