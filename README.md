# CoreDNS w/ Unbound
A container image that provides amd64 version of coreDNS w/ Unbound compiled in and all cloud provider plugins removed (Azure, AWS, GCP). The image is based on the same distroless image that the official coreDNS published docker image uses with the same entrypoint so all public documentation is applicable here.

## Usage

Default config (will not recurse):
`docker run -d --name coredns --restart=always -P ccie57654/coredns-unbound`

Custom corefile (named Corefile, no extension in the current directory):

`docker run -d --name coredns --restart=always --volume=${pwd}:/var/lib/coredns/ -P ccie57654/coredns-unbound -conf /var/lib/coredns/Corefile`


## Building your own image

1. Have at least docker community edition installed on a linux host
2. Clone this repo and cd into the directory
3. run `DOCKER_BUILDKIT=1 docker build -t {image_name} ./`
4. push to a repository if you want


## Notes
To run this container and leverage unbound you need at minimum a corefile containing the below, also if you are on systemd based linux host and use the `-P` parameter to publish exposed port 53, it will conflict with systemd-resolved, you can disable this service (recommended for servers) or bind to an alternate port.

```
. {
    unbound 
}
```

Although I would recommend at least the following:

```
. {
    unbound 
    cache
    log
}
```
