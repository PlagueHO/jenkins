---
external help file: Jenkins-help.xml
Module Name: jenkins
online version:
schema: 2.0.0
---

# Get-JenkinsPluginsList

## SYNOPSIS
Get a list of installed plugins in a Jenkins master server.

## SYNTAX

```
Get-JenkinsPluginsList [-Uri] <String> [[-Credential] <PSCredential>] [[-Crumb] <String>] [[-Api] <String>]
 [[-Depth] <String>] [<CommonParameters>]
```

## DESCRIPTION
Returns the list of installed plugins from a jenkins server, the list containing the name and version of each plugin.

## EXAMPLES

### EXAMPLE 1
```
$Plugins = Get-JenkinsPluginsList `
```

-Uri 'https://jenkins.contoso.com' \`
    -Credential (Get-Credential) \`
    -Verbose
Returns the list of installed plugins on https://jenkins.contoso.com using the credentials provided by the user.

## PARAMETERS

### -Uri
Contains the Uri to the Jenkins Master server to execute the command on.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
Contains the credentials to use to authenticate with the Jenkins Master server.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Crumb
Contains a Crumb to pass to the Jenkins Master Server if CSRF is enabled.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Api
The API to use.
Can be XML, JSON or Python.
Defaults to JSON.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: Json
Accept pipeline input: False
Accept wildcard characters: False
```

### -Depth
The depth of the tree to return (must be at least 1).
Defaults to 1.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: 1
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### An array of Jenkins objects.

## NOTES

## RELATED LINKS
