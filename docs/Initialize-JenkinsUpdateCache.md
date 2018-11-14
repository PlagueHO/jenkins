---
external help file: Jenkins-help.xml
Module Name: jenkins
online version:
schema: 2.0.0
---

# Initialize-JenkinsUpdateCache

## SYNOPSIS

This function creates or updates a local Jenkins Update cache.

## SYNTAX

```powershell
Initialize-JenkinsUpdateCache [[-Uri] <String>] [-Path] <String> [-CacheUri] <String> [[-Include] <String[]>]
 [[-Exclude] <String[]>] [-UpdateCore] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

The purpose of this function is to make a local copy of the standard
Jenkins plugins found on Update-Center.
It can also cache the Jenkins WAR file.

This can allow an administrator to centrally control the plugins that are available
to local Jenkins Masters.
It can also control the Jenkins WAR file version that
is available.

It also allows creating a Jenkins Plugin cache inside DMZ or restrictive proxy
to allow plugins to be made available to internal Jenkins servers.

## EXAMPLES

### EXAMPLE 1

```powershell
PS C:\>Initialize-JenkinsUpdateCache `
    -Path d:\JenkinsCache \`
    -CacheUri 'http:\\\\jenkinscache.contoso.com\cache'
    -Include '*' \`
    -UpdateCore
```

Add or update all plugins and the Jenkins Core in the Jenkins Cache folder in
d:\JenkinsCache.

### EXAMPLE 2

```powershell
PS C:\>Initialize-JenkinsUpdateCache `
    -Path d:\JenkinsCache \`
    -CacheUri 'http:\\\\jenkinscache.contoso.com\cache'
    -Include 'Yammer'
```

Add or update the Yammer plugin in the Jenkins Cache folder in d:\JenkinsCache.

### EXAMPLE 3

```powershell
PS C:\>Initialize-JenkinsUpdateCache `
    -Path d:\JenkinsCache \`
    -CacheUri 'http:\\\\jenkinscache.contoso.com\cache'
    -Include 'A*' \`
    -UpdateCore
```

Add or update all plugins in the Jenkins Cache folder in d:\JenkinsCache.
Also, update the Jenkins Core WAR file if required.

## PARAMETERS

### -Uri

Contains the Uri to the Jenkins Update Center JSON file.

This defaults to http://updates.jenkins-ci.org/update-center.json and
should usually not need to be changed.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: Http://updates.jenkins-ci.org/update-center.json
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path

The path to the folder that the Jenkins Update Cache will be stored in.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CacheUri

Contains the Uri that the local Jenkins Update Cache will be accesible on.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Include

The optional list of plugins to include in the cache.
Wildcards supported.
If neither Include or Exclude are specified then no plugins will be cached.
This allows just caching of the Jenkins core file.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Exclude

{{Fill Exclude Description}}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UpdateCore

Setting this switch will cause the Jenkins WAR core to be cached.
If this switch is not specified and this is a new cache then the core will
still be available, but it will point to the external URI to download the core.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force

{{Fill Force Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf

Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### A list of plugin files that were downloaded to the Plugin cache.

## NOTES

## RELATED LINKS
