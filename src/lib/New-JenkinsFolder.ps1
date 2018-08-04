<#
    .SYNOPSIS
        Create a new Jenkins Folder.

    .DESCRIPTION
        Creates a new Jenkins Folder with the specifed Name and optional Description.
        If a folder is specified it will create the new folder inside the specified folder.
        If the folder already exists an error will occur.
        If XML is provided then the XML will be used instead of being generated automatically
        from the Name and description.
        This requires the Jobs Plugin to be installed on Jenkins.

    .PARAMETER Uri
        Contains the Uri to the Jenkins Master server to set the Job definition on.

    .PARAMETER Credential
        Contains the credentials to use to authenticate with the Jenkins Master server.

    .PARAMETER Crumb
        Contains a Crumb to pass to the Jenkins Master Server if CSRF is enabled.

    .PARAMETER Folder
        The optional folder the new folder will be created in.
        If the folder does not exist then an error will occur.

    .PARAMETER Name
        The name of the new folder to create.

    .PARAMETER Description
        The optional description of the new folder to create.

    .PARAMETER XML
        The optional config XML for the new folder.
        This allows additional properties to be set on the folder.

    .EXAMPLE
        New-JenkinsFolder `
            -Uri 'https://jenkins.contoso.com' `
            -Credential (Get-Credential) `
            -Name 'Management' `
            -Description 'Management jobs' `
            -Verbose
        Creates a new folder on https://jenkins.contoso.com using the credentials provided by
        the user.

    .EXAMPLE
        New-JenkinsFolder `
            -Uri 'https://jenkins.contoso.com' `
            -Credential (Get-Credential) `
            -Folder 'Apps' `
            -Name 'Management' `
            -Description 'Management jobs' `
            -Verbose
        Creates a new folder in the 'Apps' folder on https://jenkins.contoso.com using the credentials provided by
        the user.

    .OUTPUTS
        None.
#>
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
