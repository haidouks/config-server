{
    param($Event)
    $ErrorActionPreference = "Stop"
    $ProgressPreference = "SilentlyContinue"
    $env:VerbosePreference ? ($VerbosePreference = $env:VerbosePreference) : ($VerbosePreference = "SilentlyContinue")
    $fileName = "new-routes"
    $routes = $null
    $env:enableAuthentation ??= $false
    $authenticatedRoutes = $null

    try {
        if($env:enableAuthentation) {
            if($null -ne $env:authenticatedRoutes) {
                $authenticatedRoutes = $env:authenticatedRoutes.split(",")
            }
        }   
    
        Lock-PodeObject -Object $Event.Lockable {
            $routes = Get-PodeState -Name routes
        }
        Write-Verbose -Message "$(Get-Date -Format "yyyyMMddHHmmssfff") $fileName __ Received routes from shared state:`n$($routes | out-string)"

        $podeRoutes = (Get-PodeRoute).Path
        Write-Verbose -Message "$(Get-Date -Format "yyyyMMddHHmmssfff") $fileName __ Received routes from Pode:`n$($podeRoutes | out-string)"
        foreach($route in $routes) {
            if($podeRoutes -notcontains $route) {
                $authType = $null
                if($env:enableAuthentation) {
                    foreach($regex in $authenticatedRoutes) {
                        if($route -match $regex.split(":")[0]) {
                            $authType = $regex.split(":")[1]
                            $authType ??= "DefaultAuth"
                        }
                    }
                }
                Write-Verbose -Message "$(Get-Date -Format "yyyyMMddHHmmssfff") $fileName __ Adding route:$route with auth type:$authType"
                if($authType) {
                    Add-PodeRoute -Method Get -Path $route -ArgumentList $route -ScriptBlock {
                        param($s,$key)
                        $value = $null
                        Lock-PodeObject -Object $s.Lockable { 
                            $value = Get-PodeState -Name $key
                        }
                        Write-PodeJsonResponse -Value @{value = $value}
                    } -ErrorAction SilentlyContinue -Middleware (Get-PodeAuthMiddleware -Name $authType -Sessionless)
                }
                else{
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
        Invoke-PodeSchedule -Name 'remove-routes'
    }   
    catch {
        $exception = $($PSItem | select-object * |Format-Custom -Property * -Depth 1 | Out-String)
        Write-Warning -Message "$(Get-Date -Format "yyyyMMddHHmmssfff") $fileName __ $exception"
    }
}
