{
    param($Event)
    $ErrorActionPreference = "Stop"
    $ProgressPreference = "SilentlyContinue"
    $VerbosePreference = "SilentlyContinue"
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
            if($routes -notcontains $podeRoute -and $routes.split("/")[1] -ne "api") {
                Write-Warning -Message "$fileName __ Removing $podeRoute from pode routes"
                Remove-PodeRoute -Path $podeRoute -Method Get
            }
        }
    }
    else {
        Write-Warning -Message "$fileName __ There is no route in shared state!"
    }
}