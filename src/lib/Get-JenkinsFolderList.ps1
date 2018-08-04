<#
    .SYNOPSIS
        Get a list of folders in a Jenkins master server.

    .DESCRIPTION
        Returns the list of folders registered on a Jenkins Master server in either the root folder or a specified
        subfolder.
        This requires the Jobs Plugin to be installed on Jenkins.

    .PARAMETER Uri
        Contains the Uri to the Jenkins Master server to execute the command on.

    .PARAMETER Credential
        Contains the credentials to use to authenticate with the Jenkins Master server.

    .PARAMETER Crumb
        Contains a Crumb to pass to the Jenkins Master Server if CSRF is enabled.

    .PARAMETER Folder
        The optional job folder to retrieve the folders from.

    .EXAMPLE
        $Folders = Get-JenkinsFolderList `
            -Uri 'https://jenkins.contoso.com' `
            -Credential (Get-Credential) `
            -Verbose
        Returns the list of job folders on https://jenkins.contoso.com using the credentials provided by the user.

    .EXAMPLE
        $Folders = Get-JenkinsFolderList `
            -Uri 'https://jenkins.contoso.com' `
            -Credential (Get-Credential) `
            -Folder 'My Builds' `
            -Verbose
        Returns the list of job folders in the 'Misc' folder on https://jenkins.contoso.com using the credentials provided
        by the user.

    .OUTPUTS
        An array of Jenkins Folder objects.
#>
function Get-JenkinsFolderList
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
        $Folder
    )

    $null = $PSBoundParameters.Add( 'Type', 'jobs')
    $null = $PSBoundParameters.Add( 'Attribute', @( 'name', 'url', 'color' ) )
    $null = $PSBoundParameters.Add( 'IncludeClass', 'com.cloudbees.hudson.plugins.folder.Folder')
    return Get-JenkinsObject `
        @PSBoundParameters
} # Get-JenkinsFolderList
