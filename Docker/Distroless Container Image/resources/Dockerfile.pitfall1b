# syntax=docker/dockerfile:1.4

# -=== Builder image ===-
FROM golang:1 as builder

WORKDIR /app

COPY <<EOF main.go
package main

import (
  "fmt"
  "os/user"
)

func main() {
  user, err := user.Current()
  if err != nil {
    panic(err)
  }

  fmt.Println("UID:", user.Uid)
  fmt.Println("GID:", user.Gid)
  fmt.Println("Username:", user.Username)
  fmt.Println("Name:", user.Name)
  fmt.Println("HomeDir:", user.HomeDir)
}
EOF

RUN CGO_ENABLED=0 go build main.go

# -=== Target image ===-
FROM scratch

COPY <<EOF /etc/group
root:x:0:
nonroot:x:65532:
EOF

COPY <<EOF /etc/passwd
root:x:0:0:root:/root:/sbin/nologin
nonroot:x:65532:65532:nonroot:/home/nonroot:/sbin/nologin
EOF

COPY --from=builder /app/main /

CMD ["/main"]
