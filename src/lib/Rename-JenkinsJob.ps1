function Rename-JenkinsJob
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
            Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,

        [parameter(
            Position = 5,
            Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $NewName,

        [parameter(
            Position = 6,
            Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Folder,

        [Switch]
        $Force
    )

    $null = $PSBoundParameters.Add('Type', 'Command')

    if ($PSBoundParameters.ContainsKey('Folder'))
    {
        $Folders = ($Folder -split '\\') -split '/'
        $Command = 'job/'

        foreach ($Folder in $Folders)
        {
            $Command += "$Folder/job/"
        } # foreach
    }
    else
    {
        $Command = "job/"
    } # if

    $Command = "$Command$Name/doRename?newName={0}" -f [System.Uri]::EscapeDataString($NewName)
    $null = $PSBoundParameters.Remove('Name')
    $null = $PSBoundParameters.Remove('NewName')
    $null = $PSBoundParameters.Remove('Confirm')
    $null = $PSBoundParameters.Remove('Force')
    $null = $PSBoundParameters.Remove('Folder')
    $null = $PSBoundParameters.Add('Command', $Command)
    $null = $PSBoundParameters.Add('Method', 'post')

    if ($Force -or $PSCmdlet.ShouldProcess( `
                $URI, `
            $($LocalizedData.RenameJobMessage -f $Name, $NewName)))
    {
        $null = Invoke-JenkinsCommand @PSBoundParameters
    } # if
} # Rename-JenkinsJob
