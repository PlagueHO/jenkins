<#
    .SYNOPSIS
        Remove an existing Jenkins Job.

    .DESCRIPTION
        Deletes an existing Jenkins Job in the specified Jenkins Master server.
        If a folder is specified it will remove the job in the specified folder.
        If the job does not exist an error will occur.

    .PARAMETER Uri
        Contains the Uri to the Jenkins Master server to set the Job definition on.

    .PARAMETER Credential
        Contains the credentials to use to authenticate with the Jenkins Master server.

    .PARAMETER Crumb
        Contains a Crumb to pass to the Jenkins Master Server if CSRF is enabled.

    .PARAMETER Folder
        The optional job folder the job is in. This requires the Jobs Plugin to be installed on Jenkins.
        If the folder does not exist then an error will occur.

    .PARAMETER Name
        The name of the job to remove.

    .EXAMPLE
        Remove-JenkinsJob `
            -Uri 'https://jenkins.contoso.com' `
            -Credential (Get-Credential) `
            -Name 'My App Build' `
            -Verbose
        Remove the 'My App Build' job on https://jenkins.contoso.com using the credentials provided by
        the user.

    .EXAMPLE
        Remove-JenkinsJob `
            -Uri 'https://jenkins.contoso.com' `
            -Credential (Get-Credential) `
            -Folder 'Misc' `
            -Name 'My App Build' `
            -Verbose
        Remove the 'My App Build' job from the 'Misc' folder on https://jenkins.contoso.com using the
        credentials provided by the user.

    .OUTPUTS
        None.
#>
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

    if ($PSBoundParameters.ContainsKey('Folder'))
    {
        $Folders = ($Folder -split '\\') -split '/'
        $Command = 'job/'

        foreach ($Folder in $Folders)
        {
            $Command += "$Folder/job/"
        } # foreach

        $Command += "$Name/doDelete"
    }
    else
    {
        $Command = "job/$Name/doDelete"
    } # if

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
