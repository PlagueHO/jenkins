$moduleRoot = Split-Path `
    -Path $MyInvocation.MyCommand.Path `
    -Parent

#region LocalizedData
$Culture = 'en-us'
if (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath $PSUICulture))
{
    $Culture = $PSUICulture
}
Import-LocalizedData `
    -BindingVariable LocalizedData `
    -Filename Jenkins_LocalizationData.psd1 `
    -BaseDirectory $moduleRoot `
    -UICulture $Culture
#endregion


<#
.SYNOPSIS
    Throws a custom exception.
.DESCRIPTION
    This cmdlet throws a terminating or non-terminating exception.
.PARAMETER errorId
    The Id of the exception.
.PARAMETER errorCategory
    The category of the exception. It must be a valid [System.Management.Automation.ErrorCategory]
    value.
.PARAMETER errorMessage
    The exception message.
.PARAMETER terminate
    This switch will cause the exception to terminate the cmdlet.
.EXAMPLE
    $ExceptionParameters = @{
        errorId = 'ConnectionFailure'
        errorCategory = 'ConnectionError'
        errorMessage = 'Could not connect'
    }
    New-Exception @ExceptionParameters
    Throw a ConnectionError exception with the message 'Could not connect'.
.OUTPUTS
    None
#>
function New-Exception
{
    [CmdLetBinding()]
    param
    (
        [Parameter(Mandatory)]
        [String] $errorId,

        [Parameter(Mandatory)]
        [System.Management.Automation.ErrorCategory] $errorCategory,

        [Parameter(Mandatory)]
        [String] $errorMessage,

        [Switch]
        $terminate
    )

    $exception = New-Object -TypeName System.Exception `
        -ArgumentList $errorMessage
    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
        -ArgumentList $exception, $errorId, $errorCategory, $null

    if ($true -or $()) {
        if ($Terminate)
        {
            # This is a terminating exception.
            throw $errorRecord
        }
        else
        {
            # Note: Although this method is called ThrowTerminatingError, it doesn't terminate.
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }
    } # if
} # function New-Exception


<#
.SYNOPSIS
    Assembles the tree request component for a Jenkins request.
.DESCRIPTION
    This cmdlet will assemble the ?tree= component of a Jenkins Rest API call to limit the return of specific
    types and levels of information.
.PARAMETER Depth
    The maximum number of levels of the tree to return.
.PARAMETER Type
    The category of elements to return. Can be: jobs, views.
.PARAMETER Attribute
    An array of attributes to return for each level of the tree. The attributes available will depend on the type
    specified.
.EXAMPLE
    $request = Get-JenkinsTreeRequest -Depth 4 -Type 'Jobs' -Attribute 'Name'
    Invoke-JenkinsCommand -Uri 'https://jenkins.contoso.com/' -Command $request
    This will return all Jobs within 4 levels of the tree. Only the name attribute will be returned.
.OUTPUTS
    String containing tree request.
#>
function Get-JenkinsTreeRequest()
{
    [CmdLetBinding()]
    [OutputType([String])]
    Param
    (
        [parameter(
            Position=1,
            Mandatory=$false)]
        [Int] $Depth = 1,

        [parameter(
            Position=2,
            Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [String] $Type = 'jobs',

        [parameter(
            Position=3,
            Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [String[]] $Attribute = @( 'name','buildable','url','color' )
    )

    $AllAttributes = $Attribute -join ','
    $TreeRequest = "?tree=$Type[$AllAttributes"
    for ($level = 1; $level -lt $Depth; $level++)
    {
        $TreeRequest += ",$Type[$AllAttributes"
    } # foreach
    $TreeRequest += ']' * $Depth
    return $TreeRequest
} # Get-JenkinsTreeRequest


<#
.SYNOPSIS
    Execute a Jenkins command or request via the Jenkins Rest API.
.DESCRIPTION
    This cmdlet is used to issue a command or request to a Jenkins Master via the Rest API.
.PARAMETER Uri
    Contains the Uri to the Jenkins Master server to execute the command on.
.PARAMETER Credential
    Contains the credentials to use to authenticate with the Jenkins Master server.
.PARAMETER Type
    The type of endpoint to invoke the command on. Can be set to: Rest,Command.
.PARAMETER Api
    The API to use. Only used if type is 'rest'. Can be XML, JSON or Python. Defaults to JSON.
.PARAMETER Command
    This is the command and any other URI parameters that need to be passed to the API. Should always be set if the
    Type is set to Command.
.PARAMETER Method
    The method of the web request to use. Defaults to default for the type of command.
.PARAMETER Headers
    Allows additional header values to be specified.
.EXAMPLE
    Invoke-JenkinsCommand `
        -Uri 'https://jenkins.contoso.com' `
        -Credential (Get-Credential) `
        -Api 'json' `
        -Command 'job/MuleTest/build'
    Triggers the MuleTest job on https://jenkins.contoso.com to run using the credentials provided by the user.
.EXAMPLE
    Invoke-JenkinsCommand `
        -Uri 'https://jenkins.contoso.com' `
        -Credential (Get-Credential) `
        -Api 'json'
    Returns the list of jobs in the root of the https://jenkins.contoso.com using credentials provided by the
    user.
.EXAMPLE
    Invoke-JenkinsCommand `
        -Uri 'https://jenkins.contoso.com'
    Returns the list of jobs in the root of the https://jenkins.contoso.com using no credentials for
    authorization.
.EXAMPLE
    Invoke-JenkinsCommand `
        -Uri 'https://jenkins.contoso.com' `
        -Credential (Get-Credential) `
        -Type 'Command' `
        -Command 'job/Build My App/config.xml'
    Returns the job config XML for the 'Build My App' job in https://jenkins.contoso.com using credentials provided
    by the user.
.OUTPUTS
    The result of the Api as a string.
#>
function Invoke-JenkinsCommand()
{
    [CmdLetBinding()]
    [OutputType([String])]
    Param
    (
        [parameter(
            Position=1,
            Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $Uri,

        [parameter(
            Position=2,
            Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $Credential,

        [parameter(
            Position=3,
            Mandatory=$false)]
        [ValidateSet('rest','command','restcommand')]
        [String] $Type = 'rest',

        [parameter(
            Position=4,
            Mandatory=$false)]
        [String] $Api = 'json',

        [parameter(
            Position=5,
            Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $Command,

        [parameter(
            Position=6,
            Mandatory=$false)]
        [ValidateSet('default','delete','get','head','merge','options','patch','post','put','trace')]
        [String] $Method,

        [parameter(
            Position=7,
            Mandatory=$false)]
        [System.Collections.Hashtable] $Headers = @{},

        [parameter(
            Position=8,
            Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [String] $ContentType,

        [parameter(
            Position=9,
            Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        $Body
    )

    if ($PSBoundParameters.ContainsKey('Credential')) {
        # Jenkins Credentials were passed so create the Authorization Header
        $Username = $Credential.Username

        # Decrypt the secure string password
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Credential.Password)
        $Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

        $Bytes = [System.Text.Encoding]::UTF8.GetBytes($Username + ':' + $Password)
        $Base64Bytes = [System.Convert]::ToBase64String($Bytes)

        $Headers += @{ "Authorization" = "Basic $Base64Bytes" }
    } # if

    $null = $PSBoundParameters.remove('Uri')
    $null = $PSBoundParameters.remove('Credential')
    $null = $PSBoundParameters.remove('Type')
    $null = $PSBoundParameters.remove('Headers')

    switch ($Type) {
        'rest' {
            $FullUri = "$Uri/api/$Api"
            if ($PSBoundParameters.ContainsKey('Command')) {
                $FullUri = $FullUri + '/' + $Command
            } # if

            $null = $PSBoundParameters.remove('Command')
            $null = $PSBoundParameters.remove('Api')

            try {
                Write-Verbose -Message $($LocalizedData.InvokingRestApiCommandMessage -f
                    $FullUri)

                $Result = Invoke-RestMethod `
                    -Uri $FullUri `
                    -Headers $Headers `
                    @PSBoundParameters `
                    -ErrorAction Stop
            }
            catch {
                # Todo: Improve error handling.
                Throw $_
            } # catch
        } # 'rest'
        'restcommand' {
            $FullUri = "$Uri/$Command"

            $null = $PSBoundParameters.remove('Command')
            $null = $PSBoundParameters.remove('Api')

            try {
                Write-Verbose -Message $($LocalizedData.InvokingRestApiCommandMessage -f
                    $FullUri)

                $Result = Invoke-RestMethod `
                    -Uri $FullUri `
                    -Headers $Headers `
                    @PSBoundParameters `
                    -ErrorAction Stop
            }
            catch {
                # Todo: Improve error handling.
                Throw $_
            } # catch
        } # 'rest'
        'command' {
            $FullUri = $Uri
            if ($PSBoundParameters.ContainsKey('Command')) {
                $FullUri = $FullUri + '/' + $Command
            } # if

            $null = $PSBoundParameters.remove('Command')
            $null = $PSBoundParameters.remove('Api')

            try {
                Write-Verbose -Message $($LocalizedData.InvokingCommandMessage -f
                    $FullUri)

                $Result = Invoke-WebRequest `
                    -Uri $FullUri `
                    -Headers $Headers `
                    @PSBoundParameters `
                    -ErrorAction Stop
            }
            catch {
                # Todo: Improve error handling.
                Throw $_
            } # catch
        } # 'rest'
    } # swtich
    Return $Result
} # Invoke-JenkinsCommand


<#
.SYNOPSIS
    Get a list of objects in a Jenkins master server.
.DESCRIPTION
    Returns a list of objects within a specific level of the Jenkins tree.
.PARAMETER Uri
    Contains the Uri to the Jenkins Master server to execute the command on.
.PARAMETER Credential
    Contains the credentials to use to authenticate with the Jenkins Master server.
.PARAMETER Type
    The type of object to return. Defaults to jobs.
.PARAMETER Attribute
    The list of attribute to return.
.PARAMETER Folder
    The optional job folder to retrieve the jobs from. This requires the Jobs Plugin to be installed on Jenkins.
.PARAMETER IncludeClass
    This allows the class of objects that are returned to be limited to only these types.
.PARAMETER ExcludeClass
    This allows the class of objects that are returned to exclude these types.
.EXAMPLE
    $Jobs = Get-JenkinsObject `
        -Uri 'https://jenkins.contoso.com' `
        -Credential (Get-Credential) `
        -Type 'jobs' `
        -Attribute 'name','buildable','url','color' `
        -Verbose
    Returns the list of jobs on https://jenkins.contoso.com using the credentials provided by the user.
.EXAMPLE
    $Jobs = Get-JenkinsObject `
        -Uri 'https://jenkins.contoso.com' `
        -Credential (Get-Credential) `
        -Folder 'Misc' `
        -Type 'jobs' `
        -Attribute 'name','buildable','url','color' `
        -Verbose
    Returns the list of jobs in the 'Misc' folder on
    https://jenkins.contoso.com using the credentials provided by the user.

.OUTPUTS
    An array of Jenkins objects.
#>
function Get-JenkinsObject()
{
    [CmdLetBinding()]
    [OutputType([Object[]])]
    Param
    (
        [parameter(
            Position=1,
            Mandatory=$true)]
        [String] $Uri,

        [parameter(
            Position=2,
            Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $Credential,

        [parameter(
            Position=3,
            Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $Type,

        [parameter(
            Position=4,
            Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String[]] $Attribute,

        [parameter(
            Position=5,
            Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [String] $Folder,

        [parameter(
            Position=6,
            Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [String[]] $IncludeClass,

        [parameter(
            Position=7,
            Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [String[]] $ExcludeClass
    )

    $null = $PSBoundParameters.Remove('Type')
    $null = $PSBoundParameters.Remove('Attribute')
    $null = $PSBoundParameters.Remove('IncludeClass')
    $null = $PSBoundParameters.Remove('ExcludeClass')
    $null = $PSBoundParameters.Remove('Folder')

    # To support the Folders plugin we have to create a tree
    # request that is limited to the depth of the folder we're looking for.
    $TreeRequestSplat = @{
        Type = $Type
        Attribute = $Attribute
    }
    if ($Folder) {
        $FolderItems = $Folder -split '\\'
        $TreeRequestSplat = @{
            Depth = ($FolderItems.Count + 1)
        }
    } # if
    $Command = Get-JenkinsTreeRequest @TreeRequestSplat
    $PSBoundParameters.Add('Command',$Command)

    $Result = Invoke-JenkinsCommand @PSBoundParameters
    $Objects = $Result.$Type
    if ($Folder) {
        # A folder was specified, so find it
        foreach ($FolderItem in $FolderItems) {
            foreach ($Object in $Objects) {
                if ($FolderItem -eq $Object.Name) {
                    $Objects = $Object.$Type
                } # if
            } # foreach
        } # foreach
    } # if

    if ($IncludeClass) {
        $Objects = $Objects | Where-Object -Property _class -In $IncludeClass
    } # if
    if ($ExcludeClass) {
        $Objects = $Objects | Where-Object -Property _class -NotIn $ExcludeClass
    } # if
    Return $Objects
} # Get-JenkinsObject


<#
.SYNOPSIS
    Get a list of jobs in a Jenkins master server.
.DESCRIPTION
    Returns the list of jobs registered on a Jenkins Master server in either the root folder or a specified
    subfolder. The list of jobs returned can be filtered by setting the IncludeClass or ExcludeClass parameters.
    By default any folders will be filtered from this list.
.PARAMETER Uri
    Contains the Uri to the Jenkins Master server to execute the command on.
.PARAMETER Credential
    Contains the credentials to use to authenticate with the Jenkins Master server.
.PARAMETER Folder
    The optional job folder to retrieve the jobs from. This requires the Jobs Plugin to be installed on Jenkins.
.PARAMETER IncludeClass
    This allows the class of objects that are returned to be limited to only these types.
.PARAMETER ExcludeClass
    This allows the class of objects that are returned to exclude these types.
.EXAMPLE
    $Jobs = Get-JenkinsJobList `
        -Uri 'https://jenkins.contoso.com' `
        -Credential (Get-Credential) `
        -Verbose
    Returns the list of jobs on https://jenkins.contoso.com using the credentials provided by the user.
.EXAMPLE
    $Jobs = Get-JenkinsJobList `
        -Uri 'https://jenkins.contoso.com' `
        -Credential (Get-Credential) `
        -Folder 'Misc' `
        -Verbose
    Returns the list of jobs in the 'Misc' folder on https://jenkins.contoso.com using the credentials provided
    by the user.
.EXAMPLE
    $Folders = Get-JenkinsJobList `
        -Uri 'https://jenkins.contoso.com' `
        -Credential (Get-Credential) `
        -Folder 'Misc' `
        -IncludeClass 'hudson.model.FreeStyleProject' `
        -Verbose
    Returns the list of freestyle Jenknins jobs in the 'Misc' folder on https://jenkins.contoso.com using the
    credentials provided by the user.
.EXAMPLE
    $Folders = Get-JenkinsJobList `
        -Uri 'https://jenkins.contoso.com' `
        -Credential (Get-Credential) `
        -Folder 'Misc\Builds' `
        -Verbose
    Returns the list of jobs in the 'Builds' folder within the 'Misc' folder on https://jenkins.contoso.com using the
    credentials provided by the user.
.OUTPUTS
    An array of Jenkins Job objects.
#>
function Get-JenkinsJobList()
{
    [CmdLetBinding()]
    [OutputType([Object[]])]
    Param
    (
        [parameter(
            Position=1,
            Mandatory=$true)]
        [String] $Uri,

        [parameter(
            Position=2,
            Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $Credential,

        [parameter(
            Position=3,
            Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [String] $Folder,

        [parameter(
            Position=4,
            Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [String[]] $IncludeClass,

        [parameter(
            Position=5,
            Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [String[]] $ExcludeClass
    )

    $null = $PSBoundParameters.Add( 'Type', 'jobs')
    $null = $PSBoundParameters.Add( 'Attribute', @( 'name','buildable','url','color' ) )
    # If a class was not explicitly excluded or included then excluded then
    # set the function to excluded folders.
    if (-not $PSBoundParameters.ContainsKey('ExcludeClass') `
        -and -not $PSBoundParameters.ContainsKey('IncludeClass')) {
        $PSBoundParameters.Add('ExcludeClass',@('com.cloudbees.hudson.plugins.folder.Folder'))
    } # if
    return Get-JenkinsObject `
        @PSBoundParameters
} # Get-JenkinsJobList


<#
.SYNOPSIS
    Get a Jenkins Job Definition.
.DESCRIPTION
    Gets the config.xml of a Jenkins job if it exists on the Jenkins Master server.
    If the job does not exist an error will occur.
    If a folder is specified it will find the job in the specified folder.
.PARAMETER Uri
    Contains the Uri to the Jenkins Master server to get the Job definition from.
.PARAMETER Credential
    Contains the credentials to use to authenticate with the Jenkins Master server.
.PARAMETER Folder
    The optional job folder to look for the job in. This requires the Jobs Plugin to be installed on Jenkins.
.PARAMETER Name
    The name of the job definition to get.
.EXAMPLE
    Get-JenkinsJob `
        -Uri 'https://jenkins.contoso.com' `
        -Credential (Get-Credential) `
        -Name 'My App Build' `
        -Verbose
    Returns the XML config of the 'My App Build' job on https://jenkins.contoso.com using the credentials provided by
    the user.
.EXAMPLE
    Get-JenkinsJob `
        -Uri 'https://jenkins.contoso.com' `
        -Credential (Get-Credential) `
        -Folder 'Misc' `
        -Name 'My App Build' `
        -Verbose
    Returns the XML config of the 'My App Build' job in the 'Misc' folder on https://jenkins.contoso.com using the
    credentials provided by the user.
.EXAMPLE
    Get-JenkinsJob `
        -Uri 'https://jenkins.contoso.com' `
        -Credential (Get-Credential) `
        -Folder 'Misc/Build' `
        -Name 'My App Build' `
        -Verbose
    Returns the XML config of the 'My App Build' job in the 'Build' folder in the 'Misc' folder on
    https://jenkins.contoso.com using the credentials provided by the user.
.OUTPUTS
    A string containing the Jenkins Job config XML.
#>
function Get-JenkinsJob()
{
    [CmdLetBinding()]
    [OutputType([String])]
    Param
    (
        [parameter(
            Position=1,
            Mandatory=$true)]
        [String] $Uri,

        [parameter(
            Position=2,
            Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $Credential,

        [parameter(
            Position=3,
            Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [String] $Folder,

        [parameter(
            Position=4,
            Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $Name
    )
    $null = $PSBoundParameters.Add('Type','Command')
    if ($PSBoundParameters.ContainsKey('Folder')) {
        $Folders = $Folder -split '/'
        $Command = 'job/'
        foreach ($Folder in $Folders) {
            $Command += "$Folder/job"
        } # foreach
        $Command += "/$Name/config.xml"
    } else {
        $Command = "job/$Name/config.xml"
    } # if
    $null = $PSBoundParameters.Remove('Name')
    $null = $PSBoundParameters.Remove('Folder')
    $null = $PSBoundParameters.Add('Command',$Command)
    return (Invoke-JenkinsCommand @PSBoundParameters).Content
} # Get-JenkinsJob


<#
.SYNOPSIS
    Set a Jenkins Job definition.
.DESCRIPTION
    Sets a Jenkins Job config.xml on a Jenkins Master server.
    If a folder is specified it will update the job in the specified folder.
    If the job does not exist an error will occur.
    If the job already exists the definition will be overwritten.
.PARAMETER Uri
    Contains the Uri to the Jenkins Master server to set the Job definition on.
.PARAMETER Credential
    Contains the credentials to use to authenticate with the Jenkins Master server.
.PARAMETER Folder
    The optional job folder the job is in. This requires the Jobs Plugin to be installed on Jenkins.
    If the folder does not exist then an error will occur.
.PARAMETER Name
    The name of the job to set the definition on.
.PARAMETER XML
    The config XML of the job to import.
.EXAMPLE
    Set-JenkinsJob `
        -Uri 'https://jenkins.contoso.com' `
        -Credential (Get-Credential) `
        -Name 'My App Build' `
        -XML $MyAppBuildConfig `
        -Verbose
    Sets the job definition of the 'My App Build' job on https://jenkins.contoso.com using the credentials provided by
    the user.
.EXAMPLE
    Set-JenkinsJob `
        -Uri 'https://jenkins.contoso.com' `
        -Credential (Get-Credential) `
        -Folder 'Misc' `
        -Name 'My App Build' `
        -XML $MyAppBuildConfig `
        -Verbose
    Sets the job definition of the 'My App Build' job in the 'Misc' folder on https://jenkins.contoso.com using the
    credentials provided by the user.
.OUTPUTS
    None.
#>
function Set-JenkinsJob()
{
    [CmdLetBinding(SupportsShouldProcess=$true)]
    [OutputType([String])]
    Param
    (
        [parameter(
            Position=1,
            Mandatory=$true)]
        [String] $Uri,

        [parameter(
            Position=2,
            Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $Credential,

        [parameter(
            Position=3,
            Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [String] $Folder,

        [parameter(
            Position=4,
            Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $Name,

        [parameter(
            Position=5,
            Mandatory=$true,
            ValueFromPipeline=$True)]
        [ValidateNotNullOrEmpty()]
        [String] $XML
    )
    $null = $PSBoundParameters.Add('Type','Command')
    if ($PSBoundParameters.ContainsKey('Folder')) {
        $Folders = $Folder -split '/'
        $Command = 'job/'
        foreach ($Folder in $Folders) {
            $Command += "$Folder/job"
        } # foreach
        $Command += "/$Name/config.xml"
    } else {
        $Command = "job/$Name/config.xml"
    } # if
    $null = $PSBoundParameters.Remove('Name')
    $null = $PSBoundParameters.Remove('Folder')
    $null = $PSBoundParameters.Remove('XML')
    $null = $PSBoundParameters.Remove('Confirm')
    $null = $PSBoundParameters.Add('Command',$Command)
    $null = $PSBoundParameters.Add('Method','post')
    $null = $PSBoundParameters.Add('ContentType','application/xml')
    $null = $PSBoundParameters.Add('Body',$XML)
    if ($PSCmdlet.ShouldProcess(`
        $URI,`
        $($LocalizedData.SetJobDefinitionMessage -f $Name))) {
        $null = Invoke-JenkinsCommand @PSBoundParameters
    } # if
} # Set-JenkinsJob


<#
.SYNOPSIS
    Determines if a Jenkins Job exists.
.DESCRIPTION
    Returns true if a Job exists in the specified Jenkins Master server with a matching Name. It will search inside
    a specific folder if one is passed.
.PARAMETER Uri
    Contains the Uri to the Jenkins Master server to execute the command on.
.PARAMETER Credential
    Contains the credentials to use to authenticate with the Jenkins Master server.
.PARAMETER Folder
    The optional job folder to look for the job in. This requires the Jobs Plugin to be installed on Jenkins.
.PARAMETER Name
    The name of the job to check for.
.EXAMPLE
    Test-JenkinsJob `
        -Uri 'https://jenkins.contoso.com' `
        -Credential (Get-Credential) `
        -Name 'My App Build' `
        -Verbose
    Returns true if the 'My App Build' job is found on https://jenkins.contoso.com using the credentials provided by
    the user.
.EXAMPLE
    Test-JenkinsJob `
        -Uri 'https://jenkins.contoso.com' `
        -Credential (Get-Credential) `
        -Folder 'Misc' `
        -Name 'My App Build' `
        -Verbose
    Returns true if the 'My App Build' job is found in the 'Misc' folder on https://jenkins.contoso.com using the
    credentials provided by the user.
.OUTPUTS
    A boolean indicating if the job was found or not.
#>
function Test-JenkinsJob()
{
    [CmdLetBinding()]
    [OutputType([Boolean])]
    Param
    (
        [parameter(
            Position=1,
            Mandatory=$true)]
        [String] $Uri,

        [parameter(
            Position=2,
            Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $Credential,

        [parameter(
            Position=3,
            Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [String] $Folder,

        [parameter(
            Position=4,
            Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [String] $Name
    )

    $null = $PSBoundParameters.Add( 'Type', 'jobs')
    $null = $PSBoundParameters.Add( 'Attribute', @( 'name' ) )
    $null = $PSBoundParameters.Remove( 'Name' )
    return ((@(Get-JenkinsObject @PSBoundParameters | Where-Object -Property Name -eq $Name)).Count -gt 0)
} # Test-JenkinsJob


<#
.SYNOPSIS
    Create a new Jenkins Job.
.DESCRIPTION
    Creates a new Jenkins Job using the provided XML.
    If a folder is specified it will create the job in the specified folder.
    If the job already exists an error will occur.
.PARAMETER Uri
    Contains the Uri to the Jenkins Master server to set the Job definition on.
.PARAMETER Credential
    Contains the credentials to use to authenticate with the Jenkins Master server.
.PARAMETER Folder
    The optional job folder the job is in. This requires the Jobs Plugin to be installed on Jenkins.
    If the folder does not exist then an error will occur.
.PARAMETER Name
    The name of the job to set the definition on.
.PARAMETER XML
    The config XML of the job to import.
.EXAMPLE
    New-JenkinsJob `
        -Uri 'https://jenkins.contoso.com' `
        -Credential (Get-Credential) `
        -Name 'My App Build' `
        -XML $MyAppBuildConfig `
        -Verbose
    Sets the job definition of the 'My App Build' job on https://jenkins.contoso.com using the credentials provided by
    the user.
.EXAMPLE
    New-JenkinsJob `
        -Uri 'https://jenkins.contoso.com' `
        -Credential (Get-Credential) `
        -Folder 'Misc' `
        -Name 'My App Build' `
        -XML $MyAppBuildConfig `
        -Verbose
    Sets the job definition of the 'My App Build' job in the 'Misc' folder on https://jenkins.contoso.com using the
    credentials provided by the user.
.OUTPUTS
    None.
#>
function New-JenkinsJob()
{
    [CmdLetBinding(SupportsShouldProcess=$true)]
    [OutputType([String])]
    Param
    (
        [parameter(
            Position=1,
            Mandatory=$true)]
        [String] $Uri,

        [parameter(
            Position=2,
            Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $Credential,

        [parameter(
            Position=3,
            Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [String] $Folder,

        [parameter(
            Position=4,
            Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $Name,

        [parameter(
            Position=5,
            Mandatory=$true,
            ValueFromPipeline=$True)]
        [ValidateNotNullOrEmpty()]
        [String] $XML
    )
    $null = $PSBoundParameters.Add('Type','Command')
    $Command = ''
    if ($PSBoundParameters.ContainsKey('Folder')) {
        $Folders = $Folder -split '/'
        foreach ($Folder in $Folders) {
            $Command += "job/$Folder"
        } # foreach
    } # if
    $Command += "createItem?name=$Name"
    $null = $PSBoundParameters.Remove('Name')
    $null = $PSBoundParameters.Remove('Folder')
    $null = $PSBoundParameters.Remove('XML')
    $null = $PSBoundParameters.Remove('Confirm')
    $null = $PSBoundParameters.Add('Command',$Command)
    $null = $PSBoundParameters.Add('Method','post')
    $null = $PSBoundParameters.Add('ContentType','application/xml')
    $null = $PSBoundParameters.Add('Body',$XML)
    if ($PSCmdlet.ShouldProcess(`
        $URI,`
        $($LocalizedData.NewJobMessage -f $Name))) {
        $null = Invoke-JenkinsCommand @PSBoundParameters
    } # if
} # New-JenkinsJob


<#
.SYNOPSIS
    Remove an existing Jenkins Job.
.DESCRIPTION
    Deletes an existing Jenkins Job in the specified Jenkins Master server.
    If a folder is specified it will remove the job in the specified folder.
    If the job does not exist an error will occur.
.PARAMETER Uri
    Contains the Uri to the Jenkins Master server to set the Job definition on.
.PARAMETER Credential
    Contains the credentials to use to authenticate with the Jenkins Master server.
.PARAMETER Folder
    The optional job folder the job is in. This requires the Jobs Plugin to be installed on Jenkins.
    If the folder does not exist then an error will occur.
.PARAMETER Name
    The name of the job to set the definition on.
.EXAMPLE
    Remove-JenkinsJob `
        -Uri 'https://jenkins.contoso.com' `
        -Credential (Get-Credential) `
        -Name 'My App Build' `
        -Verbose
    Remove the 'My App Build' job on https://jenkins.contoso.com using the credentials provided by
    the user.
.EXAMPLE
    Remove-JenkinsJob `
        -Uri 'https://jenkins.contoso.com' `
        -Credential (Get-Credential) `
        -Folder 'Misc' `
        -Name 'My App Build' `
        -Verbose
    Remove the 'My App Build' job from the 'Misc' folder on https://jenkins.contoso.com using the
    credentials provided by the user.
.OUTPUTS
    None.
#>
function Remove-JenkinsJob()
{
    [CmdLetBinding(SupportsShouldProcess=$true,
        ConfirmImpact="High")]
    Param
    (
        [parameter(
            Position=1,
            Mandatory=$true)]
        [String] $Uri,

        [parameter(
            Position=2,
            Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $Credential,

        [parameter(
            Position=3,
            Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [String] $Folder,

        [parameter(
            Position=4,
            Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $Name,

        [Switch] $Force
    )
    $null = $PSBoundParameters.Add('Type','Command')
    if ($PSBoundParameters.ContainsKey('Folder')) {
        $Folders = $Folder -split '/'
        $Command = 'job/'
        foreach ($Folder in $Folders) {
            $Command += "$Folder/job"
        } # foreach
        $Command += "/$Name/doDelete"
    } else {
        $Command = "job/$Name/doDelete"
    } # if
    $null = $PSBoundParameters.Remove('Name')
    $null = $PSBoundParameters.Remove('Folder')
    $null = $PSBoundParameters.Remove('Confirm')
    $null = $PSBoundParameters.Remove('Force')
    $null = $PSBoundParameters.Add('Command',$Command)
    $null = $PSBoundParameters.Add('Method','post')
    if ($Force -or $PSCmdlet.ShouldProcess(`
        $URI,`
        $($LocalizedData.RemoveJobMessage -f $Name))) {
        $null = Invoke-JenkinsCommand @PSBoundParameters
    } # if
} # Remove-JenkinsJob


<#
.SYNOPSIS
    Invoke an existing Jenkins Job.
.DESCRIPTION
    Runs an existing Jenkins Job.
    If a folder is specified it will run the job in the specified folder.
    If the job does not exist an error will occur.
.PARAMETER Uri
    Contains the Uri to the Jenkins Master server to set the Job definition on.
.PARAMETER Credential
    Contains the credentials to use to authenticate with the Jenkins Master server.
.PARAMETER Folder
    The optional job folder the job is in. This requires the Jobs Plugin to be installed on Jenkins.
    If the folder does not exist then an error will occur.
.PARAMETER Name
    The name of the job to set the definition on.
.PARAMETER Parameters
    This is a hash table containg the job parameters for a parameterized job. The parameter names
    are case sensitive. If the job is a parameterized then this parameter must be passed even if it
    is empty.
.EXAMPLE
    Invoke-JenkinsJob `
        -Uri 'https://jenkins.contoso.com' `
        -Credential (Get-Credential) `
        -Name 'My App Build' `
        -Verbose
    Invoke the 'My App Build' job on https://jenkins.contoso.com using the credentials provided by
    the user.
.EXAMPLE
    Invoke-JenkinsJob `
        -Uri 'https://jenkins.contoso.com' `
        -Credential (Get-Credential) `
        -Folder 'Misc' `
        -Name 'My App Build' `
        -Verbose
    Invoke the 'My App Build' job from the 'Misc' folder on https://jenkins.contoso.com using the
    credentials provided by the user.
.EXAMPLE
    Invoke-JenkinsJob `
        -Uri 'https://jenkins.contoso.com' `
        -Credential (Get-Credential) `
        -Name 'My App Build' `
        -Parameters @{ verbosity = 'full'; buildtitle = 'test build' } `
        -Verbose
    Invoke the 'My App Build' job on https://jenkins.contoso.com using the credentials provided by the
    user and passing the build parameters verbosity and buildtitle.
.OUTPUTS
    None.
#>
function Invoke-JenkinsJob()
{
    [CmdLetBinding()]
    Param
    (
        [parameter(
            Position=1,
            Mandatory=$true)]
        [String] $Uri,

        [parameter(
            Position=2,
            Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $Credential,

        [parameter(
            Position=3,
            Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [String] $Folder,

        [parameter(
            Position=4,
            Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $Name,

        [parameter(
            Position=5,
            Mandatory=$false)]
        [Hashtable] $Parameters
    )
    $null = $PSBoundParameters.Add('Type','RestCommand')
    if ($PSBoundParameters.ContainsKey('Folder')) {
        $Folders = $Folder -split '/'
        $Command = 'job/'
        foreach ($Folder in $Folders) {
            $Command += "$Folder/job"
        } # foreach
        $Command += "/$Name/build"
    } else {
        $Command = "job/$Name/build"
    } # if
    $null = $PSBoundParameters.Remove('Name')
    $null = $PSBoundParameters.Remove('Folder')
    $null = $PSBoundParameters.Remove('Confirm')
    $null = $PSBoundParameters.Remove('Parameters')
    $null = $PSBoundParameters.Add('Command',$Command)
    $null = $PSBoundParameters.Add('Method','post')
    if ($Parameters) {
        $postValues = @()
        foreach ($key in $Parameters.Keys) {
            $postValues += @( @{ name = $key; value = $Parameters[$key] } )
        } # foreach
        $postObject = @{ parameter = $postValues }
        $body = @{ json = (ConvertTo-JSON -InputObject $postObject) }
        $null = $PSBoundParameters.Add('Body',$body)
    }
    $Result = Invoke-JenkinsCommand @PSBoundParameters
} # Invoke-JenkinsJob


<#
.SYNOPSIS
    Get a list of views in a Jenkins master server.
.DESCRIPTION
    Returns the list of views registered on a Jenkins Master server. The list of views returned can be filtered by
    setting the IncludeClass or ExcludeClass parameters.
.PARAMETER Uri
    Contains the Uri to the Jenkins Master server to execute the command on.
.PARAMETER Credential
    Contains the credentials to use to authenticate with the Jenkins Master server.
.PARAMETER IncludeClass
    This allows the class of objects that are returned to be limited to only these types.
.PARAMETER ExcludeClass
    This allows the class of objects that are returned to exclude these types.
.EXAMPLE
    $Views = Get-JenkinsView `
        -Uri 'https://jenkins.contoso.com' `
        -Credential (Get-Credential) `
        -Verbose
    Returns the list of views on https://jenkins.contoso.com using the credentials provided by the user.
.EXAMPLE
    $Views = Get-JenkinsView `
        -Uri 'https://jenkins.contoso.com' `
        -Credential (Get-Credential) `
        -ExcludeClass 'hudson.model.AllView' `
        -Verbose
    Returns the list of views except for the AllView on https://jenkins.contoso.com using the credentials provided
    by the user.
.OUTPUTS
    An array of Jenkins View objects.
#>
function Get-JenkinsView()
{
    [CmdLetBinding()]
    [OutputType([Object[]])]
    Param
    (
        [parameter(
            Position=1,
            Mandatory=$true)]
        [String] $Uri,

        [parameter(
            Position=2,
            Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $Credential,

        [parameter(
            Position=3,
            Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [String[]] $IncludeClass,

        [parameter(
            Position=4,
            Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [String[]] $ExcludeClass
    )

    $null = $PSBoundParameters.Add( 'Type', 'views')
    $null = $PSBoundParameters.Add( 'Attribute', @( 'name','url' ) )
    return Get-JenkinsObject `
        @PSBoundParameters
} # Get-JenkinsView


<#
.SYNOPSIS
    Determines if a Jenkins View exists.
.DESCRIPTION
    Returns true if a View exists in the specified Jenkins Master server with a matching Name.
.PARAMETER Uri
    Contains the Uri to the Jenkins Master server to execute the command on.
.PARAMETER Credential
    Contains the credentials to use to authenticate with the Jenkins Master server.
.PARAMETER Name
    The name of the view to check for.
.EXAMPLE
    Test-JenkinsView `
        -Uri 'https://jenkins.contoso.com' `
        -Credential (Get-Credential) `
        -Name 'My View' `
        -Verbose
    Returns true if the 'My View' view is found on https://jenkins.contoso.com using the credentials provided by
    the user.
.OUTPUTS
    A boolean indicating if the View was found or not.
#>
function Test-JenkinsView()
{
    [CmdLetBinding()]
    [OutputType([Boolean])]
    Param
    (
        [parameter(
            Position=1,
            Mandatory=$true)]
        [String] $Uri,

        [parameter(
            Position=2,
            Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $Credential,

        [parameter(
            Position=3,
            Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [String] $Name
    )

    $null = $PSBoundParameters.Add( 'Type', 'views')
    $null = $PSBoundParameters.Add( 'Attribute', @( 'name' ) )
    $null = $PSBoundParameters.Remove( 'Name' )
    return ((@(Get-JenkinsObject @PSBoundParameters | Where-Object -Property Name -eq $Name)).Count -gt 0)
} # Test-JenkinsView


<#
.SYNOPSIS
    Get a list of folders in a Jenkins master server.
.DESCRIPTION
    Returns the list of folders registered on a Jenkins Master server in either the root folder or a specified
    subfolder.
    This requires the Jobs Plugin to be installed on Jenkins.
.PARAMETER Uri
    Contains the Uri to the Jenkins Master server to execute the command on.
.PARAMETER Credential
    Contains the credentials to use to authenticate with the Jenkins Master server.
.PARAMETER Folder
    The optional job folder to retrieve the folders from.
.EXAMPLE
    $Folders = Get-JenkinsFolderList `
        -Uri 'https://jenkins.contoso.com' `
        -Credential (Get-Credential) `
        -Verbose
    Returns the list of job folders on https://jenkins.contoso.com using the credentials provided by the user.
.EXAMPLE
    $Folders = Get-JenkinsFolderList `
        -Uri 'https://jenkins.contoso.com' `
        -Credential (Get-Credential) `
        -Folder 'My Builds' `
        -Verbose
    Returns the list of job folders in the 'Misc' folder on https://jenkins.contoso.com using the credentials provided
    by the user.
.OUTPUTS
    An array of Jenkins Folder objects.
#>
function Get-JenkinsFolderList()
{
    [CmdLetBinding()]
    [OutputType([Object[]])]
    Param
    (
        [parameter(
            Position=1,
            Mandatory=$true)]
        [String] $Uri,

        [parameter(
            Position=2,
            Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $Credential,

        [parameter(
            Position=3,
            Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [String] $Folder
    )

    $null = $PSBoundParameters.Add( 'Type', 'jobs')
    $null = $PSBoundParameters.Add( 'Attribute', @( 'name','url','color' ) )
    $null = $PSBoundParameters.Add( 'IncludeClass', 'com.cloudbees.hudson.plugins.folder.Folder')
    return Get-JenkinsObject `
        @PSBoundParameters
} # Get-JenkinsFolderList


<#
.SYNOPSIS
    Determines if a Jenkins Folder exists.
.DESCRIPTION
    Returns true if a Folder exists in the specified Jenkins Master server with a matching Name.
    This requires the Jobs Plugin to be installed on Jenkins.
    It will search inside a specific folder if one is passed.
.PARAMETER Uri
    Contains the Uri to the Jenkins Master server to execute the command on.
.PARAMETER Credential
    Contains the credentials to use to authenticate with the Jenkins Master server.
.PARAMETER Folder
    The optional folder to look for the folder in.
.PARAMETER Name
    The name of the folder to check for.
.EXAMPLE
    Test-JenkinsFolder `
        -Uri 'https://jenkins.contoso.com' `
        -Credential (Get-Credential) `
        -Name 'My Builds' `
        -Verbose
    Returns true if the 'My Builds' folder is found on https://jenkins.contoso.com using the
    credentials provided by the user.
.EXAMPLE
    Test-JenkinsFolder `
        -Uri 'https://jenkins.contoso.com' `
        -Credential (Get-Credential) `
        -Folder 'Misc' `
        -Name 'My Builds' `
        -Verbose
    Returns true if the 'My Builds' folder is found in the 'Misc' folder on https://jenkins.contoso.com using the
    credentials provided by the user.
.OUTPUTS
    A boolean indicating if the was found or not.
#>
function Test-JenkinsFolder()
{
    [CmdLetBinding()]
    [OutputType([Boolean])]
    Param
    (
        [parameter(
            Position=1,
            Mandatory=$true)]
        [String] $Uri,

        [parameter(
            Position=2,
            Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $Credential,

        [parameter(
            Position=3,
            Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [String] $Folder,

        [parameter(
            Position=4,
            Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [String] $Name
    )

    $null = $PSBoundParameters.Add( 'Type', 'jobs')
    $null = $PSBoundParameters.Add( 'Attribute', @( 'name' ) )
    $null = $PSBoundParameters.Add( 'IncludeClass', 'com.cloudbees.hudson.plugins.folder.Folder')
    $null = $PSBoundParameters.Remove( 'Name' )
    return ((@(Get-JenkinsObject @PSBoundParameters | Where-Object -Property Name -eq $Name)).Count -gt 0)
} # Test-JenkinsFolder
