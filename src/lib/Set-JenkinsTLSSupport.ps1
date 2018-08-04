<#
    .SYNOPSIS
        Enables PowerShell to support TLS1.2 for communicating with
        newer versions of Jenkins.

    .DESCRIPTION
        This support cmdlet enables connecting to newer versions of
        Jenkins over HTTPS. Newer versions of Jenkins have deprecated
        support for SSL3/TLS, which are the default supported HTTPS
        protocols.

    .OUTPUTS
        None
#>
function Set-JenkinsTLSSupport
{
    [CmdLetBinding()]
    param
    (
    )

    if (-not ([Net.ServicePointManager]::SecurityProtocol).ToString().Contains([Net.SecurityProtocolType]::Tls12))
    {
        [Net.ServicePointManager]::SecurityProtocol = `
            [Net.ServicePointManager]::SecurityProtocol.toString() + ', ' + [Net.SecurityProtocolType]::Tls12
    }
} # function Set-JenkinsTLSSupport
