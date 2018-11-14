---
external help file: Jenkins-help.xml
Module Name: jenkins
online version:
schema: 2.0.0
---

# Get-JenkinsFolderList

## SYNOPSIS

Get a list of folders in a Jenkins master server.

## SYNTAX

```powershell
Get-JenkinsFolderList [-Uri] <String> [[-Credential] <PSCredential>] [[-Crumb] <String>] [[-Folder] <String>]
 [<CommonParameters>]
```

## DESCRIPTION

Returns the list of folders registered on a Jenkins Master server in either the root folder or a specified
subfolder.
This requires the Jobs Plugin to be installed on Jenkins.

## EXAMPLES

### EXAMPLE 1

```powershell
PS C:\>$Folders = Get-JenkinsFolderList `
    -Uri 'https://jenkins.contoso.com' \`
    -Credential (Get-Credential) \`
    -Verbose
```

Returns the list of job folders on https://jenkins.contoso.com using the credentials provided by the user.

### EXAMPLE 2

```powershell
PS C:\>$Folders = Get-JenkinsFolderList `
    -Uri 'https://jenkins.contoso.com' \`
    -Credential (Get-Credential) \`
    -Folder 'My Builds' \`
    -Verbose
```

Returns the list of job folders in the 'Misc' folder on https://jenkins.contoso.com using the credentials provided
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

### -Folder

The optional job folder to retrieve the folders from.

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### An array of Jenkins Folder objects.

## NOTES

## RELATED LINKS
