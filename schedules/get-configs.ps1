{
    param($Event)
    $VerbosePreference = "Continue"
    $stateFile = "./state.json"
    $repo = "https://github.com/haidouks/configs.git"
    $configPath = "F:\cansinaldanmaz\workspace\github.com\haidouks\config-server\configurations\configs"
    $configFile = Join-Path -Path $configPath -ChildPath "test.yaml" 
    $fileName = "clone"
    try { 
        
        if(Test-Path $configFile) {
            Write-Verbose -Message "$fileName __ Starting to pulling changes from $repo to: $configPath"
            git -C $configPath pull 
        }
        else {
            Write-Verbose -Message "$fileName __ Starting to clone $repo to: $configPath"
            git clone $repo $configPath
        }
        
        $configs = Get-Content -Path $configFile -Raw | ConvertFrom-Yaml -AllDocuments
        Write-Verbose -Message "$fileName __ Received configs:`n$($configs | out-string)"
        Lock-PodeObject -Object $Event.Lockable {
            Set-PodeState -Name "configs" -Value $configs | Out-Null
            Save-PodeState -Path  $stateFile 
        }
        Write-Verbose -Message "$fileName __ Saved state to $stateFile"
    }
    catch {
        $_ | Out-PodeHost
        throw $PSItem
    }
}