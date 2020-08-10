{
    param($Event)
    try {
        $ProgressPreference = "SilentlyContinue"
        $VerbosePreference = $env:VerbosePreference ? $env:VerbosePreference : "SilentlyContinue"
        
        $fileName = "get-configs"
        $configPath = Join-Path -Path (Get-PodeServerPath) -ChildPath "configs"
        $repoPath = Join-Path -Path $configPath -ChildPath "repo"
        $stateFile = Join-Path -Path $configPath -ChildPath "state.json"
        
        $configFiles = Get-ChildItem -Path $repoPath -Filter *.yaml | Select-Object Name,FullName
        $exConfigFiles = $null

        Lock-PodeObject -Object $Event.Lockable {
            $exConfigFiles = Get-PodeState -Name configFiles
            Set-PodeState -Name configFiles -Value $configFiles.Name | Out-Null
        }

        foreach($exConfigFile in $exConfigFiles) {
            if($configFiles.Name -notcontains $exConfigFile) {
                Write-Warning -Message "$(Get-Date -Format "yyyyMMddHHmmssfff") $fileName __ Removing unused config state $exConfigFile"
                Lock-PodeObject -Object $Event.Lockable {
                    Remove-PodeState -Name $exConfigFile 
                }
            }
        }

        foreach($configFile in $configFiles) {
            $configs = $null
            $configs = Get-Content -Path $configFile.FullName -Raw | ConvertFrom-Yaml -AllDocuments
            Write-Verbose -Message "$(Get-Date -Format "yyyyMMddHHmmssfff") $fileName __ Setting shared state for $($configFile.Name):`n$($configs | out-string)"
            Lock-PodeObject -Object $Event.Lockable {
                Set-PodeState -Name $configFile.Name -Value $configs | Out-Null
            }
        }

        Lock-PodeObject -Object $Event.Lockable {
            Save-PodeState -Path  $stateFile 
        }
        Write-Verbose -Message "$(Get-Date -Format "yyyyMMddHHmmssfff") $fileName __ Saved state to $stateFile"
        Invoke-PodeSchedule -Name 'get-routes'
    }
    catch {
        $exception = $($PSItem | select-object * |Format-Custom -Property * -Depth 1 | Out-String)
        Write-Warning -Message "$(Get-Date -Format "yyyyMMddHHmmssfff") $fileName __ $exception"
    }
}
