# docker-rootless-api-tls
Example of how to run docker rootless, and expose the api via TLS
This example is known to run on Ubuntu 23 and 24, easily adaptable to other distros

setup.sh is commented.  Not expected to necessarily run, but more of a "guide".

more info on docker rootless:
https://docs.docker.com/engine/security/rootless/


## High Level Steps (detailed in setup.sh)
1. Install Docker, Containerd and other requirements
2. Run setup-rootless script packaged with Docker Community
3. prevent docker from accidentally being start and run as root
4. Do CA, server cert, key and other "certificate" operations, and copy to respective locations
5. Create systemd and daemon configuration files and copy to respective locations
6. reload systemd configuration and start service
7. example call to docker info using api over tls and expected output


## Example Verification of Docker Info showing api responding, after all the other setup.
```
docker --context rootless --tlsverify --tlscacert /home/name/.docker/certs/ca-cert.pem --tlscert /home/name/.docker/certs/server-cert.pem --tlskey /home/name/.docker/certs/server-key.pem info

Client: Docker Engine - Community
 Version:    27.3.1
 Context:    rootless
 Debug Mode: false
 Plugins:
  buildx: Docker Buildx (Docker Inc.)
    Version:  v0.17.1
    Path:     /usr/libexec/docker/cli-plugins/docker-buildx
  compose: Docker Compose (Docker Inc.)
    Version:  v2.29.7
    Path:     /usr/libexec/docker/cli-plugins/docker-compose

Server:
 Containers: 1
  Running: 1
  Paused: 0
  Stopped: 0
 Images: 4
 Server Version: 27.3.1
 Storage Driver: overlay2
  Backing Filesystem: extfs
  Supports d_type: true
  Using metacopy: false
  Native Overlay Diff: true
  userxattr: true
 Logging Driver: json-file
 Cgroup Driver: systemd
 Cgroup Version: 2
 Plugins:
  Volume: local
  Network: bridge host ipvlan macvlan null overlay
  Log: awslogs fluentd gcplogs gelf journald json-file local splunk syslog
 Swarm: inactive
 Runtimes: io.containerd.runc.v2 runc
 Default Runtime: runc
 Init Binary: docker-init
 containerd version: 7f7fdf5fed64eb6a7caf99b3e12efcf9d60e311c
 runc version: v1.1.14-0-g2c9f560
 init version: de40ad0
 Security Options:
  seccomp
   Profile: builtin
  rootless
  cgroupns
 Kernel Version: 6.8.0-48-generic
 Operating System: Ubuntu 24.04.1 LTS
 OSType: linux
 Architecture: x86_64
 CPUs: 8
 Total Memory: 31.14GiB
 Name: host.example.com
 ID: 258208ed-7c67-4221-9166-00a1bb643851
 Docker Root Dir: /home/name/.local/share/docker
 Debug Mode: false
 Experimental: false
 Insecure Registries:
  127.0.0.0/8
 Live Restore Enabled: false

WARNING: No cpuset support
WARNING: No io.weight support
WARNING: No io.weight (per device) support
WARNING: No io.max (rbps) support
WARNING: No io.max (wbps) support
WARNING: No io.max (riops) support
WARNING: No io.max (wiops) support
WARNING: bridge-nf-call-iptables is disabled
WARNING: bridge-nf-call-ip6tables is disabled
```