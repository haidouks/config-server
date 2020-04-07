{
    param($Event)
    $ErrorActionPreference = "Stop"
    $ProgressPreference = "SilentlyContinue"
    $VerbosePreference = "SilentlyContinue"
    $fileName = "new-routes"
    $routes = $null
    
    Lock-PodeObject -Object $Event.Lockable {
        $routes = Get-PodeState -Name routes
    }
    Write-Verbose -Message "$fileName __ Received routes from shared state:`n$($routes | out-string)"
    
    $podeRoutes = (Get-PodeRoute).Path
    Write-Verbose -Message "$fileName __ Received routes from Pode:`n$($podeRoutes | out-string)"
    foreach($route in $routes) {
        if($podeRoutes -notcontains $route) {
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
}