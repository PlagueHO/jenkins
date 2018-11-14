---
external help file: Jenkins-help.xml
Module Name: jenkins
online version:
schema: 2.0.0
---

# Invoke-JenkinsCommand

## SYNOPSIS

Execute a Jenkins command or request via the Jenkins Rest API.

## SYNTAX

```powershell
Invoke-JenkinsCommand [-Uri] <String> [[-Credential] <PSCredential>] [[-Crumb] <String>] [[-Type] <String>]
 [[-Api] <String>] [-Command] <String> [[-Method] <String>] [[-Headers] <Hashtable>] [[-ContentType] <String>]
 [[-Body] <Object>] [<CommonParameters>]
```

## DESCRIPTION

This cmdlet is used to issue a command or request to a Jenkins Master via the Rest API.

## EXAMPLES

### EXAMPLE 1

```powershell
PS C:\>Invoke-JenkinsCommand `
    -Uri 'https://jenkins.contoso.com' \`
    -Credential (Get-Credential) \`
    -Crumb $Crumb \`
    -Api 'json' \`
    -Command 'job/MuleTest/build'
```

Triggers the MuleTest job on https://jenkins.contoso.com to run using the credentials provided by the user.

### EXAMPLE 2

```powershell
PS C:\>Invoke-JenkinsCommand `
    -Uri 'https://jenkins.contoso.com' \`
    -Credential (Get-Credential) \`
    -Api 'json'
```

Returns the list of jobs in the root of the https://jenkins.contoso.com using credentials provided by the
user.

### EXAMPLE 3

```powershell
PS C:\>Invoke-JenkinsCommand `
    -Uri 'https://jenkins.contoso.com'
```

Returns the list of jobs in the root of the https://jenkins.contoso.com using no credentials for
authorization.

### EXAMPLE 4

```powershell
PS C:\>Invoke-JenkinsCommand `
    -Uri 'https://jenkins.contoso.com' \`
    -Credential (Get-Credential) \`
    -Type 'Command' \`
    -Command 'job/Build My App/config.xml'
```

Returns the job config XML for the 'Build My App' job in https://jenkins.contoso.com using credentials provided
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

### -Type

The type of endpoint to invoke the command on.
Can be set to: Rest,Command.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: Rest
Accept pipeline input: False
Accept wildcard characters: False
```

### -Api

The API to use.
Only used if type is 'rest'.
Can be XML, JSON or Python.
Defaults to JSON.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: Json
Accept pipeline input: False
Accept wildcard characters: False
```

### -Command

This is the command and any other URI parameters that need to be passed to the API.
Should always be set if the
Type is set to Command.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Method

The method of the web request to use.
Defaults to default for the type of command.

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

### -Headers

Allows additional header values to be specified.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: @{}
Accept pipeline input: False
Accept wildcard characters: False
```

### -ContentType

{{Fill ContentType Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Body

{{Fill Body Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 11
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### The result of the Api as a string.

## NOTES

## RELATED LINKS
