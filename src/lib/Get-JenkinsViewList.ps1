<#
    .SYNOPSIS
        Get a list of views in a Jenkins master server.

    .DESCRIPTION
        Returns the list of views registered on a Jenkins Master server. The list of views returned can be filtered by
        setting the IncludeClass or ExcludeClass parameters.

    .PARAMETER Uri
        Contains the Uri to the Jenkins Master server to execute the command on.

    .PARAMETER Credential
        Contains the credentials to use to authenticate with the Jenkins Master server.

    .PARAMETER Crumb
        Contains a Crumb to pass to the Jenkins Master Server if CSRF is enabled.

    .PARAMETER IncludeClass
        This allows the class of objects that are returned to be limited to only these types.

    .PARAMETER ExcludeClass
        This allows the class of objects that are returned to exclude these types.

    .EXAMPLE
        $Views = Get-JenkinsViewList `
            -Uri 'https://jenkins.contoso.com' `
            -Credential (Get-Credential) `
            -Verbose
        Returns the list of views on https://jenkins.contoso.com using the credentials provided by the user.

    .EXAMPLE
        $Views = Get-JenkinsViewList `
            -Uri 'https://jenkins.contoso.com' `
            -Credential (Get-Credential) `
            -ExcludeClass 'hudson.model.AllView' `
            -Verbose
        Returns the list of views except for the AllView on https://jenkins.contoso.com using the credentials provided
        by the user.

    .OUTPUTS
        An array of Jenkins View objects.
#>
function Get-JenkinsViewList
{
    [CmdLetBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [parameter(
            Position = 1,
            Mandatory = $true)]
        [System.String] $Uri,

        [parameter(
            Position = 2,
            Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $Credential,

        [parameter(
            Position = 3,
            Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Crumb,

        [parameter(
            Position = 4,
            Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $IncludeClass,

        [parameter(
            Position = 5,
            Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $ExcludeClass
    )

    $null = $PSBoundParameters.Add( 'Type', 'views')
    $null = $PSBoundParameters.Add( 'Attribute', @( 'name', 'url' ) )
    return Get-JenkinsObject `
        @PSBoundParameters
} # Get-JenkinsViewList
