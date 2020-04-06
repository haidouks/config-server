{
    param($Event)
    $ErrorActionPreference = "Stop"
    $VerbosePreference = "Continue"
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
               Get-KeyHier -hash $hash."$key" -path "$path/$key"
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
    Write-Verbose -Message "Received configs from shared state"
    $routes = Get-ConfigRoutes -hash $configs

    Lock-PodeObject -Object $Event.Lockable {
        Set-PodeState -Name routes -Value $routes | Out-Null
        Save-PodeState -Path './state.json'
    }

    foreach($config in $configs) {
        "Creating route $($config.Keys) Value:$($config.Values)" | Out-PodeHost
        Add-PodeRoute -Method Get -Path $config.Keys -ArgumentList $config.Values -ScriptBlock {
            param($s,$value)
            Write-PodeJsonResponse -Value @{value = $value}
    } -ErrorAction SilentlyContinue
    
}
}