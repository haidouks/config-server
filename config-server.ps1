#region Set Parameters
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
$VerbosePreference = "SilentlyContinue"
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
    Install-Module -Name $_.Name -RequiredVersion $_.Version -Force -AllowClobber 
}
#endregion

Start-PodeServer -Threads $env:ThreadCount {
    Import-PodeModule -Name "powershell-yaml"
    New-PodeLoggingMethod -Terminal | Enable-PodeErrorLogging
    New-PodeLoggingMethod -Terminal | Enable-PodeRequestLogging
    Restore-PodeState -Path './state.json'
    Add-PodeEndpoint -Address * -Port $env:PodePort -Protocol Http
    
    Add-PodeSchedule -Name 'get-config' -Cron '@minutely' -FilePath ./schedules/get-configs.ps1
    Add-PodeSchedule -Name 'get-routes' -Cron '@minutely' -FilePath ./schedules/get-routes.ps1
    Add-PodeSchedule -Name 'new-routes' -Cron '@minutely' -FilePath ./schedules/new-routes.ps1
    Add-PodeSchedule -Name 'remove-routes' -Cron '@minutely' -FilePath ./schedules/remove-routes.ps1
    
}
