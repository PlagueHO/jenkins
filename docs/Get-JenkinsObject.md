---
external help file: Jenkins-help.xml
Module Name: jenkins
online version:
schema: 2.0.0
---

# Get-JenkinsObject

## SYNOPSIS

Get a list of objects in a Jenkins master server.

## SYNTAX

```powershell
Get-JenkinsObject [-Uri] <String> [[-Credential] <PSCredential>] [[-Crumb] <String>] [-Type] <String>
 [-Attribute] <String[]> [[-Folder] <String>] [[-IncludeClass] <String[]>] [[-ExcludeClass] <String[]>]
 [<CommonParameters>]
```

## DESCRIPTION

Returns a list of objects within a specific level of the Jenkins tree.

## EXAMPLES

### EXAMPLE 1

```powershell
PS C:\>$Jobs = Get-JenkinsObject `
    -Uri 'https://jenkins.contoso.com' \`
    -Credential (Get-Credential) \`
    -Type 'jobs' \`
    -Attribute 'name','buildable','url','color' \`
    -Verbose
```

Returns the list of jobs on https://jenkins.contoso.com using the credentials provided by the user.

### EXAMPLE 2

```powershell
$Jobs = Get-JenkinsObject `
    -Uri 'https://jenkins.contoso.com' \`
    -Credential (Get-Credential) \`
    -Folder 'Misc' \`
    -Type 'jobs' \`
    -Attribute 'name','buildable','url','color' \`
    -Verbose
```

Returns the list of jobs in the 'Misc' folder on
https://jenkins.contoso.com using the credentials provided by the user.

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

### -Type

The type of object to return.
Defaults to jobs.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Attribute

The list of attribute to return.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 6
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
Position: 7
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
Position: 8
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
Position: 9
Default value: None
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
