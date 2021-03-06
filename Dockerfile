ARG src_dir="/go/src/github.com/cloudflare/gortr"

FROM golang:alpine as builder
ARG src_dir

RUN apk --update --no-cache add git && \
    mkdir -p ${src_dir}

WORKDIR ${src_dir}
COPY . .

RUN go get -u github.com/golang/dep/cmd/dep && \
    dep ensure && \
    go build cmd/gortr/gortr.go

FROM alpine:latest
ARG src_dir

RUN apk --update --no-cache add ca-certificates && \
    adduser -S -D -H -h / rtr
USER rtr

COPY --from=builder ${src_dir}/gortr ${src_dir}/cmd/gortr/cf.pub /
ENTRYPOINT ["./gortr"]
