FROM mcr.microsoft.com/powershell:7.0.0-alpine-3.10
COPY . /usr/src/app/
EXPOSE 8085
RUN apk add --no-cache git
RUN git config --global http.sslVerify false
# RUN addgroup -S appgroup && adduser -S pwshuser -G appgroup
RUN chgrp -R 0 /usr/src/app/ && chmod -R g+rwX /usr/src/app/
#RUN chown -R pwshuser /root/.local/share/powershell /usr/src/app/
SHELL ["pwsh", "-command"]
RUN Set-PSReadLineOption -HistorySaveStyle SaveNothing
RUN (Get-Content -Path /usr/src/app/config.json | ConvertFrom-Json).requiredModules | ForEach-Object { Install-Module $_.Name -RequiredVersion $_.Version -Force -Scope AllUsers}
# USER pwshuser
WORKDIR /usr/src/app
CMD ./config-server.ps1
