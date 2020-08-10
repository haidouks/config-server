#region Set Parameters
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
$VerbosePreference = $env:VerbosePreference ? $env:VerbosePreference : "Continue"
        
$env:PodePort ??= 8085
$env:ThreadCount ??= 5
$config = Get-Content -Path .\config.json | ConvertFrom-Json
#endregion

#region Uninstall/Install Required Modules
ForEach ($module in $config.requiredModules) {
    $existingModule = Get-Module -Name $module.Name -All -ListAvailable | Where-Object{$_.Version -eq $module.Version}
    if($null -eq $existingModule) {
        Write-Verbose -Message "$(Get-Date -Format "yyyyMMddHHmmssfff") Installing module:$($module.Name) version:$($module.Version) from $($module.Repository)"
        Install-Module -Name $module.Name -RequiredVersion $module.Version -Force -AllowClobber -AllowPrerelease -Repository $module.Repository -Scope CurrentUser
    }
}
#endregion

Start-PodeServer -Threads $env:ThreadCount {
    Import-PodeModule -Name "powershell-yaml"
    
    New-PodeLoggingMethod -Terminal | Enable-PodeErrorLogging
    New-PodeLoggingMethod -Terminal | Enable-PodeRequestLogging
    
    Add-PodeEndpoint -Address * -Port $env:PodePort -Protocol Http
    
    $configPath = Join-Path -Path (Get-PodeServerPath) -ChildPath "configs"
    (Test-Path -Path $configPath) ? "" : (New-Item -Path $configPath -ItemType Directory)
    $stateFile = Join-Path -Path $configPath -ChildPath "state.json"
    Restore-PodeState -Path $stateFile
    
    Add-PodeSchedule -Name 'set-auth' -Cron '@minutely' -Limit 1 -FilePath ./schedules/set-auth.ps1 -OnStart
    Add-PodeSchedule -Name 'get-repo' -Cron '@minutely'  -FilePath ./schedules/get-repo.ps1 -OnStart
    Add-PodeSchedule -Name 'get-configs' -Cron '@hourly' -Limit 1 -FilePath ./schedules/get-configs.ps1
    Add-PodeSchedule -Name 'get-routes' -Cron '@hourly' -Limit 1 -FilePath ./schedules/get-routes.ps1
    Add-PodeSchedule -Name 'new-routes' -Cron '@hourly' -Limit 1 -FilePath ./schedules/new-routes.ps1
    Add-PodeSchedule -Name 'remove-routes' -Cron '@hourly' -Limit 1 -FilePath ./schedules/remove-routes.ps1
    
}
