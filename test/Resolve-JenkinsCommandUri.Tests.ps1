
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\src\Jenkins.psd1' -Resolve) -Force

Describe 'Resolve-JenkinsCommandUri.when ony an endpoint' {
    It ('should resolve' ) {
        Resolve-JenkinsCommandUri -Command 'Fubar Snafu' | Should -Be 'Fubar Snafu'
    }
}

Describe 'Resolve-JenkinsCommandUri.when folders seperated by forward slash' {
    It ('should resolve' ) {
        Resolve-JenkinsCommandUri -Command 'create' -Folder 'Fizz Buzz/Buzz Fizz' |
            Should -Be 'job/Fizz Buzz/job/Buzz Fizz/create'
    }
}

Describe 'Resolve-JenkinsCommandUri.when folders seperated by backward slash' {
    It ('should resolve' ) {
        Resolve-JenkinsCommandUri -Command 'create' -Folder 'Fizz Buzz\Buzz Fizz' |
            Should -Be 'job/Fizz Buzz/job/Buzz Fizz/create'
    }
}

Describe 'Resolve-JenkinsCommandUri.when passing a job name' {
    It ('should resolve' ) {
        Resolve-JenkinsCommandUri -Folder 'one/two/three' -JobName 'Fubar Snafu' -Command 'config.xml' | Should -Be 'job/one/job/two/job/three/job/Fubar Snafu/config.xml'
    }
}

Describe 'Resolve-JenkinsCommandUri.when folder and job name are null' {
    It ('should resolve' ) {
        Resolve-JenkinsCommandUri -Folder $null -JobName $null -Command 'config.xml' | Should -Be 'config.xml'
    }
}

