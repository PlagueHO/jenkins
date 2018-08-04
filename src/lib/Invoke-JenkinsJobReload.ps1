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
