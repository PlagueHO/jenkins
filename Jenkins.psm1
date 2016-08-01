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
.PARAMETER Api
    The API to use. Can be XML, JSON or Python. Defaults to JSON.
.PARAMETER Command
    This is the command and any other URI parameters that need to be passed to the API.
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
        [String] $Api = 'json',

        [parameter(
            Position=4,
            Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [String] $Command
    )

    $Headers = @{}
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

    $FullUri = "$Uri/api/$Api"
    if ($PSBoundParameters.ContainsKey('Command')) {
        $FullUri = $FullUri + '/' + $Command
    } # if

    try {
        Write-Verbose -Message $($LocalizedData.InvokingRestApiCommandMessage -f
            $FullUri)

        $Result = Invoke-RestMethod `
            -Uri $FullUri `
            -Headers $Headers `
            -Method Post
    }
    catch {
        # Todo: Improve error handling.
        Throw $_
    }

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
    }
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
    subfolder. The list of views returned can be filtered by setting the IncludeClass or ExcludeClass parameters.
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
    $Jobs = Get-JenkinsJob `
        -Uri 'https://jenkins.contoso.com' `
        -Credential (Get-Credential) `
        -ExcludeClass 'com.cloudbees.hudson.plugins.folder.Folder' `
        -Verbose
    Returns the list of jobs on https://jenkins.contoso.com using the credentials provided by the user.
.EXAMPLE
    $Jobs = Get-JenkinsJob `
        -Uri 'https://jenkins.contoso.com' `
        -Credential (Get-Credential) `
        -Folder 'Misc' `
        -ExcludeClass 'com.cloudbees.hudson.plugins.folder.Folder' `
        -Verbose
    Returns the list of jobs in the 'Misc' folder on https://jenkins.contoso.com using the credentials provided
    by the user.
.EXAMPLE
    $Folders = Get-JenkinsJob `
        -Uri 'https://jenkins.contoso.com' `
        -Credential (Get-Credential) `
        -Folder 'Misc' `
        -IncludeClass 'com.cloudbees.hudson.plugins.folder.Folder' `
        -Verbose
    Returns the list of folders in the 'Misc' folder on https://jenkins.contoso.com using the credentials
    provided by the user.
.OUTPUTS
    An array of Jenkins Job objects.
#>
function Get-JenkinsJob()
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
    return Get-JenkinsObject `
        @PSBoundParameters
} # Get-JenkinsJob


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