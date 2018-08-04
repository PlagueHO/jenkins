$moduleRoot = Split-Path `
    -Path $MyInvocation.MyCommand.Path `
    -Parent

$culture = 'en-us'
if (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath $PSUICulture))
{
    $culture = $PSUICulture
}
Import-LocalizedData `
    -BindingVariable LocalizedData `
    -Filename Jenkins_LocalizationData.psd1 `
    -BaseDirectory $moduleRoot `
    -UICulture $culture

# Dot source any functions in the libs folder
$libs = Get-ChildItem `
    -Path (Join-Path -Path $moduleRoot -ChildPath 'lib') `
    -Include '*.ps1' `
    -Recurse

Foreach ($lib in $libs)
{
    Write-Verbose -Message $($LocalizedData.ImportingLibFileMessage -f $lib.Fullname)
    . $lib.Fullname
}
