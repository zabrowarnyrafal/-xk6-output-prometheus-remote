FROM golang:1.16-alpine3.14 AS builder

ARG K6_VERSION=v0.35.0

RUN apk upgrade --no-cache --update && \
    apk add --no-cache --update ca-certificates git build-base wget tar

WORKDIR /app

ENV K6_VERSION=${K6_VERSION}

RUN go install go.k6.io/xk6/cmd/xk6@v0.5.0
RUN CGO_ENABLED=0 \
GOOS=linux \
GOPROXY=https://proxy.golang.org \
xk6 build --with github.com/grafana/xk6-output-prometheus-remote@latest


FROM alpine:3.14 AS runner

COPY --from=builder /app/k6 /opt/k6/k6
RUN chmod a+x /opt/k6/k6

RUN addgroup k6 && \
    adduser -D -G k6 --no-create-home -s /bin/sh k6

USER k6

WORKDIR /opt/k6/

CMD ["--help"]

ENTRYPOINT ["/opt/k6/k6"]
