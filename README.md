# [docker-openvpn][container]

[![Latest Tag](https://img.shields.io/github/tag/scoobadog/docker-openvpn.svg)](https://hub.docker.com/r/scoobadog/openvpn/tags/)
[![Docker Build](https://img.shields.io/docker/automated/scoobadog/docker-openvpn.svg)](https://hub.docker.com/r/scoobadog/openvpn/builds/)
[![Docker Pulls](https://img.shields.io/docker/pulls/scoobadog/openvpn.svg)](https://hub.docker.com/r/scoobadog/openvpn/)

A minimal [Alpine Linux][alpine] based [Docker][docker] container with
[OpenVPN][openvpn] and [s6][overlay] as a process supervisor.

All traffic from within the container to the Internet is forced through a VPN
tunnel by `iptables` rules and the container is configured to terminate in case
the VPN connection drops.

## Configuration

### DNS servers

An alternative DNS server should be used to prevent DNS leaks. Use the DNS
servers provided by the VPN provider or choose an alternative from the list
that [WikiLeaks][dns] has compiled.

### OpenVPN

Two configuration files are required by OpenVPN. VPN providers usually have
already made configuration files that can be used as is as the first file,
named `config.ovpn`. The second file, named `login.conf`, is used as a value
for `auth-user-pass` parameter and it must contain username on the first line
and password on the second line. For more information on how to configure
OpenVPN see the official documentation at the [website][openvpn-doc].

### Environment variables

`NETMON_INTERVAL` environment variable defines the interval in seconds between
connection checks. If left undefined a default value of 60 seconds will be used.
Environment variables can be passed using `-e NETMON_INTERVAL=120` syntax.

## Mount points

The container requires a couple of mount points to work, which are listed below.
Host directories and files can be mounted using `-v /host/path:/docker/path`
commandline argument.

### Mandatory

The container requires that the following files are mounted from the host.

```
/mnt/
	openvpn/
		config.ovpn
		login.conf
```

### Optional

OpenVPN process is configured to log its `stdout` and `stderr` into the files
listed below. To persist logs mount a directory as `/var/log/` or a file as
a single log file.

```
/var/log/
	netmon/
		stdout.log
	openvpn/
		stderr.log
		stdout.log
```

## SELinux

To use this container on a host that has SELinux enabled use the provided
`docker-openvpn.te` policy module or create your own if it doesn't work. To
compile and install the policy module run the following commands.

```
$ checkmodule -M -m docker-openvpn.te -o /tmp/docker-openvpn.mod
$ semodule_package -m /tmp/docker-openvpn.mod -o /tmp/docker-openvpn.pp
# semodule -i /tmp/docker-openvpn.pp
```

In addition to installing the module, the volumes must be mounted using the
`:Z` mount option so that Docker will relabel the volumes with a correct
security label.

## Usage

To run the container interactively execute the following command. Modify the
parameters to fit your environment.

```
# docker run -it --rm \
	--cap-add=NET_ADMIN --device=/dev/net/tun \
	--dns=8.8.8.8 --dns=8.8.4.4 \
	--volume ~/.config/openvpn:/mnt/openvpn:Z \
	scoobadog/docker-openvpn:latest
```

### systemd service

A reliable way to start the container at boot time and restart it, if something
goes wrong and the container shuts down, is to let systemd to manage the
container. Use the following code snippet as a template, modify the parameters
to fit your environment and save it as
`/usr/lib/systemd/system/docker-openvpn.service`.

```
[Unit]
Description=docker-openvpn
After=docker.service
Requires=docker.service

[Service]
Restart=always
ExecStart=/usr/bin/docker run \
	--cap-add=NET_ADMIN --device=/dev/net/tun \
	--dns=8.8.8.8 --dns=8.8.4.4 \
	--volume ~/.config/openvpn:/mnt/openvpn:Z \
	--name openvpn scoobadog/docker-openvpn:latest
ExecStop=/usr/bin/docker stop -t 10 openvpn
ExecStopPost=/usr/bin/docker rm -f openvpn

[Install]
WantedBy=multi-user.target
```

To enable and start the service run the following commands.

```
# systemctl enable docker-openvpn
# systemctl start docker-openvpn
```

## License

docker-openvpn is licensed under the MIT License.

[container]: https://github.com/scoobadog/docker-openvpn
[alpine]: https://alpinelinux.org/
[docker]: https://www.docker.com/
[openvpn]: https://openvpn.net/
[openvpn-doc]: https://openvpn.net/index.php/open-source/documentation/howto.html
[overlay]: https://github.com/just-containers/s6-overlay
[dns]: https://www.wikileaks.org/wiki/Alternative_DNS
