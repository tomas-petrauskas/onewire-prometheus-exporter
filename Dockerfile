FROM golang:1.23 AS builder
LABEL org.opencontainers.image.source https://github.com/tomas-petrauskas/go-tapo-exporter

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy the Go modules files and download the dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy the source code into the container
COPY . .

# Build the Go application
RUN CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -o onewire-prometheus-exporter .

# Start a new stage from scratch
FROM alpine:latest

# Install required packages for accessing 1-Wire devices
RUN apk --no-cache add \
    curl \
    && apk add --no-cache --virtual .build-deps \
    gcc \
    musl-dev \
    && apk del .build-deps

# Copy the binary from the builder stage
COPY --from=builder /app/onewire-prometheus-exporter /usr/local/bin/

# Command to run the application
CMD ["/usr/local/bin/onewire-prometheus-exporter"]