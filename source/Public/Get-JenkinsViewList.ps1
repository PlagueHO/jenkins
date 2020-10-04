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
