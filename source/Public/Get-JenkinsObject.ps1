function Get-JenkinsObject
{
    [CmdLetBinding()]
    [OutputType([System.Object[]])]
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
            Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Type,

        [parameter(
            Position = 5,
            Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String[]]
        $Attribute,

        [parameter(
            Position = 6,
            Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Folder,

        [parameter(
            Position = 7,
            Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String[]]
        $IncludeClass,

        [parameter(
            Position = 8,
            Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String[]]
        $ExcludeClass
    )

    $null = $PSBoundParameters.Remove('Type')
    $null = $PSBoundParameters.Remove('Attribute')
    $null = $PSBoundParameters.Remove('IncludeClass')
    $null = $PSBoundParameters.Remove('ExcludeClass')
    $null = $PSBoundParameters.Remove('Folder')

    # To support the Folders plugin we have to create a tree
    # request that is limited to the depth of the folder we're looking for.
    $TreeRequestSplat = @{
        Type      = $Type
        Attribute = $Attribute
    }

    if ($Folder)
    {
        $FolderItems = ($Folder -split '\\') -split '/'
        $TreeRequestSplat = @{
            Depth     = ($FolderItems.Count + 1)
            Attribute = $Attribute
        }
    } # if
    $Command = Get-JenkinsTreeRequest @TreeRequestSplat
    $PSBoundParameters.Add('Command', $Command)

    $Result = Invoke-JenkinsCommand @PSBoundParameters
    $Objects = $Result.$Type

    if ($Folder)
    {
        # A folder was specified, so find it
        foreach ($FolderItem in $FolderItems)
        {

            foreach ($Object in $Objects)
            {

                if ($FolderItem -eq $Object.Name)
                {
                    $Objects = $Object.$Type
                } # if
            } # foreach
        } # foreach
    } # if

    if ($IncludeClass)
    {
        $Objects = $Objects | Where-Object -Property _class -In $IncludeClass
    } # if

    if ($ExcludeClass)
    {
        $Objects = $Objects | Where-Object -Property _class -NotIn $ExcludeClass
    } # if

    return $Objects
} # Get-JenkinsObject
