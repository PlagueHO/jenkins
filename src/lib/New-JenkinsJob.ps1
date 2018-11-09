function New-JenkinsJob
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
        $Name,

        [parameter(
            Position = 6,
            Mandatory = $true,
            ValueFromPipeline = $True)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $XML
    )

    $null = $PSBoundParameters.Add('Type', 'Command')

    $Command = Resolve-JenkinsCommandUri -Folder $Folder -Command ("createItem?name={0}" -f [System.Uri]::EscapeDataString($Name))

    $null = $PSBoundParameters.Remove('Name')
    $null = $PSBoundParameters.Remove('Folder')
    $null = $PSBoundParameters.Remove('XML')
    $null = $PSBoundParameters.Remove('Confirm')
    $null = $PSBoundParameters.Add('Command', $Command)
    $null = $PSBoundParameters.Add('Method', 'post')
    $null = $PSBoundParameters.Add('ContentType', 'application/xml')
    $null = $PSBoundParameters.Add('Body', $XML)

    if ($PSCmdlet.ShouldProcess(`
                $URI, `
            $($LocalizedData.NewJobMessage -f $Name)))
    {
        $null = Invoke-JenkinsCommand @PSBoundParameters
    } # if
} # New-JenkinsJob
