function New-JenkinsApiToken
{
    [CmdLetBinding(SupportsShouldProcess = $true)]
    [OutputType([System.Object])]
    param (
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
        $TokenName
    )

    $NewTokenRequestBody = @{
        newTokenName = $TokenName
    }

    $JenkinsCommandParameters = @{
        Uri = $Uri
        Type = 'command'
        Command = 'me/descriptorByName/jenkins.security.ApiTokenProperty/generateNewToken'
        Method = 'post'
        Body = $NewTokenRequestBody
    }

    if ($Crumb) {
        $JenkinsCommandParameters['Crumb'] = $Crumb
    }

    if ($Credential) {
        $JenkinsCommandParameters['Credential'] = $Credential
    }

    if ($PSCmdlet.ShouldProcess($TokenName, $LocalizedData.NewApiTokenMessage))
    {
        $Response = Invoke-JenkinsCommand @JenkinsCommandParameters

        if ($Response.PSObject.Properties.name -contains 'data')
        {
            $ExpectedProperties = @('tokenName', 'tokenUuid', 'tokenValue')
            $ComparisonParameters = @{
                ReferenceObject = $ExpectedProperties
                DifferenceObject = $Response.data.PSObject.Properties.name
            }

            [PSCustomObject[]] $Comparison = Compare-Object @ComparisonParameters
            if ($Comparison.Length -gt 0)
            {
                $ExceptionParameters = @{
                    errorId       = 'ApiTokenResponseFormatError'
                    errorCategory = 'InvalidData'
                    errorMessage  = $($LocalizedData.ApiTokenResponseFormatError -f `
                        ($Response.data.PSObject.Properties.name -join ', '))
                }
                New-JenkinsException @ExceptionParameters
            }

            if ($Response.data.tokenName -ne $TokenName) {
                $ExceptionParameters = @{
                    errorId       = 'ApiTokenResponseNameError'
                    errorCategory = 'InvalidResult'
                    errorMessage  = $($LocalizedData.ApiTokenResponseNameError -f `
                        $Response.data.tokenName)
                }
                New-JenkinsException @ExceptionParameters
            }

            return $Response.data
        }
        else
        {
            $ExceptionParameters = @{
                errorId       = 'ApiTokenResponseDataMissing'
                errorCategory = 'InvalidData'
                errorMessage  = $($LocalizedData.ApiTokenResponseDataMissing)
            }
            New-JenkinsException @ExceptionParameters
        }
    }
}
