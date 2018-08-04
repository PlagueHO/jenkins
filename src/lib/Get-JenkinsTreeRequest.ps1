<#
    .SYNOPSIS
        Assembles the tree request component for a Jenkins request.

    .DESCRIPTION
        This cmdlet will assemble the ?tree= component of a Jenkins Rest API call
        to limit the return of specific types and levels of information.

    .PARAMETER Depth
        The maximum number of levels of the tree to return.

    .PARAMETER Type
        The category of elements to return. Can be: jobs, views.

    .PARAMETER Attribute
        An array of attributes to return for each level of the tree. The attributes
        available will depend on the type specified.

    .EXAMPLE
        $request = Get-JenkinsTreeRequest -Depth 4 -Type 'Jobs' -Attribute 'Name'
        Invoke-JenkinsCommand -Uri 'https://jenkins.contoso.com/' -Command $request
        This will return all Jobs within 4 levels of the tree. Only the name
        attribute will be returned.

    .OUTPUTS
        String containing tree request.
#>
function Get-JenkinsTreeRequest
{
    [CmdLetBinding()]
    [OutputType([System.String])]
    param
    (
        [parameter(
            Position = 1,
            Mandatory = $false)]
        [System.Int32]
        $Depth = 1,

        [parameter(
            Position = 2,
            Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Type = 'jobs',

        [parameter(
            Position = 3,
            Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String[]]
        $Attribute = @( 'name', 'buildable', 'url', 'color' )
    )

    $allAttributes = $Attribute -join ','
    $treeRequest = "?tree=$Type[$allAttributes"

    for ($level = 1; $level -lt $Depth; $level++)
    {
        $treeRequest += ",$Type[$allAttributes"
    } # foreach

    $treeRequest += ']' * $Depth

    return $treeRequest
} # Get-JenkinsTreeRequest
