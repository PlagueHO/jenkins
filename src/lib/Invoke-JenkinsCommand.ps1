<#
    .SYNOPSIS
        Execute a Jenkins command or request via the Jenkins Rest API.

    .DESCRIPTION
        This cmdlet is used to issue a command or request to a Jenkins Master via the Rest API.

    .PARAMETER Uri
        Contains the Uri to the Jenkins Master server to execute the command on.

    .PARAMETER Credential
        Contains the credentials to use to authenticate with the Jenkins Master server.

    .PARAMETER Crumb
        Contains a Crumb to pass to the Jenkins Master Server if CSRF is enabled.

    .PARAMETER Type
        The type of endpoint to invoke the command on. Can be set to: Rest,Command.

    .PARAMETER Api
        The API to use. Only used if type is 'rest'. Can be XML, JSON or Python. Defaults
        to JSON.

    .PARAMETER Command
        This is the command and any other URI parameters that need to be passed to the API.
        Should always be set if the Type is set to Command.

    .PARAMETER Method
        The method of the web request to use. Defaults to default for the type of command.

    .PARAMETER Headers
        Allows additional header values to be specified.

    .EXAMPLE
        Invoke-JenkinsCommand `
            -Uri 'https://jenkins.contoso.com' `
            -Credential (Get-Credential) `
            -Crumb $Crumb `
            -Api 'json' `
            -Command 'job/MuleTest/build'
        Triggers the MuleTest job on https://jenkins.contoso.com to run using the credentials
        provided by the user.

    .EXAMPLE
        Invoke-JenkinsCommand `
            -Uri 'https://jenkins.contoso.com' `
            -Credential (Get-Credential) `
            -Api 'json'
        Returns the list of jobs in the root of the https://jenkins.contoso.com using
        credentials provided by the user.

    .EXAMPLE
        Invoke-JenkinsCommand `
            -Uri 'https://jenkins.contoso.com'
        Returns the list of jobs in the root of the https://jenkins.contoso.com using no
        credentials for authorization.

    .EXAMPLE
        Invoke-JenkinsCommand `
            -Uri 'https://jenkins.contoso.com' `
            -Credential (Get-Credential) `
            -Type 'Command' `
            -Command 'job/Build My App/config.xml'
        Returns the job config XML for the 'Build My App' job in https://jenkins.contoso.com
        using credentials provided by the user.

    .OUTPUTS
        The result of the Api as a string.
#>
function Invoke-JenkinsCommand
{
    [CmdLetBinding()]
    [OutputType([System.String])]
    param
    (
        [parameter(
            Position = 1,
            Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
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
        [ValidateSet('rest', 'command', 'restcommand', 'pluginmanager')]
        [System.String]
        $Type = 'rest',

        [parameter(
            Position = 5,
            Mandatory = $false)]
        [System.String]
        $Api = 'json',

        [parameter(
            Position = 6,
            Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Command,

        [parameter(
            Position = 7,
            Mandatory = $false)]
        [ValidateSet('default', 'delete', 'get', 'head', 'merge', 'options', 'patch', 'post', 'put', 'trace')]
        [System.String]
        $Method,

        [parameter(
            Position = 8,
            Mandatory = $false)]
        [System.Collections.Hashtable]
        $Headers = @{},

        [parameter(
            Position = 9,
            Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ContentType,

        [parameter(
            Position = 10,
            Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        $Body
    )

    if ($PSBoundParameters.ContainsKey('Credential') -and $Credential -ne [System.Management.Automation.PSCredential]::Empty)
    {
        # Jenkins Credentials were passed so create the Authorization Header
        $Username = $Credential.Username

        # Decrypt the secure string password
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Credential.Password)
        $Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

        $Bytes = [System.Text.Encoding]::UTF8.GetBytes($Username + ':' + $Password)
        $Base64Bytes = [System.Convert]::ToBase64String($Bytes)

        $Headers += @{ "Authorization" = "Basic $Base64Bytes" }
    } # if

    if ($PSBoundParameters.ContainsKey('Crumb'))
    {
        Write-Verbose -Message $($LocalizedData.UsingCrumbMessage -f
            $Crumb)

        # Support both Jenkins and Cloudbees Jenkins Enterprise
        $Headers += @{ "Jenkins-Crumb" = $Crumb }
        $Headers += @{ ".crumb" = $Crumb }
    } # if

    $null = $PSBoundParameters.remove('Uri')
    $null = $PSBoundParameters.remove('Credential')
    $null = $PSBoundParameters.remove('Crumb')
    $null = $PSBoundParameters.remove('Type')
    $null = $PSBoundParameters.remove('Headers')

    switch ($Type)
    {
        'rest'
        {
            $FullUri = "$Uri/api/$Api"
            if ($PSBoundParameters.ContainsKey('Command'))
            {
                $FullUri = $FullUri + '/' + $Command
            } # if

            $null = $PSBoundParameters.remove('Command')
            $null = $PSBoundParameters.remove('Api')

            try
            {
                Write-Verbose -Message $($LocalizedData.InvokingRestApiCommandMessage -f
                    $FullUri)

                Set-JenkinsTLSSupport

                $Result = Invoke-RestMethod `
                    -Uri $FullUri `
                    -Headers $Headers `
                    @PSBoundParameters `
                    -ErrorAction Stop
            }
            catch
            {
                # Todo: Improve error handling.
                Throw $_
            } # catch
        } # 'rest'

        'restcommand'
        {
            $FullUri = "$Uri/$Command"

            $null = $PSBoundParameters.remove('Command')
            $null = $PSBoundParameters.remove('Api')

            try
            {
                Write-Verbose -Message $($LocalizedData.InvokingRestApiCommandMessage -f
                    $FullUri)

                Set-JenkinsTLSSupport

                $Result = Invoke-RestMethod `
                    -Uri $FullUri `
                    -Headers $Headers `
                    @PSBoundParameters `
                    -ErrorAction Stop
            }
            catch
            {
                # Todo: Improve error handling.
                Throw $_
            } # catch
        } # 'restcommand'

        'command'
        {
            $FullUri = $Uri
            if ($PSBoundParameters.ContainsKey('Command'))
            {
                $FullUri = $FullUri + '/' + $Command
            } # if

            $null = $PSBoundParameters.remove('Command')
            $null = $PSBoundParameters.remove('Api')

            Write-Verbose -Message $($LocalizedData.InvokingCommandMessage -f
                $FullUri)

            Set-JenkinsTLSSupport

            $Result = Invoke-WebRequest `
                -Uri $FullUri `
                -Headers $Headers `
                -MaximumRedirection 0 `
                @PSBoundParameters `
                -ErrorAction SilentlyContinue `
                -ErrorVariable RequestErrors

            if ($RequestErrors.Count -eq 1 -and $Result.StatusCode -eq 302 `
                    -and $RequestErrors[0].FullyQualifiedErrorId -like "MaximumRedirectExceeded,*")
            {
                Write-Verbose -Message $($LocalizedData.SuppressingRedirectMessage -f $Result.Headers.Location)
            }
            elseif ($RequestErrors.Count -ge 1)
            {
                # Todo: Improve error handling.
                throw $RequestErrors[0].Exception
            }
        } # 'command'

        'pluginmanager'
        {
            $FullUri = $Uri
            if ($PSBoundParameters.ContainsKey('Command'))
            {
                $FullUri = "$FullUri/pluginManager/api/$api/?$Command"
            } # if (condition) {

            $null = $PSBoundParameters.remove('Command')
            $null = $PSBoundParameters.remove('Api')

            try
            {
                Write-Verbose -Message $($LocalizedData.InvokingCommandMessage -f
                    $FullUri)

                Set-JenkinsTLSSupport

                $Result = Invoke-WebRequest `
                    -Uri $FullUri `
                    -Headers $Headers `
                    @PSBoundParameters `
                    -ErrorAction Stop
            }
            catch
            {
                # Todo: Improve error handling.
                Throw $_
            } # catch
        } # 'pluginmanager'
    } # switch

    Return $Result
} # Invoke-JenkinsCommand
