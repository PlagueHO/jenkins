---
external help file: Jenkins-help.xml
Module Name: jenkins
online version:
schema: 2.0.0
---

# New-JenkinsApiToken

## SYNOPSIS

Generate a new Jenkins API token.

## SYNTAX

```powershell
New-JenkinsApiToken [-Uri] <String> [[-Credential] <PSCredential>] [[-Crumb] <String>]
 [-TokenName] <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Generates a new Jenkins API token with the specified name.

## EXAMPLES

### EXAMPLE 1

```powershell
PS C:\>New-JenkinsApiToken `
    -Uri 'https://jenkins.contoso.com' \`
    -Credential (Get-Credential) \`
    -TokenName 'Test Token'

tokenName                tokenUuid                            tokenValue
---------                ---------                            ----------
New API Token (API test) 9b585257-67af-453a-8d5f-d20195609838 11bb7df286b17f63c0713d08c7c669a6c2
```

Creates a new token on https://jenkins.contoso.com named 'Test Token' associated
with the credentials provided by the user.

## PARAMETERS

### -Uri

Contains the Uri to the Jenkins Master server to set the Job definition on.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
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
Position: 2
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
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TokenName

The name of the new token to create.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
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

### An object containing the details of the new token.

## NOTES

## RELATED LINKS
