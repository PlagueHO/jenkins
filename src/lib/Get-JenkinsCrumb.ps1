function Get-JenkinsCrumb
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
        $Credential
    )

    if ($PSBoundParameters.ContainsKey('Credential'))
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

    $null = $PSBoundParameters.remove('Uri')
    $null = $PSBoundParameters.remove('Credential')
    $FullUri = '{0}/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)' -f $Uri

    try
    {
        Write-Verbose -Message $($LocalizedData.GetCrumbMessage -f
            $FullUri)

        Set-JenkinsTLSSupport

        $Result = Invoke-WebRequest `
            -Uri $FullUri `
            -Headers $Headers `
            -ErrorAction Stop
    }
    catch
    {
        # Todo: Improve error handling.
        Throw $_
    } # catch

    $Regex = '^Jenkins-Crumb:([A-Z0-9]*)'
    $Matches = @([regex]::matches($Result.Content, $Regex, 'IgnoreCase'))

    if (-not $Matches.Groups)
    {
        # Attempt to match the alternate Jenkins Crumb format
        $Regex = '^.crumb:([A-Z0-9]*)'
        $Matches = @([regex]::matches($Result.Content, $Regex, 'IgnoreCase'))
        if (-not $Matches.Groups)
        {
            $ExceptionParameters = @{
                errorId       = 'CrumbResponseFormatError'
                errorCategory = 'InvalidArgument'
                errorMessage  = $($LocalizedData.CrumbResponseFormatError -f `
                        $Result.Content)
            }
            New-JenkinsException @ExceptionParameters
        } # if
    } # if

    $Crumb = $Matches.Groups[1].Value

    return $Crumb
} # Get-JenkinsCrumb
