<#
    .SYNOPSIS
        Get a list of installed plugins in a Jenkins master server.

    .DESCRIPTION
        Returns the list of installed plugins from a jenkins server, the list containing
        the name and version of each plugin.

    .PARAMETER Uri
        Contains the Uri to the Jenkins Master server to execute the command on.

    .PARAMETER Credential
        Contains the credentials to use to authenticate with the Jenkins Master server.

    .PARAMETER Crumb
        Contains a Crumb to pass to the Jenkins Master Server if CSRF is enabled.

    .PARAMETER Api
        The API to use. Can be XML, JSON or Python. Defaults to JSON.

    .PARAMETER Depth
        The depth of the tree to return (must be at least 1). Defaults to 1.

    .EXAMPLE
        $Plugins = Get-JenkinsPluginsList `
            -Uri 'https://jenkins.contoso.com' `
            -Credential (Get-Credential) `
            -Verbose
        Returns the list of installed plugins on https://jenkins.contoso.com using the credentials provided by the user.

    .OUTPUTS
        An array of Jenkins objects.
#>
function Get-JenkinsPluginsList
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
        [System.String]
        $Api = 'json',

        [parameter(
            Position = 5,
            Mandatory = $false)]
        [System.String]
        $Depth = '1'
    )

    # Add/Remove PSBoundParameters so they can be splatted
    $null = $PSBoundParameters.Add('Type', 'pluginmanager')
    $null = $PSBoundParameters.Add('Command', "depth=$Depth")
    $null = $PSBoundParameters.Remove('Depth')

    # Invoke the Command to Get the Plugin List
    $Result = Invoke-JenkinsCommand @PSBoundParameters
    $Objects = ConvertFrom-Json -InputObject $Result.Content

    # Returns the list of plugins, selecting just the name and version.
    Return ($Objects.plugins | Select-Object shortName, version)
} # Get-JenkinsPluginsList
