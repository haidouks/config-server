{
    param($Event)
    try {
        $ProgressPreference = "SilentlyContinue"
        $VerbosePreference = "SilentlyContinue"
        $fileName = "get-configs"
        $stateFile = "./state.json"

        $repo = "https://github.com/haidouks/configs.git"
        $configPath = Join-Path -Path (Get-PodeServerPath) -ChildPath "configs/sample"

        if(Test-Path $configPath) {
            Write-Verbose -Message "$fileName __ Starting to pull changes from $repo to: $configPath"
            git -C $configPath pull
        }
        else {
            Write-Verbose -Message "$fileName __ Starting to clone $repo to: $configPath"
            git clone $repo $configPath
        }

        $configFiles = Get-ChildItem -Path $configPath -Filter *.yaml | Select-Object Name,FullName
        Lock-PodeObject -Object $Event.Lockable {
            Set-PodeState -Name configFiles -Value $configFiles.Name | Out-Null
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
        throw $_
    }
}