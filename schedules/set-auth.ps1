{
    param($Event)
    $ErrorActionPreference = "Stop"
    $ProgressPreference = "SilentlyContinue"
    $env:VerbosePreference ? ($VerbosePreference = $env:VerbosePreference) : ($VerbosePreference = "SilentlyContinue")
    $fileName = "set-auth"
    $env:defaultAuthToken = "QweAsdZxc123"
    try {
        New-PodeAuthType -Bearer | Add-PodeAuth -Name 'DefaultAuth' -ScriptBlock {
            param($token)
            if ($token -eq $env:defaultAuthToken) {
                return @{
                    User = @{
                        'Name' = 'BestName'
                        'Type' = 'User'
                    }
                }
            }
            return $null
        }
    }
    catch {
        $exception = $($PSItem | select-object * |Format-Custom -Property * -Depth 1 | Out-String)
        Write-Warning -Message "$(Get-Date -Format "yyyyMMddHHmmssfff") $fileName __ $exception"
    }


}