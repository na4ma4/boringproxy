FROM golang:1.15-alpine3.12 as builder

WORKDIR /build

RUN apk add git
RUN go get github.com/GeertJohan/go.rice/rice

COPY go.* ./
RUN go mod download
COPY . .

RUN rice embed-go
RUN cd cmd/boringproxy && CGO_ENABLED=0 go build -o boringproxy

FROM alpine:3.13 as certs
RUN apk --update add ca-certificates

FROM scratch 
EXPOSE 80 443

COPY --from=certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

COPY --from=builder /build/cmd/boringproxy/boringproxy /

ENTRYPOINT ["/boringproxy"]
CMD ["server"]
