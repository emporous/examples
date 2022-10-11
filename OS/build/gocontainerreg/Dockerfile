FROM docker.io/library/golang
RUN GOBIN=$PWD go install github.com/google/go-containerregistry/cmd/registry@latest
CMD ["./registry"]
