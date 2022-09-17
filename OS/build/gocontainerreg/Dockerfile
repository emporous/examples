FROM registry.service.mcserverhosting.net/docker/library/golang
RUN GOBIN=$PWD go install github.com/google/go-containerregistry/cmd/registry@latest
CMD ["./registry"]
