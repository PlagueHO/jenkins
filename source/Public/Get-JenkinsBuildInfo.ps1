function Get-JenkinsBuildInfo
{
	[CmdLetBinding()]
	[OutputType([System.String])]
	param
	(
		[parameter(
			Position = 1,
			Mandatory = $true)]
		[System.String]
		$Uri,

		[parameter(
			Position = 2,
			Mandatory = $false)]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.CredentialAttribute()]
		$Credential,

		[parameter(
			Position = 3,
			Mandatory = $false)]
		[System.String]
		$Crumb,

		[parameter(
			Position = 4,
			Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[System.String]
		$Name,

		# [number]			BuildNumber	firstBuildNumber(usually is 1) - infinity
		# [System.String]	Permalink	lastBuild lastStableBuild lastSuccessfulBuild lastFailedBuild
		[parameter(
			Position = 5,
			Mandatory = $false)]
		[System.String]
		$Build = 'lastSuccessfulBuild',

		[parameter(
			Position = 6,
			Mandatory = $false)]
		[System.String]
		$Type = '*',
		[parameter(
			Position = 7,
			Mandatory = $false)]
		[System.String[]]
		$Attribute = @('*'),
		# i dont know what $Folder is , is it cloudbee related ? just copy it here
		[parameter(
			Position = 8,
			Mandatory = $false)]
		[ValidateNotNullOrEmpty()]
		[System.String]
		$Folder
	)

	# Get-JenkinsTreeRequest only accept single $Type
	# so it CAN'T generate something like  ?tree=artifacts[*],fullDisplayName
	# Let's hope nobody had to use it this way
	# When just getting whole info , ?tree=... can be omited -- means it can be $null or empty
	# but Invoke-JenkinsCommand DON'T allow me do it
	$Command = (Get-JenkinsTreeRequest -Type $Type -Attribute $Attribute)
	$null = $PSBoundParameters.Remove("Type")
	$null = $PSBoundParameters.Remove("Attribute")
	$null = $PSBoundParameters.Add("Command", $Command)

	#Url like https://ci.example.com/job/MyProject/lastStableBuild/...
	$null = $PSBoundParameters.Remove("Uri")
	$null = $PSBoundParameters.Remove('Name')
	$null = $PSBoundParameters.Remove('Build')
	$Uri = "{0}/{1}" -f $Uri , $(Resolve-JenkinsCommandUri -JobName $Name -Command $Build)
	$null = $PSBoundParameters.Add('Uri', $Uri)
	# Write-Verbose $Uri

	# Invoke-JenkinsCommand -Uri $Uri  -Type "rest" -Command $command -Verbose
	$null = $PSBoundParameters.Add('Type', 'rest')
	return Invoke-JenkinsCommand `
		@PSBoundParameters
	# other possible variant of this part
	# Get-JenkinsObject -Uri "https://ci.example.com/job/MyProject/lastStableBuild" -Type "artifacts" -Attribute "*" -Verbose
} # Get-JenkinsBuildInfo
