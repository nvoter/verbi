FROM golang:1.23-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /service

FROM alpine:3.19
WORKDIR /app
COPY .env .env
COPY --from=builder /service /app/service
EXPOSE ${SERVER_PORT}
CMD ["/app/service"]