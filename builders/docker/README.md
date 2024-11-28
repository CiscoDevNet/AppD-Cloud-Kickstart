# Dockerized AppD Controller.

## What?
This will produce an 18GB+ Docker container with SystemD and full CentOS base to replicate a "full" AppD Controller appliance.
This is so we can re-use the existing install and validation scripts in `<repo>/provisioners` DIR's.
The aim was to use existing scripts without change, to prevent diverging and maintaining two sets of install scripts.

## Warnings
The local DB are ephemeral (stored inside the container) and will not persist by default.

## Build

`appd_username` and `appd_password` are credentials to the AppD download site to pull the latest controller RPM's and necessary dependancies.

```
cd <repo-root>
docker build --add-host=platformadmin:127.0.0.1 --build-arg appd_username=someusername --build-arg appd_password=somepassword . -f builders/docker/Dockerfile
```

## Run

``
 docker run -ti -v get_apm_platform_licence.env:/opt/get_apm_platform_licence.env --mount type=bind,source=/sys/fs/cgroup,target=/sys/fs/cgroup --add-host=platformadmin:127.0.0.1  --restart always -p8090:8090 -p9080:9080 -p9191:9191 -p8181:8181 <docker image>
`` 

The `-v /opt/get_apm_platform_licence.env` mount is to pass in S3 AWS credentials to a systemd `oneshot` service, which grabs a demo licence for the controller on each `docker run`.
The controller will startup without it, just won't be licenced.
See an example env file in `./builders/docker/get_apm_platform_licence.env.sample`

