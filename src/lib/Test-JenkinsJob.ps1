
<#
    .SYNOPSIS
        Determines if a Jenkins Job exists.

    .DESCRIPTION
        Returns true if a Job exists in the specified Jenkins Master server with a
        matching Name. It will search inside a specific folder if one is passed.

    .PARAMETER Uri
        Contains the Uri to the Jenkins Master server to execute the command on.

    .PARAMETER Credential
        Contains the credentials to use to authenticate with the Jenkins Master server.

    .PARAMETER Crumb
        Contains a Crumb to pass to the Jenkins Master Server if CSRF is enabled.

    .PARAMETER Folder
        The optional job folder to look for the job in. This requires the Jobs Plugin to be installed on Jenkins.

    .PARAMETER Name
        The name of the job to check for.

    .EXAMPLE
        Test-JenkinsJob `
            -Uri 'https://jenkins.contoso.com' `
            -Credential (Get-Credential) `
            -Name 'My App Build' `
            -Verbose
        Returns true if the 'My App Build' job is found on https://jenkins.contoso.com using the credentials provided by
        the user.

    .EXAMPLE
        Test-JenkinsJob `
            -Uri 'https://jenkins.contoso.com' `
            -Credential (Get-Credential) `
            -Folder 'Misc' `
            -Name 'My App Build' `
            -Verbose
        Returns true if the 'My App Build' job is found in the 'Misc' folder on https://jenkins.contoso.com using the
        credentials provided by the user.

    .OUTPUTS
        A boolean indicating if the job was found or not.
#>
function Test-JenkinsJob
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
    $null = $PSBoundParameters.Remove( 'Name' )
    return ((@(Get-JenkinsObject @PSBoundParameters | Where-Object -Property Name -eq $Name)).Count -gt 0)
} # Test-JenkinsJob
