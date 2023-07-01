---
external help file: Jenkins-help.xml
Module Name: jenkins
online version:
schema: 2.0.0
---

# Get-JenkinsBuildInfo

## SYNOPSIS

Get info of a build of a job in a Jenkins master server.

## SYNTAX

```powershell
Get-JenkinsObject [-Uri] <String> [[-Credential] <PSCredential>] [[-Crumb] <String>] [-Name] <String>
 [[-Build] <String>] [[-Type] <String>] [[-Attribute] <String[]>] [[-Folder] <String>]
 [<CommonParameters>]
```

## DESCRIPTION

Returns build info of a build.

## EXAMPLES

### EXAMPLE 1

```powershell
$Jobs = Get-JenkinsBuildInfo `
    -Uri 'https://ci.athion.net' \`
    -Name 'FastAsyncWorldEdit' \`
    -Build 'lastStableBuild' \`
    -Type 'artifacts' \`
    -Attribute '*' \`
    -Verbose
```

Returns only artifacts in build info of the lastStableBuild of job FastAsyncWorldEdit on
https://ci.athion.net .

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

### -Build

BuildNumber or Permalink.
Defaults to lastSuccessfulBuild.

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

### -Type

The type of object to return.
Defaults to *.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: '*'
Accept pipeline input: False
Accept wildcard characters: False
```

### -Attribute

The list of attribute to return.
Defaults to *.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: '*'
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
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### Info of a Build.

## NOTES

## RELATED LINKS
