function New-JenkinsFolder
{
    [CmdLetBinding(SupportsShouldProcess = $true)]
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
        $Name,

        [parameter(
            Position = 6,
            Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Description,

        [parameter(
            Position = 7,
            Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $XML
    )

    $null = $PSBoundParameters.Add('Type', 'Command')
    if (-not ($PSBoundParameters.ContainsKey('XML')))
    {
        # Generate the XML we need to use to create the job
        $XML = @"
<?xml version='1.0' encoding='UTF-8'?>
<com.cloudbees.hudson.plugins.folder.Folder plugin="cloudbees-folder">
  <actions/>
  <description>$Description</description>
  <properties/>
</com.cloudbees.hudson.plugins.folder.Folder>
"@
    }
    $null = $PSBoundParameters.Remove('XML')
    $Command = ''
    if ($PSBoundParameters.ContainsKey('Folder'))
    {
        $Folders = ($Folder -split '\\') -split '/'
        foreach ($Folder in $Folders)
        {
            $Command += "job/$Folder/"
        } # foreach
    } # if
    $Command += "createItem?name=$Name"
    $null = $PSBoundParameters.Remove('Name')
    $null = $PSBoundParameters.Remove('Description')
    $null = $PSBoundParameters.Remove('Folder')
    $null = $PSBoundParameters.Remove('Confirm')
    $null = $PSBoundParameters.Add('Command', $Command)
    $null = $PSBoundParameters.Add('Method', 'post')
    $null = $PSBoundParameters.Add('ContentType', 'application/xml')
    $null = $PSBoundParameters.Add('Body', $XML)
    if ($PSCmdlet.ShouldProcess(`
                $URI, `
            $($LocalizedData.NewFolderMessage -f $Name)))
    {
        $null = Invoke-JenkinsCommand @PSBoundParameters
    } # if
} # New-JenkinsFolder
