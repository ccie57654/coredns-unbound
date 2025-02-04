ARG DEBIAN_IMAGE=debian:stable-slim
ARG GO_IMAGE=golang:1.22
ARG BASE=gcr.io/distroless/base-debian12:nonroot
FROM --platform=amd64 ${GO_IMAGE} AS compile
SHELL ["/bin/sh", "-ec"]

ENV GOFLAGS="-buildvcs=false"
ENV CGOENABLED=1

RUN git clone --depth 1 --branch v1.12.0 https://github.com/coredns/coredns.git
WORKDIR /go/coredns

RUN sed -i 's/^route53/#route53/; s/^clouddns/#clouddns/; s/^azure/#azure/' plugin.cfg ; \
    echo "unbound:github.com/coredns/unbound" >> plugin.cfg ; \
    apt-get -qq update ; \
    apt-get -yyqq install libunbound8 libunbound-dev ; \
    go get github.com/coredns/unbound ; \
    go generate && go build

FROM --platform=amd64 ${DEBIAN_IMAGE} AS build
SHELL [ "/bin/sh", "-ec" ]

RUN export DEBCONF_NONINTERACTIVE_SEEN=true \
           DEBIAN_FRONTEND=noninteractive \
           DEBIAN_PRIORITY=critical \
           TERM=linux ; \
    apt-get -qq update ; \
    apt-get -yyqq upgrade ; \
    apt-get -yyqq install ca-certificates libcap2-bin; \
    apt-get -yyqq install libunbound8 libevent-2.1-7 libgmp10 libhogweed6 libnettle8; \
    apt-get clean
COPY --from=compile /go/coredns/coredns /coredns
RUN setcap cap_net_bind_service=+ep /coredns

FROM --platform=amd64 ${BASE}
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /usr/lib/x86_64-linux-gnu/libunbound* /usr/lib/x86_64-linux-gnu/
COPY --from=build /usr/lib/x86_64-linux-gnu/libevent* /usr/lib/x86_64-linux-gnu/
COPY --from=build /usr/lib/x86_64-linux-gnu/libgmp* /usr/lib/x86_64-linux-gnu/
COPY --from=build /usr/lib/x86_64-linux-gnu/libhogweed* /usr/lib/x86_64-linux-gnu/
COPY --from=build /usr/lib/x86_64-linux-gnu/libnettle* /usr/lib/x86_64-linux-gnu/
COPY --from=build /coredns /coredns
USER nonroot:nonroot
WORKDIR /
EXPOSE 53 53/udp
ENTRYPOINT ["/coredns"]
