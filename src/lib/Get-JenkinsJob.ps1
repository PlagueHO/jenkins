<#
    .SYNOPSIS
        Get a Jenkins Job Definition.

    .DESCRIPTION
        Gets the config.xml of a Jenkins job if it exists on the Jenkins Master server.
        If the job does not exist an error will occur.
        If a folder is specified it will find the job in the specified folder.

    .PARAMETER Uri
        Contains the Uri to the Jenkins Master server to get the Job definition from.

    .PARAMETER Credential
        Contains the credentials to use to authenticate with the Jenkins Master server.

    .PARAMETER Crumb
        Contains a Crumb to pass to the Jenkins Master Server if CSRF is enabled.

    .PARAMETER Folder
        The optional job folder to look for the job in. This requires the Jobs Plugin to be
        installed on Jenkins.

    .PARAMETER Name
        The name of the job definition to get.

    .EXAMPLE
        Get-JenkinsJob `
            -Uri 'https://jenkins.contoso.com' `
            -Credential (Get-Credential) `
            -Name 'My App Build' `
            -Verbose
        Returns the XML config of the 'My App Build' job on https://jenkins.contoso.com using
        the credentials provided by the user.

    .EXAMPLE
        Get-JenkinsJob `
            -Uri 'https://jenkins.contoso.com' `
            -Credential (Get-Credential) `
            -Folder 'Misc' `
            -Name 'My App Build' `
            -Verbose
        Returns the XML config of the 'My App Build' job in the 'Misc' folder on https://jenkins.contoso.com
        using the credentials provided by the user.

    .EXAMPLE
        Get-JenkinsJob `
            -Uri 'https://jenkins.contoso.com' `
            -Credential (Get-Credential) `
            -Folder 'Misc/Build' `
            -Name 'My App Build' `
            -Verbose
        Returns the XML config of the 'My App Build' job in the 'Build' folder in the 'Misc' folder on
        https://jenkins.contoso.com using the credentials provided by the user.

    .OUTPUTS
        A string containing the Jenkins Job config XML.
#>
function Get-JenkinsJob
{
    [CmdLetBinding()]
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
    $null = $PSBoundParameters.Add('Command', $Command)
    $configXml = (Invoke-JenkinsCommand @PSBoundParameters).Content
    return $configXml -replace '^<\?xml\ version=(''|")1\.1(''|")', '<?xml version=''1.0'''
} # Get-JenkinsJob
