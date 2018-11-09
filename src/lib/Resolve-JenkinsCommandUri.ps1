
function Resolve-JenkinsCommandUri
{
    [CmdLetBinding()]
    [OutputType([System.String])]
    param
    (
        [parameter(
            Position = 1,
            Mandatory = $false)]
        [System.String]
        $Folder,

        [parameter(
            Position = 2)]
        [System.String]
        $JobName,

        [parameter(
            Position = 3,
            Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Command
    )

    $segments = & {
                        if( $Folder )
                        {
                            ($Folder -split '\\') -split '/'
                        }

                        if( $JobName )
                        {
                            $JobName
                        }
                }
    $uri = ''
    if( $segments )
    {
        $uri = $segments -join '/job/'
        $uri = ('job/{0}/' -f $uri)
    }
    return '{0}{1}' -f $uri,$Command
}

