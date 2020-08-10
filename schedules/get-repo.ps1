{
    param($Event)
    try {
        
        $ProgressPreference = "SilentlyContinue"
        $VerbosePreference = $env:VerbosePreference ? $env:VerbosePreference : "SilentlyContinue"
        
        $env:GIT_REDIRECT_STDERR = '2>&1'
        $fileName = "get-repo"
        $env:repo ??= "https://github.com/haidouks/configs.git"
        $configPath = Join-Path -Path (Get-PodeServerPath) -ChildPath "configs"
        (Test-Path -Path $configPath) ? "" : (New-Item -Path $configPath -ItemType Directory)
        $repoPath = Join-Path -Path $configPath -ChildPath "repo"
        

        if(Test-Path $repoPath) {
            Write-Verbose -Message "$(Get-Date -Format "yyyyMMddHHmmssfff") $fileName __ Starting to pull changes from $env:repo to: $repoPath"
            git -C $repoPath pull
            if ($LASTEXITCODE) { 
                Throw "$(Get-Date -Format "yyyyMMddHHmmssfff") Unable to pull repo: $($env:repo), exit code: $LASTEXITCODE" 
            }
        }
        else {
            Write-Verbose -Message "$(Get-Date -Format "yyyyMMddHHmmssfff") $fileName __ Starting to clone $env:repo to: $repoPath"
            git clone $env:repo $repoPath
            if ($LASTEXITCODE) { 
                Throw "$(Get-Date -Format "yyyyMMddHHmmssfff") Unable to clone repo: $($env:repo), exit code: $LASTEXITCODE" 
            }
            Write-Verbose -Message "$(Get-Date -Format "yyyyMMddHHmmssfff") $fileName __ Waiting 15 seconds after first clone"
            Start-Sleep -Seconds 15

        }
        Write-Verbose -Message "$(Get-Date -Format "yyyyMMddHHmmssfff") $fileName __ Saved repo to $configPath"
        Invoke-PodeSchedule -Name 'get-configs'
    }
    catch {
        $exception = $($PSItem | select-object * |Format-Custom -Property * -Depth 1 | Out-String)
        Write-Warning -Message "$fileName __ $exception"
    }
}
