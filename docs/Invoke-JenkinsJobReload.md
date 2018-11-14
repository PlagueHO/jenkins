---
external help file: Jenkins-help.xml
Module Name: jenkins
online version:
schema: 2.0.0
---

# Invoke-JenkinsJobReload

## SYNOPSIS

Triggers a reload on a jenkins server

## SYNTAX

```powershell
Invoke-JenkinsJobReload [-Uri] <String> [[-Credential] <PSCredential>] [[-Crumb] <String>] [<CommonParameters>]
```

## DESCRIPTION

Triggers a reload on a jenkins server, e.g.
if the job configs are altered on disk.

## EXAMPLES

### EXAMPLE 1

```powershell
PS C:\>Invoke-JenkinsJobReload `
    -Uri 'https://jenkins.contoso.com' \`
    -Credential (Get-Credential) \`
    -Verbose
```

Triggers a reload of the jenkins server 'https://jenkins.contoso.com'

## PARAMETERS

### -Uri

The uri of the Jenkins server to trigger the reload on.

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
