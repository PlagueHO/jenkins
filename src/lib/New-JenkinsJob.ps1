<#
    .SYNOPSIS
        Create a new Jenkins Job.

    .DESCRIPTION
        Creates a new Jenkins Job using the provided XML.
        If a folder is specified it will create the job in the specified folder.
        If the job already exists an error will occur.

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
        The name of the job to add.

    .PARAMETER XML
        The config XML of the job to import.

    .EXAMPLE
        New-JenkinsJob `
            -Uri 'https://jenkins.contoso.com' `
            -Credential (Get-Credential) `
            -Name 'My App Build' `
            -XML $MyAppBuildConfig `
            -Verbose
        Sets the job definition of the 'My App Build' job on https://jenkins.contoso.com using the credentials provided by
        the user.

    .EXAMPLE
        New-JenkinsJob `
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
    $Command = ''

    if ($PSBoundParameters.ContainsKey('Folder'))
    {
        $Folders = ($Folder -split '\\') -split '/'

        foreach ($Folder in $Folders)
        {
            $Command += "job/$Folder/"
        } # foreach
    } # if

    $Command += "createItem?name={0}" -f [System.Uri]::EscapeDataString($Name)
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
