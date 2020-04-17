{
    param($Event)
    try {
        $ProgressPreference = "SilentlyContinue"
        $VerbosePreference = $env:VerbosePreference ? $env:VerbosePreference : "SilentlyContinue"
        
        $fileName = "get-configs"
        $stateFile = "./state.json"
        $configPath = Join-Path -Path (Get-PodeServerPath) -ChildPath "configs"
        $configFiles = Get-ChildItem -Path $configPath -Filter *.yaml | Select-Object Name,FullName
        $exConfigFiles = $null

        Lock-PodeObject -Object $Event.Lockable {
            $exConfigFiles = Get-PodeState -Name configFiles
            Set-PodeState -Name configFiles -Value $configFiles.Name | Out-Null
        }

        foreach($exConfigFile in $exConfigFiles) {
            if($configFiles.Name -notcontains $exConfigFile) {
                Write-Warning -Message "$fileName __ Removing unused config state $exConfigFile"
                Lock-PodeObject -Object $Event.Lockable {
                    Remove-PodeState -Name $exConfigFile 
                }
            }
        }

        foreach($configFile in $configFiles) {
            $configs = $null
            $configs = Get-Content -Path $configFile.FullName -Raw | ConvertFrom-Yaml -AllDocuments
            Write-Verbose -Message "$fileName __ Setting shared state for $($configFile.Name):`n$($configs | out-string)"
            Lock-PodeObject -Object $Event.Lockable {
                Set-PodeState -Name $configFile.Name -Value $configs | Out-Null
            }
        }

        Lock-PodeObject -Object $Event.Lockable {
            Save-PodeState -Path  $stateFile 
        }
        Write-Verbose -Message "$fileName __ Saved state to $stateFile"
    }
    catch {
        $exception = $($PSItem | select-object * |Format-Custom -Property * -Depth 1 | Out-String)
        Write-Warning -Message "$fileName __ $exception"
    }
}