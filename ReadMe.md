# Config Server

## What is Config Server?
Config Server is a Cross-Platform key/value store which dynamically converts yaml files into rest services. 

## How to store Config Files?
Actually it is up to you.  `schedules/get-repo.ps1` file is responsible from getting yamls from remote and by default, config server assumes that yaml files are kept in a git repository. 

But it is possible to add custom logic to get/sync yaml files or completely disabling and working on existing local yaml files by changing `schedules/get-repo.ps1`.

![config-server](https://user-images.githubusercontent.com/23384662/80245529-8b05de00-8673-11ea-8142-018c7ee5c51f.png)


## Yaml file Format
Assume that you have 2 yaml files `test1.yaml` and `test2.yaml`;

* test1.yaml
``` yaml
---
nested:
  array:
  - this
  - is
  - an
myKey: world1
```

* test2.yaml
``` yaml
myKey2: myValue2
```

Config server will convert all keys in all yaml files to the following endpoints:
* /test1/nested/array
* /test1/myKey
* /test2/myKey2


## How to run?

### Requirements

>If you use `cnsn/config-server` base image, all requirements are already installed inside this docker image.

>If you want to run config-server out side of containers, first thing you need is Powershell Core(>6.0). Then you need to install `git` and be able to reach repos defined in Powershell Gallery.

>When you start `config-server.ps1` for the first time, following modules will be installed from Powershell Gallery if they are not installed already:

* Powershell-Yaml (Powershell Module)
* Pode (Powershell Module)
* PSCache (Powershell Module)

>If you want to install them manually, you can use following commands:

``` Powershell
Install-Module -Name "powershell-yaml" -RequiredVersion 0.4.1 -Force -Scope CurrentUser
Install-Module -Name "pode" -RequiredVersion 1.6.1 -Force -Scope CurrentUser
Install-Module -Name "pscache" -RequiredVersion 0.1.0 -Force -Scope CurrentUser
```


#### Environment Variables
Config server will use environment variables during server startup to configure itself. They are:
* `repo`: Remote git repo address that config server will clone and pull periodically. Default: https://github.com/haidouks/configs
* `PodePort`: Port that will config server will be listening. Default: 8085
* `ThreadCount`: Dedicated thread count for all routes. Default: 5
* `VerbosePreference`: Enable verbose logging. Default: SilentlyContinue


#### Examples
Example 1: Quick start
``` Docker
docker run -d -p 8085:8085 cnsn/config-server:latest
```
Example 2: Configure variables
``` Docker
docker run -d -p 8085:8085 \
    -e VerbosePreference=Continue \
    -e ThreadCount=10 \
    -e repo=https://github.com/haidouks/configs \
    cnsn/config-server
```
