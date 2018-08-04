<#
    .SYNOPSIS
        Get a list of jobs in a Jenkins master server.

    .DESCRIPTION
        Returns the list of jobs registered on a Jenkins Master server in either the root
        folder or a specified subfolder. The list of jobs returned can be filtered by
        setting the IncludeClass or ExcludeClass parameters. By default any folders will
        be filtered from this list.

    .PARAMETER Uri
        Contains the Uri to the Jenkins Master server to execute the command on.

    .PARAMETER Credential
        Contains the credentials to use to authenticate with the Jenkins Master server.

    .PARAMETER Crumb
        Contains a Crumb to pass to the Jenkins Master Server if CSRF is enabled.

    .PARAMETER Folder
        The optional job folder to retrieve the jobs from. This requires the Jobs Plugin
        to be installed on Jenkins.

    .PARAMETER IncludeClass
        This allows the class of objects that are returned to be limited to only these
        types.

    .PARAMETER ExcludeClass
        This allows the class of objects that are returned to exclude these types.

    .EXAMPLE
        $Jobs = Get-JenkinsJobList `
            -Uri 'https://jenkins.contoso.com' `
            -Credential (Get-Credential) `
            -Verbose
        Returns the list of jobs on https://jenkins.contoso.com using the credentials
        provided by the user.

    .EXAMPLE
        $Jobs = Get-JenkinsJobList `
            -Uri 'https://jenkins.contoso.com' `
            -Credential (Get-Credential) `
            -Folder 'Misc' `
            -Verbose
        Returns the list of jobs in the 'Misc' folder on https://jenkins.contoso.com
        using the credentials provided by the user.

    .EXAMPLE
        $Folders = Get-JenkinsJobList `
            -Uri 'https://jenkins.contoso.com' `
            -Credential (Get-Credential) `
            -Folder 'Misc' `
            -IncludeClass 'hudson.model.FreeStyleProject' `
            -Verbose
        Returns the list of freestyle Jenknins jobs in the 'Misc' folder on
        https://jenkins.contoso.com using the credentials provided by the user.

    .EXAMPLE
        $Folders = Get-JenkinsJobList `
            -Uri 'https://jenkins.contoso.com' `
            -Credential (Get-Credential) `
            -Folder 'Misc\Builds' `
            -Verbose
        Returns the list of jobs in the 'Builds' folder within the 'Misc' folder
        on https://jenkins.contoso.com using the credentials provided by the user.

    .OUTPUTS
        An array of Jenkins Job objects.
#>
function Get-JenkinsJobList
{
    [CmdLetBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [parameter(
            Position = 1,
            Mandatory = $true)]
        [System.String]
        $Uri,

        [parameter(
            Position = 2,
            Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential,

        [parameter(
            Position = 3,
            Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Crumb,

        [parameter(
            Position = 4,
            Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Folder,

        [parameter(
            Position = 5,
            Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String[]]
        $IncludeClass,

        [parameter(
            Position = 6,
            Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String[]]
        $ExcludeClass
    )

    $null = $PSBoundParameters.Add( 'Type', 'jobs')
    $null = $PSBoundParameters.Add( 'Attribute', @( 'name', 'buildable', 'url', 'color' ) )

    # If a class was not explicitly excluded or included then excluded then
    # set the function to excluded folders.
    if (-not $PSBoundParameters.ContainsKey('ExcludeClass') `
            -and -not $PSBoundParameters.ContainsKey('IncludeClass'))
    {
        $PSBoundParameters.Add('ExcludeClass', @('com.cloudbees.hudson.plugins.folder.Folder'))
    } # if

    return Get-JenkinsObject `
        @PSBoundParameters
} # Get-JenkinsJobList
