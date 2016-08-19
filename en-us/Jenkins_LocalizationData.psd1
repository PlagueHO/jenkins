# culture="en-US"
ConvertFrom-StringData -StringData @'
    InvokingRestApiCommandMessage = Invoking Rest Api Command '{0}'.
    InvokingCommandMessage = Invoking Command '{0}'.
    InvokeRestApiCommandError = Rest Api Command '{0}' returned '{1}'.
    PluginListBadFormatError = The {0} plugin list file downloaded from '{0}' was in an unexpected format.

    NewJobMessage = Create the job '{0}'
    NewFolderMessage = Create the folder '{0}'
    RemoveJobMessage = Delete the job '{0}'
    SetJobDefinitionMessage = Set the job definition for job '{0}'

    DownloadingRemotePluginListMessage = Downloading the remote plugin list from '{0}'.
    ProcessingRemotePluginListMessage = Processing the remote plugin list from '{0}'.
    ProcessingLocalPluginListMessage = Processing the local plugin list from '{0}'.
    DownloadingPluginMessage = Downloading plugin '{0}' from '{1}' to '{2}'.
'@