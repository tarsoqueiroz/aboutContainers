# What's Inside Of a Distroless Container Image: Taking a Deeper Look

## About

> `https://iximiuz.com/en/posts/containers-distroless-images/`
>
> `https://github.com/GoogleContainerTools/distroless`

GoogleContainerTools' distroless base images are often mentioned as one of the ways to produce small(er), fast(er), and secure(r) containers. But what are these distroless images, really? Why are they needed? What's the difference between a container built from a distroless base and a container built from scratch? Let's take a deeper look.

Tools:

- [Bazel](https://bazel.build/): From startup to enterprise, choose the Bazel open source project to build and test your multi-language, multi-platform projects.

## Pitfalls of scratch containers

A while ago, I was debunking a (mine only?) misconception that every container has an operating system inside. Using an empty (aka scratch) base image, I created a container holding just a single file - a tiny hello-world program. And, ~~to my utter surprise,~~ when I ran it, it worked out well! Besides other things, it allowed me to conclude that **having a full-blown Linux distro in a container is not mandatory**.

But, as it often happens in labs, that experiment was staged 🙈

To make my point stronger, I deliberately oversimplified the test executable by creating it statically linked and doing nothing but printing a bunch of `ASCII` characters. So, what if I try to repeat that experiment today but use slightly more involved apps? Will it reveal any non-obvious problems with scratch containers?

### Preparing the new stage

The article is going to be a hands-on one (learn by doing == ❤️) with the only prerequisite of having a machine with Docker on it. To make the examples reproducible, I'll write them as multi-staged Dockerfiles (shamelessly abusing the heredoc feature). However, to avoid bloating the article, I'll keep most of the Dockerfiles collapsed by default and highlight only the important parts instead.

Here is the general idea:

```dockerfile
# syntax=docker/dockerfile:1.4

# -=== Builder image ===-
FROM golang:1 as builder

WORKDIR /app

COPY <<EOF main.go
package main

import (
  ...
)

func main() {
  <...test program goes here...>
}
EOF

RUN CGO_ENABLED=0 go build main.go


# -=== Target image ===-
FROM scratch

COPY --from=builder /app/main /

CMD ["/main"]
```

### Pitfall 1: Scratch containers miss proper user management

The very first thing I'll try to put into a "from scratch" container is the following Go snippet printing out some information about the current user:

```go
user, err := user.Current()
if err != nil {
  panic(err)
}

fmt.Println("UID:", user.Uid)
fmt.Println("GID:", user.Gid)
fmt.Println("Username:", user.Username)
fmt.Println("Name:", user.Name)
fmt.Println("HomeDir:", user.HomeDir)
```

- [Docker file Pitfall 1](./resources/Dockerfile.pitfall1)

Build it with:

```sh
docker buildx build -t scratch-current-user -f Dockerfile.pitfall1 .
```

Let's try to run it and see if it works:

```sh
docker run --rm scratch-current-user
```

Result:

```sh
panic: user: Current requires cgo or $USER set in environment

goroutine 1 [running]:
main.main()
  /app/main.go:11 +0x23c
```

That's a pity! A failure from the first try. Can it be fixed, though?

The cgo is off the scope here (I intentionally disabled it to avoid the dependency on libc or any other shared libraries), so according to the Go stdlib, the only remaining way to fix the problem is by setting the $USER environment variable:

```sh
docker run --rm -e USER=root scratch-current-user
```

Result:

```sh
UID: 0
GID: 0
Username: root
Name:
HomeDir: /
```

Seems to work! But containers shouldn't run as root. Can another user be used?

```sh
docker run --rm -e USER=nonroot scratch-current-user
```

Result:

```sh
UID: 0
GID: 0
Username: nonroot
Name:
HomeDir: /
```

Ah, shoot! The `nonroot` user also has the UID `0`! In other words, it's the same `root` but in disguise. Maybe using the `--user` flag will help?

```sh
docker run --user nonroot --rm scratch-current-user
```

Result:

```sh
docker: Error response from daemon:
  unable to find user root:
  no matching entries in passwd file.
```

Nope. But Docker gave me a good pointer here - is the passwd file even there?! So, this was my first realization:

**The `/etc/passwd` and `/etc/group` files are missing in *"from scratch"* containers.**

Placing these two files manually into the end image seems to resolve the issue:

```Dockerfile
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
```

- [Docker file Pitfall 1b](./resources/Dockerfile.pitfall1b)

Build it with:

```sh
docker buildx build -t scratch-current-user-fixed -f Dockerfile.pitfall1b .
```

Let's try to run it and see if it works.

Running with `root` user:

```sh
docker run --user root --rm scratch-current-user-fixed
```

Result:

```sh
UID: 0
GID: 0
Username: root
Name: root
HomeDir: /root
```

Running with `nonroot` user:

```sh
docker run --user nonroot --rm scratch-current-user-fixed
```

Result:

```sh
UID: 65532
GID: 65532
Username: nonroot
Name: nonroot
HomeDir: /home/nonroot
```

Finally, the example works as expected. But manual user management is not fun 🙃

### Pitfall 2: Scratch containers miss important folders

Here is another example - it's pretty common for a program to create temporary files and folders:

```go
f, err := os.CreateTemp("", "sample")
if err != nil {
  panic(err)
}

fmt.Println("Temporary file:", f.Name())
```

- [Docker file Pitfall 2](./resources/Dockerfile.pitfall2)

Build it with:

```sh
docker buildx build -t scratch-tmp-file -f Dockerfile.pitfall2 .
```

But apparently, **creating a temporary file using the above Go snippet fails in a *"from scratch"* container**:

```sh
docker run --user root --rm scratch-current-user-fixed
```

Result:

```sh
panic: open /tmp/sample386939664: no such file or directory

goroutine 1 [running]:
main.main()
  /app/main.go:11 +0xbc
```

The fix is simple - make sure the `/tmp` folder exists in the running container. There are different ways to achieve it, including mounting a folder on the fly. Although it might be annoying to do it manually (don't forget about the sticky bit - the directory mode needs to be set carefully 😉):

```sh
docker run --rm --mount 'type=tmpfs,dst=/tmp,tmpfs-mode=1777' scratch-tmp-file
```

Result:

```sh
Temporary file: /tmp/sample2333717960
```

And, of course, the other important locations like `/home` or `/var` might be missing too!

### Pitfall 3: Scratch containers miss CA certificates

