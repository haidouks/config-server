{
    param($Event)
    $ErrorActionPreference = "Stop"
    $VerbosePreference = "Continue"
    
    $configs = $null
    Lock-PodeObject -Object $Event.Lockable {
        $configs = Get-PodeState -Name routes
    }

    foreach($config in $configs) {
        "Creating route $($config.Keys) Value:$($config.Values)" | Out-PodeHost
        Add-PodeRoute -Method Get -Path $config.Keys -ArgumentList $config.Values -ScriptBlock {
            param($s,$value)
            Write-PodeJsonResponse -Value @{value = $value}
        } -ErrorAction SilentlyContinue
    }
    
    "Removing unused routes" | Out-PodeHost  
    "$(Get-PodeRoute -Method Get | out-string)" | Out-PodeHost

}