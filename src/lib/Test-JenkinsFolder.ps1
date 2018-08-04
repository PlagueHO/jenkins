<#
    .SYNOPSIS
        Determines if a Jenkins Folder exists.

    .DESCRIPTION
        Returns true if a Folder exists in the specified Jenkins Master server with a matching Name.
        This requires the Jobs Plugin to be installed on Jenkins.
        It will search inside a specific folder if one is passed.

    .PARAMETER Uri
        Contains the Uri to the Jenkins Master server to execute the command on.

    .PARAMETER Credential
        Contains the credentials to use to authenticate with the Jenkins Master server.

    .PARAMETER Crumb
        Contains a Crumb to pass to the Jenkins Master Server if CSRF is enabled.

    .PARAMETER Folder
        The optional folder to look for the folder in.

    .PARAMETER Name
        The name of the folder to check for.

    .EXAMPLE
        Test-JenkinsFolder `
            -Uri 'https://jenkins.contoso.com' `
            -Credential (Get-Credential) `
            -Name 'My Builds' `
            -Verbose
        Returns true if the 'My Builds' folder is found on https://jenkins.contoso.com using the
        credentials provided by the user.

    .EXAMPLE
        Test-JenkinsFolder `
            -Uri 'https://jenkins.contoso.com' `
            -Credential (Get-Credential) `
            -Folder 'Misc' `
            -Name 'My Builds' `
            -Verbose
        Returns true if the 'My Builds' folder is found in the 'Misc' folder on https://jenkins.contoso.com using the
        credentials provided by the user.

    .OUTPUTS
        A boolean indicating if the was found or not.
#>
function Test-JenkinsFolder
{
    [CmdLetBinding()]
    [OutputType([System.Boolean])]
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
        [System.String]
        $Name
    )

    $null = $PSBoundParameters.Add( 'Type', 'jobs')
    $null = $PSBoundParameters.Add( 'Attribute', @( 'name' ) )
    $null = $PSBoundParameters.Add( 'IncludeClass', 'com.cloudbees.hudson.plugins.folder.Folder')
    $null = $PSBoundParameters.Remove( 'Name' )
    return ((@(Get-JenkinsObject @PSBoundParameters | Where-Object -Property Name -eq $Name)).Count -gt 0)
} # Test-JenkinsFolder
