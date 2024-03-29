@{
    PSDependOptions       = @{
        AddToPath  = $true
        Target     = 'output\RequiredModules'
        Parameters = @{
            Repository = ''
        }
    }

    invokeBuild           = 'latest'
    PSScriptAnalyzer      = 'latest'
    Pester                = '4.10.1'
    Plaster               = 'latest'
    Platyps               = 'latest'
    ModuleBuilder         = 'latest'
    ChangelogManagement   = 'latest'
    Sampler               = 'latest'
    'Sampler.GitHubTasks' = 'latest'
    MarkdownLinkCheck     = 'latest'
}
