{
    param($Event)
    $VerbosePreference = "Continue"
    $stateFile = "./state.json"
    $repo = "https://github.com/haidouks/configs.git"
    $configFile = "./configurations/test.yaml" 
    $fileName = "clone"
    try { 
        Write-Verbose -Message "$fileName __ Starting to clone repository: $repo"
        #git clone  ../configurations | Out-PodeHost

        $configs = Get-Content -Path $configFile -Raw | ConvertFrom-Yaml -AllDocuments
        Write-Verbose -Message "$fileName __ Received configs:`n$($configs | out-string)"
        Lock-PodeObject -Object $Event.Lockable {
            Set-PodeState -Name configs -Value $configs | Out-Null
            Save-PodeState -Path  $stateFile 
        }
        Write-Verbose -Message "$fileName __ Saved state to $stateFile"
    }
    catch {
        $_ | Out-PodeHost
        throw $PSItem
    }
}