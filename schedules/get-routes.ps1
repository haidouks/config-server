{
    param($Event)
    $ErrorActionPreference = "Stop"
    $VerbosePreference = "Continue"
    $fileName = "get-routes"
    $stateFile = "./state.json"
    function Get-ConfigRoutes {
        [CmdletBinding()]
        param (
            # Parameter help description
            [Parameter(Mandatory=$false)]
            [ValidateNotNullOrEmpty()]
            $hash,
            [Parameter(Mandatory=$false)]
            [string]
            $path = ""
        )
        if($hash.Keys -ge 1) {
            foreach($key in $hash.Keys ) {    
                Get-ConfigRoutes -hash $hash."$key" -path "$path/$key"
            }
        }
        else {
            return @{$path=$hash}
        } 
    }
    
    $configs = $null
    Lock-PodeObject -Object $Event.Lockable {
        $configs = Get-PodeState -Name configs
    }
    Write-Verbose -Message "$fileName __ Received configs from shared state:`n$($configs | out-string)"
    $routes = Get-ConfigRoutes -hash $configs
    Lock-PodeObject -Object $Event.Lockable {
        Set-PodeState -Name routes -Value $routes.Keys | Out-Null
        Save-PodeState -Path $stateFile
    }
    foreach($route in $routes) {
        Write-Verbose -Message "$fileName __ Saving route to shared state: $($route | out-string)"
        Lock-PodeObject -Object $Event.Lockable {
            Set-PodeState -Name $route.Keys -Value $route.Values | Out-Null
            Save-PodeState -Path $stateFile
        }
    }
    
}