<#
    .SYNOPSIS
        Triggers a reload on a jenkins server

    .DESCRIPTION
        Triggers a reload on a jenkins server, e.g. if the job configs are altered on disk.

    .PARAMETER Uri
        The uri of the Jenkins server to trigger the reload on.

    .PARAMETER Credential
        Contains the credentials to use to authenticate with the Jenkins Master server.

    .PARAMETER Crumb
        Contains a Crumb to pass to the Jenkins Master Server if CSRF is enabled.

    .EXAMPLE
        Invoke-JenkinsJobReload `
            -Uri 'https://jenkins.contoso.com' `
            -Credential (Get-Credential) `
            -Verbose
        Triggers a reload of the jenkins server 'https://jenkins.contoso.com'
#>
function Invoke-JenkinsJobReload
{
    [CmdLetBinding()]
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
        $Crumb
    )

    # Invoke-JenkinsCommand with the 'reload' rest command
    Invoke-JenkinsCommand `
        -Uri $uri `
        -Credential $Credential `
        -Crumb $Crumb `
        -Type 'restcommand' `
        -Command 'reload' `
        -Method 'post' `
        -Verbose
} # function Invoke-JenkinsJobReload
