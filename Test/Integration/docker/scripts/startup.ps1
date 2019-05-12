$ProgressPreference = 'SilentlyContinue'

# SHOW CONTAINER INFO
$ip = Get-NetAdapter |
    Select-Object -First 1 |
    Get-NetIPAddress |
    Where-Object -FilterScript { $_.AddressFamily -eq 'IPv4'} |
    Select-Object -Property IPAddress |
    ForEach-Object -Process { $_.IPAddress }

Write-Host -Object '= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ' -ForegroundColor Yellow
Write-Host -Object 'JENKINS MASTER CONTAINER' -ForegroundColor Yellow
Write-Host -Object ('Started at:     {0}' -f [DateTime]::Now.ToString('yyyy-MMM-dd HH:mm:ss.fff')) -ForegroundColor Yellow
Write-Host -Object ('Container Name: {0}' -f $env:COMPUTERNAME) -ForegroundColor Yellow
Write-Host -Object ('Container IP:   {0}' -f $ip) -ForegroundColor Yellow
Write-Host -Object ('Access URL:     http://{0}:8080' -f $ip) -ForegroundColor Yellow
Write-Host -Object '= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ' -ForegroundColor Yellow

# Move default files to attached volume after the start of container
if (Test-Path -Path 'c:/backups')
{
    Get-ChildItem -Path 'c:/backups/*' -Filter "FULL-*" |
    Sort-Object -Property Name -Descending |
    Select-Object -First 1 |
    Copy-Item -Destination 'c:/jenkins/' -Recurse -Force
}

# Download plugins
if (Test-Path -Path 'c:/scripts/plugins.txt')
{
    $webClient = New-Object -TypeName System.Net.WebClient
    $plugins = Get-Content -Path 'c:/scripts/plugins.txt'

    foreach ($plugin in $plugins)
    {
        $url = ('{0}/download/plugins/{1}/latest/{1}.hpi' -f $env:JENKINS_UC,$plugin)

        if (Test-Path -Path 'c:/jenkins/plugins')
        {
            Write-Host -Object ('Skipping plugin:`t[{0}]' -f $plugin)
        }
        else
        {
            Write-Host -Object ('Downloading plugin:`t[{0}]`tfrom`t{1}' -f $plugin,$url)
            $webClient.DownloadFile($url,('c:/jenkins/plugins/{0}.jpi' -f $plugin))
        }
    }

    Remove-Item -Path 'c:/scripts/plugins.txt'
}

& 'java.exe' '-jar' 'c:/jenkins.war'
