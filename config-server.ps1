#region Set Parameters
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
$VerbosePreference = "Continue"
$env:PodePort ??= 8085
$env:ThreadCount ??= 10
#endregion

#region Uninstall/Install Required Modules
$requiredModules = @(
    @{Name = "pode"; Version = "1.6.1"},
    @{Name = "powershell-yaml"; Version = "0.4.1"}
)

$requiredModules | ForEach-Object {
    Uninstall-Module -Name $_.Name -Force -AllVersions -ErrorAction SilentlyContinue
    Install-Module -Name $_.Name -RequiredVersion $_.Version -Force -Repository "ZT-PSGallery" -AllowClobber
}
#endregion

Start-PodeServer -Threads $env:ThreadCount {
    Import-PodeModule -Name "powershell-yaml"
    New-PodeLoggingMethod -Terminal | Enable-PodeErrorLogging
    New-PodeLoggingMethod -Terminal | Enable-PodeRequestLogging
    Restore-PodeState -Path './state.json'
    Add-PodeEndpoint -Address * -Port $env:PodePort -Protocol Http
    # Add-PodeSchedule -Name 'save-state' -Cron '@minutely' -ScriptBlock {
    #     param($e)
    #     #git clone https://github.com/haidouks/configs.git configurations 
    #     $testConfigs = Get-Content -Path ./configurations/test.yaml -Raw | ConvertFrom-Yaml
    #     $testConfigs | Out-String | Out-PodeHost
    #     Lock-PodeObject -Object $e.Lockable {
    #         Set-PodeState -Name 'test' -Value @{Name="ali"} | Out-Null
    #         "In lock" | out-podehost
    #         Get-PodeState -Name 'test'| Out-String | Out-PodeHost
    #         Save-PodeState -Path '/Users/cansinaldanmaz/Downloads/workspace/github.com/haidouks/config-server/state.json' -Verbose
    #     } -verbose
    #     "Get state" | Out-PodeHost
    #     Get-PodeState -Name 'test'| Out-String | Out-PodeHost
    #     "Saving kjhaskdad" | Out-PodeHost
    # }
    Add-PodeSchedule -Name 'get-config' -Cron '@minutely' -FilePath ./schedules/get-configs.ps1
    Add-PodeSchedule -Name 'get-routes' -Cron '@minutely' -FilePath ./schedules/get-routes.ps1
    Add-PodeSchedule -Name 'new-routes' -Cron '@minutely' -FilePath ./schedules/new-routes.ps1
    #    param($e)
    #    $VerbosePreference = "Continue"
    #    try { 
    #        "Clonning repository" | Out-PodeHost
    #        git clone https://github.com/haidouks/configs.git configurations | Out-PodeHost
    #        $testConfigs = Get-Content -Path ./configurations/test.yaml -Raw | ConvertFrom-Yaml -AllDocuments
    #        "Saving:`n$($testConfigs|out-String)" | Out-PodeHost
    #        # ensure we're thread safe
    #        Lock-PodeObject -Object $e.Lockable {
    #            "Getting State11:" | Out-PodeHost
    #            Set-PodeState -Name 'test' -Value @{ 'Name' = 'Rick Sanchez' }| Out-Null
    #            Save-PodeState -Path './state.json'
    #            "Getting State:" | Out-PodeHost
    #        }
    #        "Disarda Getting State" | Out-PodeHost
    #        }
    #    catch {
    #        throw $_
    #    }
    #}
    Add-PodeRoute -Method Get -Path '/ping' -ScriptBlock {
        Write-PodeJsonResponse -Value @{Status = "Healthy"}
    }
}
