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
