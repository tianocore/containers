# Windows 2022

Because there is fewer tool support around Windows containers, currently they need
to be manually managed. The following instructions can be used to configure the
Windows dev container.

```cmd
docker pull ghcr.io/tianocore/containers/windows-2022-build:latest
docker run -i -v C:\host\code\path:C:\src --workdir=C:\src --name=<name> ghcr.io/tianocore/containers/windows-2022-build:latest
```

After being created, the image can be resumed with the following command.

```cmd
docker start -i <name>
```

## Git Credentials

The windows contains come with the Windows Git credential manager which will prompt
for a one-time web browser based device authentication method when git is used. This
will allow you to authenticate your docker image without having to explicitly enter
credentials into the docker image.
