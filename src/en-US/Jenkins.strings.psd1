# culture="en-US"
ConvertFrom-StringData -StringData @'
    GetCrumbMessage = Get a Crumb from '{0}'.
    CrumbResponseFormatError = The crumb response '{0}' was invalid.
    UsingCrumbMessage = Using Crumb '{0}'.
    InvokingRestApiCommandMessage = Invoking Rest Api Command '{0}'.
    InvokingCommandMessage = Invoking Command '{0}'.
    InvokeRestApiCommandError = Rest Api Command '{0}' returned '{1}'.
    UpdateListBadFormatError = The {0} update list file downloaded from '{1}' was in an unexpected format.
    SuppressingRedirectMessage = Suppressing redirect-after-command to target URL '{0}'.

    NewJobMessage = Create the job '{0}'
    NewFolderMessage = Create the folder '{0}'
    DisableJobMessage = Disable the job '{0}'
    EnableJobMessage = Enable the job '{0}'
    RenameJobMessage = Rename the job '{0}' to '{1}'
    RemoveJobMessage = Delete the job '{0}'
    SetJobDefinitionMessage = Set the job definition for job '{0}'
    UpdateJenkinsPluginMessage = Update Jenkins cached plugin '{0}' to version '{1}'
    CreateJenkinsUpdateListMessage = Create Jenkins update list file '{0}'
    UpdateJenkinsCoreMessage = Update Jenkins core file to version '{0}'

    DownloadingRemoteUpdateListMessage = Downloading the remote plugin list from '{0}'.
    ProcessingRemoteUpdateListMessage = Processing the remote plugin list from '{0}'.
    ProcessingLocalUpdateListMessage = Processing the local plugin list from '{0}'.
    ProcessingPluginMessage = Processing plugin '{0}' version '{1}'.
    RemovingPluginFileMessage = Removing plugin file '{0}'.
    DownloadingPluginMessage = Downloading plugin '{0}' from '{1}' to '{2}'.
    ExistingPluginFoundMessage = Existing plugin '{0}' version '{1}' found in the cache - won't download.
    ExistingJenkinsCoreFoundMessage = Existing Jenkins Core version '{0}' found in the cache - won't download.
    RemovingJenkinsCoreFileMessage = Removing Jenkins core file '{0}'.
    DownloadingJenkinsCoreMessage = Downloading Jenkins Core from '{0}' to '{1}'.
'@
