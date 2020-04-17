{
    param($Event)
    try {
        
        $ProgressPreference = "SilentlyContinue"
        $VerbosePreference = $env:VerbosePreference ? $env:VerbosePreference : "SilentlyContinue"
        
        $fileName = "get-repo"
        $env:repo ??= "https://github.com/haidouks/configs.git"
        $configPath = Join-Path -Path (Get-PodeServerPath) -ChildPath "configs"

        if(Test-Path $configPath) {
            Write-Verbose -Message "$fileName __ Starting to pull changes from $env:repo to: $configPath"
            git -C $configPath pull
            if ($LASTEXITCODE) { 
                Throw "Unable to pull repo: $($env:repo), exit code: $LASTEXITCODE" 
            }
        }
        else {
            Write-Verbose -Message "$fileName __ Starting to clone $env:repo to: $configPath"
            git clone $env:repo $configPath
            if ($LASTEXITCODE) { 
                Throw "Unable to clone repo: $($env:repo), exit code: $LASTEXITCODE" 
            }
        }
        Write-Verbose -Message "$fileName __ Saved repo to $configPath"
    }
    catch {
        $exception = $($PSItem | select-object * |Format-Custom -Property * -Depth 1 | Out-String)
        Write-Warning -Message "$fileName __ $exception"
    }
}
