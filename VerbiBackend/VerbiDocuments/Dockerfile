FROM golang:1.23-alpine AS builder
WORKDIR /app
RUN go install github.com/swaggo/swag/cmd/swag@v1.8.7
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN swag init
RUN CGO_ENABLED=0 GOOS=linux go build -o /service

FROM alpine:3.19
WORKDIR /app
RUN apk add --no-cache ca-certificates
COPY .env .env
COPY --from=builder /service /app/service
COPY host_rsa_key /app/host_rsa_key
EXPOSE ${SERVER_PORT} 2022
ENV SFTP_PORT=2022
ENV SFTP_HOST_KEY=/app/host_rsa_key
CMD ["/app/service"]
