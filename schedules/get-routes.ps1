{
    param($Event)
    
    $ErrorActionPreference = "Stop"
    $ProgressPreference = "SilentlyContinue"
    $VerbosePreference = $env:VerbosePreference ? $env:VerbosePreference : "SilentlyContinue"
    
    $fileName = "get-routes"
    $stateFile = "./state.json"
    
    try {
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

        $configFiles = $null
        Lock-PodeObject -Object $Event.Lockable {
            $configFiles = Get-PodeState -Name "configFiles"
        }
        $routes = New-Object System.Collections.ArrayList
        foreach ($configFile in $configFiles) {
            $configName = $configFile.Split(".")[0]
            Write-Verbose -Message "$fileName __ Getting configs for $configFile"
            $configs = $null

            Lock-PodeObject -Object $Event.Lockable {
                $configs = Get-PodeState -Name $configFile
            }
            Write-Verbose -Message "$fileName __ Preparing routes for $configName"
            $newRoutes = Get-ConfigRoutes -hash $configs -path "/$configName"
            foreach ($newRoute in $newRoutes) {
                if($routes.Keys -notcontains $newRoute.Keys) {
                    Write-Verbose -Message "$fileName __ Adding route $($newRoute | out-string)"
                    $null = $routes.Add($newRoute)
                }
            }
        }
        Write-Verbose -Message "$fileName __ Saving all route paths to shared state"
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
    catch {
        $exception = $($PSItem | select-object * |Format-Custom -Property * -Depth 1 | Out-String)
        Write-Warning -Message "$fileName __ $exception"
    }
    
    
}