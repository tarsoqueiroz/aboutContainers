# Stage 1: Build the Go application
# FROM golang:1.23.3-alpine AS builder
FROM golang:1.22.11-alpine AS builder

WORKDIR /app

COPY main.go .

RUN go mod init minimalhttp

RUN go build -o /app/minimalhttp

# Stage 2: Create a minimal runtime environment
FROM scratch

COPY --from=builder /app/minimalhttp /app/minimalhttp

# Port exposing the app
EXPOSE 8910

# Command to run the application
CMD ["/app/minimalhttp"]

