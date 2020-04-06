{
    param($Event)
    $ErrorActionPreference = "Stop"
    $VerbosePreference = "Continue"
    $fileName = "new-routes"
    $routes = $null
    
    Lock-PodeObject -Object $Event.Lockable {
        $routes = Get-PodeState -Name routes
    }
    Write-Verbose -Message "$fileName __ Received routes from shared state:`n$($routes | out-string)"

    foreach($route in $routes) {
        Add-PodeRoute -Method Get -Path $route -ArgumentList $route -ScriptBlock {
            param($s,$key)
            $value = $null
            Lock-PodeObject -Object $s.Lockable {
                $value = Get-PodeState -Name $key
            }
            Write-PodeJsonResponse -Value @{value = $value}
        } -ErrorAction SilentlyContinue
    }
}