---
external help file: Jenkins-help.xml
Module Name: jenkins
online version:
schema: 2.0.0
---

# Invoke-JenkinsJob

## SYNOPSIS

Invoke an existing Jenkins Job.

## SYNTAX

```powershell
Invoke-JenkinsJob [-Uri] <String> [[-Credential] <PSCredential>] [[-Crumb] <String>] [[-Folder] <String>]
 [-Name] <String> [[-Parameters] <Hashtable>] [<CommonParameters>]
```

## DESCRIPTION

Runs an existing Jenkins Job.
If a folder is specified it will run the job in the specified folder.
If the job does not exist an error will occur.

## EXAMPLES

### EXAMPLE 1

```powershell
PS C:\>Invoke-JenkinsJob `
    -Uri 'https://jenkins.contoso.com' \`
    -Credential (Get-Credential) \`
    -Name 'My App Build' \`
    -Verbose
```

Invoke the 'My App Build' job on https://jenkins.contoso.com using the credentials provided by
the user.

### EXAMPLE 2

```powershell
PS C:\>Invoke-JenkinsJob `
    -Uri 'https://jenkins.contoso.com' \`
    -Credential (Get-Credential) \`
    -Folder 'Misc' \`
    -Name 'My App Build' \`
    -Verbose
```

Invoke the 'My App Build' job from the 'Misc' folder on https://jenkins.contoso.com using the
credentials provided by the user.

### EXAMPLE 3

```powershell
PS C:\>Invoke-JenkinsJob `
    -Uri 'https://jenkins.contoso.com' \`
    -Credential (Get-Credential) \`
    -Name 'My App Build' \`
    -Parameters @{ verbosity = 'full'; buildtitle = 'test build' } \`
    -Verbose
```

Invoke the 'My App Build' job on https://jenkins.contoso.com using the credentials provided by the
user and passing the build parameters verbosity and buildtitle.

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

### -Parameters

This is a hash table containg the job parameters for a parameterized job.
The parameter names
are case sensitive.
If the job is a parameterized then this parameter must be passed even if it
is empty.

```yaml
Type: Hashtable
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

### None.

## NOTES

## RELATED LINKS
