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
