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

    $Command = Resolve-JenkinsCommandUri -Folder $Folder -JobName $Name -Command 'config.xml'

    $null = $PSBoundParameters.Remove('Name')
    $null = $PSBoundParameters.Remove('Folder')
    $null = $PSBoundParameters.Add('Command', $Command)
    $configXml = (Invoke-JenkinsCommand @PSBoundParameters).Content
    return $configXml -replace '^<\?xml\ version=(''|")1\.1(''|")', '<?xml version=''1.0'''
} # Get-JenkinsJob
