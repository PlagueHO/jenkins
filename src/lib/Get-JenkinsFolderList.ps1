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
