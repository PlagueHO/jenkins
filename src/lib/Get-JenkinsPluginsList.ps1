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
    $result = Invoke-JenkinsCommand @PSBoundParameters
    $objects = ConvertFrom-Json -InputObject $result.Content

    # Returns the list of plugins, selecting just the name and version.
    return ($objects.plugins | Select-Object shortName, version)
} # Get-JenkinsPluginsList
