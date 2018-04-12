FROM golang:1.9-alpine as builder

RUN apk add --no-cache git
RUN go get -v github.com/Shark/docker-socket-proxy
#RUN go get -v github.com/tianon/gosu
RUN apk add --no-cache wget ca-certificates && update-ca-certificates
RUN wget 'https://github.com/tianon/gosu/releases/download/1.10/gosu-amd64' -O /bin/gosu && \
    chmod +x /bin/gosu

FROM alpine:3.7
COPY --from=builder /go/bin/docker-socket-proxy /bin/
COPY --from=builder /bin/gosu /bin/

CMD set -x; \
    : "${SOCKET:=/socket/docker-ro.sock}" && \
    rm -f "${SOCKET}" && \
    /bin/gosu "${UID:-0}:${GID:-0}" /bin/docker-socket-proxy -out /var/run/docker.sock -in "${SOCKET}"


