FROM openshift/origin-release:golang-1.10 as builder

RUN mkdir -p /go/src/github.com/openshift/hive
WORKDIR /go/src/github.com/openshift/hive

COPY pkg/    pkg/
COPY cmd/    cmd/
COPY vendor/ vendor/
COPY contrib/ contrib/
COPY hack/ hack/

RUN GOPATH="/go" go get -u github.com/golang/mock/gomock
RUN GOPATH="/go" go get -u github.com/golang/mock/mockgen
RUN GOPATH="/go" PATH="${PATH}:/go/bin" go generate ./pkg/... ./cmd/...
RUN GOPATH="/go" CGO_ENABLED=0 GOOS=linux go build -o /go/bin/manager -ldflags '-extldflags "-static"' github.com/openshift/hive/cmd/manager
RUN GOPATH="/go" CGO_ENABLED=0 GOOS=linux go build -o /go/bin/hiveutil -ldflags '-extldflags "-static"' github.com/openshift/hive/contrib/cmd/hiveutil

FROM centos:7

COPY --from=builder /go/bin/manager /opt/services/
COPY --from=builder /go/bin/hiveutil /usr/bin/
