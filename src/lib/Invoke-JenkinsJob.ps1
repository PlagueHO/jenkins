<#
    .SYNOPSIS
        Invoke an existing Jenkins Job.

    .DESCRIPTION
        Runs an existing Jenkins Job.
        If a folder is specified it will run the job in the specified folder.
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
        The name of the job to set the definition on.

    .PARAMETER Parameters
        This is a hash table containg the job parameters for a parameterized job. The parameter names
        are case sensitive. If the job is a parameterized then this parameter must be passed even if it
        is empty.

    .EXAMPLE
        Invoke-JenkinsJob `
            -Uri 'https://jenkins.contoso.com' `
            -Credential (Get-Credential) `
            -Name 'My App Build' `
            -Verbose
        Invoke the 'My App Build' job on https://jenkins.contoso.com using the credentials provided by
        the user.

    .EXAMPLE
        Invoke-JenkinsJob `
            -Uri 'https://jenkins.contoso.com' `
            -Credential (Get-Credential) `
            -Folder 'Misc' `
            -Name 'My App Build' `
            -Verbose
        Invoke the 'My App Build' job from the 'Misc' folder on https://jenkins.contoso.com using the
        credentials provided by the user.

    .EXAMPLE
        Invoke-JenkinsJob `
            -Uri 'https://jenkins.contoso.com' `
            -Credential (Get-Credential) `
            -Name 'My App Build' `
            -Parameters @{ verbosity = 'full'; buildtitle = 'test build' } `
            -Verbose
        Invoke the 'My App Build' job on https://jenkins.contoso.com using the credentials provided by the
        user and passing the build parameters verbosity and buildtitle.

    .OUTPUTS
        None.
#>
function Invoke-JenkinsJob
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
            Mandatory = $false)]
        [Hashtable]
        $Parameters
    )

    $null = $PSBoundParameters.Add('Type', 'RestCommand')

    if ($PSBoundParameters.ContainsKey('Folder'))
    {
        $Folders = ($Folder -split '\\') -split '/'
        $Command = 'job/'

        foreach ($Folder in $Folders)
        {
            $Command += "$Folder/job/"
        } # foreach

        $Command += "$Name/build"
    }
    else
    {
        $Command = "job/$Name/build"
    } # if

    $null = $PSBoundParameters.Remove('Name')
    $null = $PSBoundParameters.Remove('Folder')
    $null = $PSBoundParameters.Remove('Confirm')
    $null = $PSBoundParameters.Remove('Parameters')
    $null = $PSBoundParameters.Add('Command', $Command)
    $null = $PSBoundParameters.Add('Method', 'post')

    if ($Parameters)
    {
        $postValues = @()

        foreach ($key in $Parameters.Keys)
        {
            $postValues += @( @{ name = $key; value = $Parameters[$key] } )
        } # foreach

        $postObject = @{ parameter = $postValues }
        $body = @{ json = (ConvertTo-JSON -InputObject $postObject) }
        $null = $PSBoundParameters.Add('Body', $body)
    }

    $null = Invoke-JenkinsCommand @PSBoundParameters
} # Invoke-JenkinsJob
