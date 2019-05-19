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

    $command = Resolve-JenkinsCommandUri -Folder $Folder -JobName $Name -Command 'build'

    $null = $PSBoundParameters.Remove('Name')
    $null = $PSBoundParameters.Remove('Folder')
    $null = $PSBoundParameters.Remove('Confirm')
    $null = $PSBoundParameters.Add('Command', $command)
    $null = $PSBoundParameters.Add('Method', 'post')
    $null = $PSBoundParameters.Add('Type', 'Command')

    $body = @{}

    if ($PSBoundParameters.ContainsKey('Parameters'))
    {
        $postValues = @()

        foreach ($key in $Parameters.Keys)
        {
            $postValues += @(
                @{
                    name = $key
                    value = $Parameters[$key]
                }
            )
        }

        $jsonBody = @{
            parameter = $postValues
        }

        $body = @{
            json = ConvertTo-Json -InputObject $jsonBody
        }

        $null = $PSBoundParameters.Remove('Parameters')
        $null = $PSBoundParameters.Add('Body', $body)
    }

    return Invoke-JenkinsCommand @PSBoundParameters
} # Invoke-JenkinsJob
