---
external help file: Jenkins-help.xml
Module Name: jenkins
online version:
schema: 2.0.0
---

# Get-JenkinsJobList

## SYNOPSIS
Get a list of jobs in a Jenkins master server.

## SYNTAX

```
Get-JenkinsJobList [-Uri] <String> [[-Credential] <PSCredential>] [[-Crumb] <String>] [[-Folder] <String>]
 [[-IncludeClass] <String[]>] [[-ExcludeClass] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Returns the list of jobs registered on a Jenkins Master server in either the root folder or a specified
subfolder.
The list of jobs returned can be filtered by setting the IncludeClass or ExcludeClass parameters.
By default any folders will be filtered from this list.

## EXAMPLES

### EXAMPLE 1
```
$Jobs = Get-JenkinsJobList `
```

-Uri 'https://jenkins.contoso.com' \`
    -Credential (Get-Credential) \`
    -Verbose
Returns the list of jobs on https://jenkins.contoso.com using the credentials provided by the user.

### EXAMPLE 2
```
$Jobs = Get-JenkinsJobList `
```

-Uri 'https://jenkins.contoso.com' \`
    -Credential (Get-Credential) \`
    -Folder 'Misc' \`
    -Verbose
Returns the list of jobs in the 'Misc' folder on https://jenkins.contoso.com using the credentials provided
by the user.

### EXAMPLE 3
```
$Folders = Get-JenkinsJobList `
```

-Uri 'https://jenkins.contoso.com' \`
    -Credential (Get-Credential) \`
    -Folder 'Misc' \`
    -IncludeClass 'hudson.model.FreeStyleProject' \`
    -Verbose
Returns the list of freestyle Jenknins jobs in the 'Misc' folder on https://jenkins.contoso.com using the
credentials provided by the user.

### EXAMPLE 4
```
$Folders = Get-JenkinsJobList `
```

-Uri 'https://jenkins.contoso.com' \`
    -Credential (Get-Credential) \`
    -Folder 'Misc\Builds' \`
    -Verbose
Returns the list of jobs in the 'Builds' folder within the 'Misc' folder on https://jenkins.contoso.com using the
credentials provided by the user.

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

### -Folder
The optional job folder to retrieve the jobs from.
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

### -IncludeClass
This allows the class of objects that are returned to be limited to only these types.

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

### -ExcludeClass
This allows the class of objects that are returned to exclude these types.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### An array of Jenkins Job objects.

## NOTES

## RELATED LINKS
