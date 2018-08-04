---
external help file: Jenkins-help.xml
Module Name: jenkins
online version:
schema: 2.0.0
---

# Set-JenkinsJob

## SYNOPSIS
Set a Jenkins Job definition.

## SYNTAX

```
Set-JenkinsJob [-Uri] <String> [[-Credential] <PSCredential>] [[-Crumb] <String>] [[-Folder] <String>]
 [-Name] <String> [-XML] <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Sets a Jenkins Job config.xml on a Jenkins Master server.
If a folder is specified it will update the job in the specified folder.
If the job does not exist an error will occur.
If the job already exists the definition will be overwritten.

## EXAMPLES

### EXAMPLE 1
```
Set-JenkinsJob `
```

-Uri 'https://jenkins.contoso.com' \`
    -Credential (Get-Credential) \`
    -Name 'My App Build' \`
    -XML $MyAppBuildConfig \`
    -Verbose
Sets the job definition of the 'My App Build' job on https://jenkins.contoso.com using the credentials provided by
the user.

### EXAMPLE 2
```
Set-JenkinsJob `
```

-Uri 'https://jenkins.contoso.com' \`
    -Credential (Get-Credential) \`
    -Folder 'Misc' \`
    -Name 'My App Build' \`
    -XML $MyAppBuildConfig \`
    -Verbose
Sets the job definition of the 'My App Build' job in the 'Misc' folder on https://jenkins.contoso.com using the
credentials provided by the user.

## PARAMETERS

### -Uri
Contains the Uri to the Jenkins Master server to set the Job definition on.

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
The optional job folder the job is in.
This requires the Jobs Plugin to be installed on Jenkins.
If the folder does not exist then an error will occur.

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
The name of the job to set the definition on.

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

### -XML
The config XML of the job to import.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 7
Default value: None
Accept pipeline input: True (ByValue)
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

### None.

## NOTES

## RELATED LINKS
