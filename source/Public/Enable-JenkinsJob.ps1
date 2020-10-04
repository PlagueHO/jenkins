
function Enable-JenkinsJob
{
    [CmdLetBinding(SupportsShouldProcess = $true)]
    [OutputType([System.String])]
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
            Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name
    )

    $null = $PSBoundParameters.Add('Type', 'Command')

    $Command = Resolve-JenkinsCommandUri -Folder $Folder -JobName $Name -Command 'enable'

    $optionalParams = @{}

    if ($Credential)
    {
        $optionalParams['Credential'] = $Credential
    }

    if ($Crumb)
    {
        $optionalParams['Crumb'] = $Crumb
    }

    $displayName = $Name

    if ($Folder)
    {
        $displayName = '{0}/{1}' -f $Folder,$Name
    }

    if ($PSCmdlet.ShouldProcess($Uri, $($LocalizedData.EnableJobMessage -f $displayName)))
    {
        $null = Invoke-JenkinsCommand -Uri $Uri -Type 'Command' -Command $Command -Method post @optionalParams
    }
}
