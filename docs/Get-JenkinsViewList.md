---
external help file: Jenkins-help.xml
Module Name: jenkins
online version:
schema: 2.0.0
---

# Get-JenkinsViewList

## SYNOPSIS
Get a list of views in a Jenkins master server.

## SYNTAX

```
Get-JenkinsViewList [-Uri] <String> [[-Credential] <PSCredential>] [[-Crumb] <String>]
 [[-IncludeClass] <String[]>] [[-ExcludeClass] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Returns the list of views registered on a Jenkins Master server.
The list of views returned can be filtered by
setting the IncludeClass or ExcludeClass parameters.

## EXAMPLES

### EXAMPLE 1
```
$Views = Get-JenkinsViewList `
```

-Uri 'https://jenkins.contoso.com' \`
    -Credential (Get-Credential) \`
    -Verbose
Returns the list of views on https://jenkins.contoso.com using the credentials provided by the user.

### EXAMPLE 2
```
$Views = Get-JenkinsViewList `
```

-Uri 'https://jenkins.contoso.com' \`
    -Credential (Get-Credential) \`
    -ExcludeClass 'hudson.model.AllView' \`
    -Verbose
Returns the list of views except for the AllView on https://jenkins.contoso.com using the credentials provided
by the user.

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

### -IncludeClass
This allows the class of objects that are returned to be limited to only these types.

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

### -ExcludeClass
This allows the class of objects that are returned to exclude these types.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### An array of Jenkins View objects.

## NOTES

## RELATED LINKS
