# syntax=docker/dockerfile:1.4

# -=== Builder image ===-
FROM golang:1 as builder

WORKDIR /app

COPY <<EOF main.go
package main

import (
  "fmt"
  "os"
)

func main() {
  f, err := os.CreateTemp("", "sample")
  if err != nil {
    panic(err)
  }

  fmt.Println("Temporary file:", f.Name())
}
EOF

RUN CGO_ENABLED=0 go build main.go

# -=== Target image ===-
FROM scratch

COPY --from=builder /app/main /

CMD ["/main"]
