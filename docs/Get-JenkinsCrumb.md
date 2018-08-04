---
external help file: Jenkins-help.xml
Module Name: jenkins
online version:
schema: 2.0.0
---

# Get-JenkinsCrumb

## SYNOPSIS
Gets a Jenkins Crumb.

## SYNTAX

```
Get-JenkinsCrumb [-Uri] <String> [[-Credential] <PSCredential>] [<CommonParameters>]
```

## DESCRIPTION
This cmdlet is used to obtain a crumb that must be passed to all other commands
to a Jenkins Server if CSRF is enabled in Global Settings of the server.
The crumb must be added to the header of any commands or requests sent to this
master.

## EXAMPLES

### EXAMPLE 1
```
Get-JenkinsCrumb `
```

-Uri 'https://jenkins.contoso.com' \`
    -Credential (Get-Credential)
Returns a Jenkins Crumb.

## PARAMETERS

### -Uri
Contains the Uri to the Jenkins Master server to obtain the crumb from.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### The crumb string.

## NOTES

## RELATED LINKS
