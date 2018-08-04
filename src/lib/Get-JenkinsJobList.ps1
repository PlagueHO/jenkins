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
