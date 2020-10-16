FROM mcr.microsoft.com/powershell:7.0.0-alpine-3.10
COPY . /usr/src/app/
RUN pwsh -c '$VerbosePreference = "Continue"; $config = Get-Content -Path /usr/src/app/config.json | ConvertFrom-Json; $config.requiredModules | ForEach-Object { Install-Module $_.Name -RequiredVersion $_.Version -Force -Scope CurrentUser}'
EXPOSE 8085
RUN apk add --no-cache git
RUN git config --global http.sslVerify false
CMD [ "pwsh", "-c", "cd /usr/src/app; ./config-server.ps1" ] 
