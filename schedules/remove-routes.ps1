{
    param($Event)
    
    $ErrorActionPreference = "Stop"
    $ProgressPreference = "SilentlyContinue"
    $VerbosePreference = $env:VerbosePreference ? $env:VerbosePreference : "SilentlyContinue"

    try {
        $fileName = "remove-routes"
        $routes = $null
        Write-Verbose -Message "$fileName __ Getting unused routes"
        Lock-PodeObject -Object $Event.Lockable {
            $routes = Get-PodeState -Name routes
        }
        Write-Verbose -Message "$fileName __ Received routes defined in shared state:$($routes |Out-String)"

        $podeRoutes = (Get-PodeRoute).Path
        Write-Verbose -Message "$fileName __ Received routes defined in pode:$($podeRoutes |out-string)"
        if($null -ne $routes)
        {
            foreach($podeRoute in $podeRoutes) {
                if($routes -notcontains $podeRoute) {
                    Write-Warning -Message "$fileName __ Removing $podeRoute from pode routes"
                    Remove-PodeRoute -Path $podeRoute -Method Get
                    Lock-PodeObject -Object $Event.Lockable {
                        Remove-PodeState -Name $podeRoute -ErrorAction SilentlyContinue | Out-Null
                    }
                }
            }
        }
        else {
            Write-Warning -Message "$fileName __ There is no route in shared state!"
        }
    }
    catch {
        $exception = $($PSItem | select-object * |Format-Custom -Property * -Depth 1 | Out-String)
        Write-Warning -Message "$fileName __ $exception"
    }
}