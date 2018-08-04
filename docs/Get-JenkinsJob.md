---
external help file: Jenkins-help.xml
Module Name: jenkins
online version:
schema: 2.0.0
---

# Get-JenkinsJob

## SYNOPSIS
Get a Jenkins Job Definition.

## SYNTAX

```
Get-JenkinsJob [-Uri] <String> [[-Credential] <PSCredential>] [[-Crumb] <String>] [[-Folder] <String>]
 [-Name] <String> [<CommonParameters>]
```

## DESCRIPTION
Gets the config.xml of a Jenkins job if it exists on the Jenkins Master server.
If the job does not exist an error will occur.
If a folder is specified it will find the job in the specified folder.

## EXAMPLES

### EXAMPLE 1
```
Get-JenkinsJob `
```

-Uri 'https://jenkins.contoso.com' \`
    -Credential (Get-Credential) \`
    -Name 'My App Build' \`
    -Verbose
Returns the XML config of the 'My App Build' job on https://jenkins.contoso.com using the credentials provided by
the user.

### EXAMPLE 2
```
Get-JenkinsJob `
```

-Uri 'https://jenkins.contoso.com' \`
    -Credential (Get-Credential) \`
    -Folder 'Misc' \`
    -Name 'My App Build' \`
    -Verbose
Returns the XML config of the 'My App Build' job in the 'Misc' folder on https://jenkins.contoso.com using the
credentials provided by the user.

### EXAMPLE 3
```
Get-JenkinsJob `
```

-Uri 'https://jenkins.contoso.com' \`
    -Credential (Get-Credential) \`
    -Folder 'Misc/Build' \`
    -Name 'My App Build' \`
    -Verbose
Returns the XML config of the 'My App Build' job in the 'Build' folder in the 'Misc' folder on
https://jenkins.contoso.com using the credentials provided by the user.

## PARAMETERS

### -Uri
Contains the Uri to the Jenkins Master server to get the Job definition from.

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

### -Folder
The optional job folder to look for the job in.
This requires the Jobs Plugin to be installed on Jenkins.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
The name of the job definition to get.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
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

### A string containing the Jenkins Job config XML.

## NOTES

## RELATED LINKS
