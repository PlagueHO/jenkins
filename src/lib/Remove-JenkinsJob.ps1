function Remove-JenkinsJob
{
    [CmdLetBinding(SupportsShouldProcess = $true,
        ConfirmImpact = "High")]
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

        [Switch]
        $Force
    )

    $null = $PSBoundParameters.Add('Type', 'Command')

    $Command = Resolve-JenkinsCommandUri -Folder $Folder -JobName $Name -Command 'doDelete'

    $null = $PSBoundParameters.Remove('Name')
    $null = $PSBoundParameters.Remove('Folder')
    $null = $PSBoundParameters.Remove('Confirm')
    $null = $PSBoundParameters.Remove('Force')
    $null = $PSBoundParameters.Add('Command', $Command)
    $null = $PSBoundParameters.Add('Method', 'post')

    if ($Force -or $PSCmdlet.ShouldProcess(`
                $URI, `
            $($LocalizedData.RemoveJobMessage -f $Name)))
    {
        $null = Invoke-JenkinsCommand @PSBoundParameters
    } # if
} # Remove-JenkinsJob
