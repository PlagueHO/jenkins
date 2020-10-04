<#
.EXTERNALHELP Jenkins-help.xml
#>
#Requires -version 5.0

$script:moduleRoot = Split-Path `
    -Path $MyInvocation.MyCommand.Path `
    -Parent

#region LocalizedData
$culture = $PSUICulture

if ([System.String]::IsNullOrEmpty($culture))
{
    $culture = 'en-US'
}
else
{
    if (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath $culture)))
    {
        $culture = 'en-US'
    }
}

Import-LocalizedData `
    -BindingVariable LocalizedData `
    -Filename 'Jenkins.strings.psd1' `
    -BaseDirectory $script:moduleRoot `
    -UICulture $culture
#endregion
