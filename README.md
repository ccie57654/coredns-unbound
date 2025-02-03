# CoreDNS w/ Unbound
A container image that provides amd64 version of coreDNS w/ Unbound compiled in and all cloud provider plugins removed (Azure, AWS, GCP). The image is based on the same distroless image that the official coreDNS published docker image uses with the same entrypoint so all public documentation is applicable here.

## Usage

Default config (will not recurse):
`docker run -d --name coredns --restart=always -P ccie57654/coredns-unbound`

Custom corefile (named Corefile, no extension in the current directory)
`docker run -d --name coredns --restart=always --volume=${pwd}:/var/lib/coredns/ -P ccie57654/coredns-unbound -conf /var/lib/coredns/Corefile`


1. For now you must clone the coreDNS repository and compile with the plugin yourself, then copy the coredns binary to this folder and build the image (soon i will put this into the build image process so you can just use this Dockerfile to publish by selecting the public version of coreDNS)
2. Once that is completed you can publish the docker image wherever you want
3. To run this container you need at minimum a corefile containing the below

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
