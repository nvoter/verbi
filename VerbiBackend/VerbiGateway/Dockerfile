FROM golang:1.23-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o gateway .

FROM alpine:3.20
WORKDIR /app
COPY --from=builder /app/gateway .
EXPOSE 8082
ENTRYPOINT ["./gateway"]
