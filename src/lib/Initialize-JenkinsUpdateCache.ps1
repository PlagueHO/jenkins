function Initialize-JenkinsUpdateCache
{
    [CmdLetBinding(SupportsShouldProcess = $true)]
    [OutputType([System.IO.FileInfo])]
    param
    (
        [parameter(
            Position = 1,
            Mandatory = $false)]
        [System.String]
        $Uri = 'http://updates.jenkins-ci.org/update-center.json',

        [parameter(
            Position = 2,
            Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { Test-Path -Path $_ })]
        [System.String]
        $Path,

        [parameter(
            Position = 3,
            Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $CacheUri,

        [parameter(
            Position = 4,
            Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String[]]
        $Include,

        [parameter(
            Position = 5,
            Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String[]]
        $Exclude,

        [Switch]
        $UpdateCore,

        [Switch]
        $Force
    )

    if ($CacheUri.EndsWith('/'))
    {
        $CacheUri = $CacheUri.Substring(0, $CacheUri.Length - 1)
    } # if

    # Download the Remote Update Center JSON
    Write-Verbose -Message $($LocalizedData.DownloadingRemoteUpdateListMessage -f
        $Uri)

    Set-JenkinsTLSSupport

    $remotePluginJSON = Invoke-WebRequest `
        -Uri $Uri `
        -UseBasicParsing
    $result = $remotePluginJSON.Content -match 'updateCenter.post\(\r?\n(.*)\r?\n\);'

    if (-not $result)
    {
        $ExceptionParameters = @{
            errorId       = 'UpdateListBadFormatError'
            errorCategory = 'InvalidArgument'
            errorMessage  = $($LocalizedData.UpdateListBadFormatError -f `
                    'remote', $Uri)
        }
        New-JenkinsException @ExceptionParameters
    }
    $remoteJSON = ConvertFrom-Json -InputObject $Matches[1]

    # Generate an array of the Remote plugins and versions
    Write-Verbose -Message $($LocalizedData.ProcessingRemoteUpdateListMessage -f
        $Uri)

    $remotePlugins = [System.Collections.ArrayList] @()
    $remotePluginList = ($remoteJSON.Plugins |
            Get-Member -MemberType NoteProperty).Name
    foreach ($plugin in $remotePluginList)
    {
        if ($Include)
        {
            $addIt = $false
            # Includes only the entries that match the $Include array
            foreach ($item in $Include)
            {
                if ($plugin -like $item)
                { $addIt = $true
                }
            }
        }
        elseif ($Exclude)
        {
            # Excludes the entries that match the $Exclude array
            $addIt = $true
            foreach ($item in $Exclude)
            {
                if ($plugin -notlike $item)
                { $addIt = $false
                }
            }
        } # if
        if ($addIt)
        {
            $null = $remotePlugins.Add( $remoteJSON.Plugins.$plugin )
        }
    } # foreach

    $localUpdateListPath = Join-Path -Path $Path -ChildPath 'update-center.json'
    if (Test-Path -Path $localUpdateListPath)
    {
        $localPluginJSON = Get-Content -Path $localUpdateListPath -Raw
        $result = $localPluginJSON -match 'updateCenter.post\(\r?\n(.*)\r?\n\);'

        if (-not $result)
        {
            $exceptionParameters = @{
                errorId       = 'UpdateListBadFormatError'
                errorCategory = 'InvalidArgument'
                errorMessage  = $($LocalizedData.UpdateListBadFormatError -f `
                        'local', $localUpdateListPath)
            }
            New-JenkinsException @exceptionParameters
        }
        $localJSON = ConvertFrom-Json -InputObject $Matches[1]

        # Generate an array of the Remote plugins and versions
        Write-Verbose -Message $($LocalizedData.ProcessingLocalUpdateListMessage -f
            $localUpdateListPath)

        $localPlugins = [System.Collections.ArrayList] @()
        $localPluginList = ($LocalJSON.Plugins |
                Get-Member -MemberType NoteProperty).Name

        foreach ($plugin in $localPluginList)
        {
            if ($Include)
            {
                $addIt = $false
                # Includes only the entries that match the $Include array
                foreach ($item in $Include)
                {
                    if ($plugin -like $item)
                    { $addIt = $true
                    }
                }
            }
            elseif ($Exclude)
            {
                # Excludes the entries that match the $Exclude array
                $addIt = $true
                foreach ($item in $Exclude)
                {
                    if ($plugin -notlike $item)
                    { $addIt = $false
                    }
                }
            } # if
            if ($addIt)
            {
                $null = $localPlugins.Add( $localJSON.Plugins.$plugin )
            }
        } # foreach
    }
    else
    {
        $localPlugins = [System.Collections.ArrayList] @()
    } # if

    <#
        Now perform the comparison between the plugins that exist and the ones
        that need to be downloaded and download any missing ones.
        Step down the list of remote plugins in reverse so that we can remove
        elements from the array.
    #>
    $cacheUpdated = $false
    for ($pluginNumber = $RemotePlugins.Count - 1; $pluginNumber -ge 0; $pluginNumber--)
    {
        $remotePlugin = $RemotePlugins[$pluginNumber]
        Write-Verbose -Message $($LocalizedData.ProcessingPluginMessage -f
            $remotePlugin.name, $remotePlugin.version )

        $pluginFilename = Split-Path -Path $remotePlugin.url -Leaf

        # Find out if the plugin already exists.
        $needsUpdate = $true
        $foundPlugin = $null
        foreach ($localPlugin in $LocalPlugins)
        {
            if ($localPlugin.name -eq $remotePlugin.name)
            {
                $foundPlugin = $localPlugin
                if ($localPlugin.version -eq $remotePlugin.version)
                {
                    # TODO: Add hash check to validate cached file
                    $needsUpdate = $false
                    break
                } # if
            } # if
        } # foreach

        if ($foundPlugin)
        {
            Write-Verbose -Message $($LocalizedData.ExistingPluginFoundMessage -f
                $foundPlugin.name, $foundPlugin.version)
        }

        if ($needsUpdate)
        {
            $downloadOK = $false

            if ($Force -or $PSCmdlet.ShouldProcess(`
                        $remotePlugin.name, `
                    $($LocalizedData.UpdateJenkinsPluginMessage -f $remotePlugin.name, $remotePlugin.verion)))
            {
                # A new version of the plugin needs to be downloaded
                $PluginFilePath = Join-Path -Path $Path -ChildPath $pluginFilename

                if (Test-Path -Path $PluginFilePath)
                {
                    # The plugin file already exists so remove it
                    Write-Verbose -Message $($LocalizedData.RemovingPluginFileMessage -f
                        $PluginFilePath)

                    $null = Remove-Item -Path $PluginFilePath -Force
                } # if

                Write-Verbose -Message $($LocalizedData.DownloadingPluginMessage -f
                    $remotePlugin.name, $remotePlugin.url, $PluginFilePath)

                # Download the plugin
                try
                {
                    Invoke-WebRequest `
                        -Uri $remotePlugin.url `
                        -UseBasicParsing `
                        -OutFile $PluginFilePath `
                        -ErrorAction Stop
                    $downloadOK = $true
                }
                catch
                {
                    Write-Error -Exception $_
                } # try
                if ($downloadOk)
                {
                    $cacheUpdated = $true
                } # if
            } # if

            if ($downloadOk)
            {
                if ($foundPlugin)
                {
                    # The plugin already exists so remove the entry before adding a new one
                    $null = $localPlugins.Remove($foundPlugin)
                } # if

                # Add the plugin to the local plugins list
                $remotePlugin.url = "$CacheUri/$pluginFilename"
                $null = $localPlugins.Add( $remotePlugin )

                # Report that the file was downloaded
                Get-ChildItem -Path $pluginFilePath
            } # if
        } # if
    } # foreach

    if ($cacheUpdated)
    {
        # Generate new Local Plugin JSON object
        $newPlugins = New-Object PSCustomObject
        foreach ($plugin in $localPlugins | Sort-Object -Property name)
        {
            $null = Add-Member `
                -InputObject $newPlugins `
                -Type NoteProperty `
                -Name $plugin.name `
                -Value $plugin
        } # foreach
        $remoteJSON.plugins = $newPlugins
    } # if

    if ($UpdateCore)
    {
        # Need to see if the Jenkins Core needs to be updated
        $coreFilename = Split-Path -Path $remoteJSON.Core.url -Leaf

        if (($localJSON.Core.version -ne $remoteJSON.Core.version) -or `
            ($localJSON.Core.url -ne "$CacheUri/$coreFilename"))
        {
            $downloadOK = $false

            if ($Force -or $PSCmdlet.ShouldProcess(`
                        $remoteJSON.Core.version, `
                    $($LocalizedData.UpdateJenkinsCoreMessage -f $remoteJSON.Core.version)))
            {
                # A new version of the plugin needs to be downloaded
                $coreFilePath = Join-Path -Path $Path -ChildPath $coreFilename

                if (Test-Path -Path $coreFilePath)
                {
                    # The plugin file already exists so remove it
                    Write-Verbose -Message $($LocalizedData.RemovingJenkinsCoreFileMessage -f
                        $coreFilePath)

                    $null = Remove-Item -Path $coreFilePath -Force
                } # if

                Write-Verbose -Message $($LocalizedData.DownloadingJenkinsCoreMessage -f
                    $remoteJSON.Core.url, $coreFilePath)

                try
                {
                    Invoke-WebRequest `
                        -Uri $remoteJSON.Core.url `
                        -UseBasicParsing `
                        -OutFile $coreFilePath `
                        -ErrorAction Stop
                    $downloadOK = $true
                }
                catch
                {
                    Write-Error -Exception $_
                } # try
                if ($downloadOk)
                {
                    # Update the Cache List file
                    $remoteJSON.Core.Url = "$CacheUri/$coreFilename"
                    $cacheUpdated = $true

                    # Report that the file was downloaded
                    Get-ChildItem -Path $coreFilePath

                } # if
            } # if
        }
        else
        {
            Write-Verbose -Message $($LocalizedData.ExistingJenkinsCoreFoundMessage -f
                $remoteJSON.Core.version)
        } # if
    } # if

    if ($cacheUpdated)
    {
        # Convert the JSON object into JSON
        $newJSON = ConvertTo-Json -InputObject $remoteJSON -Compress

        # Create the new Local Plugin JSON file content
        $localPluginJSON = "updateCenter.post(`n$newJSON`n);"
        if ($Force -or $PSCmdlet.ShouldProcess(`
                    $localUpdateListPath, `
                $($LocalizedData.CreateJenkinsUpdateListMessage -f $localUpdateListPath)))
        {
            # Write out the new Local Update List file
            if (Test-Path -Path $localUpdateListPath)
            {
                $null = Remove-Item -Path $localUpdateListPath -Force
            } # if
            $null = Set-Content -Path $localUpdateListPath -Value $localPluginJSON -NoNewline
        } # if
    } # if
} # Initialize-JenkinsUpdateCache
