<#
    .SYNOPSIS
        Set a Jenkins Job definition.

    .DESCRIPTION
        Sets a Jenkins Job config.xml on a Jenkins Master server.
        If a folder is specified it will update the job in the specified folder.
        If the job does not exist an error will occur.
        If the job already exists the definition will be overwritten.

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
        The name of the job to set the definition on.

    .PARAMETER XML
        The config XML of the job to import.

    .EXAMPLE
        Set-JenkinsJob `
            -Uri 'https://jenkins.contoso.com' `
            -Credential (Get-Credential) `
            -Name 'My App Build' `
            -XML $MyAppBuildConfig `
            -Verbose
        Sets the job definition of the 'My App Build' job on https://jenkins.contoso.com using the credentials provided by
        the user.

    .EXAMPLE
        Set-JenkinsJob `
            -Uri 'https://jenkins.contoso.com' `
            -Credential (Get-Credential) `
            -Folder 'Misc' `
            -Name 'My App Build' `
            -XML $MyAppBuildConfig `
            -Verbose
        Sets the job definition of the 'My App Build' job in the 'Misc' folder on https://jenkins.contoso.com using the
        credentials provided by the user.

    .OUTPUTS
        None.
#>
function Set-JenkinsJob
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

    if ($PSBoundParameters.ContainsKey('Folder'))
    {
        $Folders = ($Folder -split '\\') -split '/'
        $Command = 'job/'

        foreach ($Folder in $Folders)
        {
            $Command += "$Folder/job/"
        } # foreach

        $Command += "$Name/config.xml"
    }
    else
    {
        $Command = "job/$Name/config.xml"
    } # if

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
            $($LocalizedData.SetJobDefinitionMessage -f $Name)))
    {
        $null = Invoke-JenkinsCommand @PSBoundParameters
    } # if
} # Set-JenkinsJob
