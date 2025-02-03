# CoreDNS w/ Unbound

1. For now you must clone the coreDNS repository and compile with the plugin yourself, then copy the coredns binary to this folder and build the image (soon i will put this into the build image process so you can just use this Dockerfile to publish)
2. Once that is completed you can publish wherever you want
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

To leverage the corefile you need to provide it to the docker container you run via volume mount such as below:

`ocker run -d --name coredns --restart=always --volume=${pwd}:/var/lib/coredns/ -P coredns-unbound -conf /var/lib/coredns/Corefile`