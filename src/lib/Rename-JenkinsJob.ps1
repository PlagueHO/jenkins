<#
    .SYNOPSIS
        Renames an existing Jenkins Job.

    .DESCRIPTION
        Renames an existing Jenkins Job in the specified Jenkins Master server.
        If the job does not exist or a job with the new name exists already an error will occur.

    .PARAMETER Uri
        Contains the Uri to the Jenkins Master server that contains the existing job.

    .PARAMETER Credential
        Contains the credentials to use to authenticate with the Jenkins Master server.

    .PARAMETER Crumb
        Contains a Crumb to pass to the Jenkins Master Server if CSRF is enabled.

    .PARAMETER Name
        The name of the job to rename.

    .PARAMETER NewName
        The new name to rename the job to.

    .PARAMETER Folder
        The optional job folder to look for the job in. This requires the Jobs Plugin to be installed on Jenkins.

    .EXAMPLE
        Rename-JenkinsJob `
            -Uri 'https://jenkins.contoso.com' `
            -Credential (Get-Credential) `
            -Name 'My App Build' `
            -NewName 'My Renamed Build' `
            -Verbose
        Rename the 'My App Build' job on https://jenkins.contoso.com to 'My Renamed Build' using the credentials provided by
        the user.

    .OUTPUTS
        None.
#>
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
