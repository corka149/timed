
release:
	rm -f timed-*
	go install github.com/crazy-max/xgo
	${GOPATH}/bin/xgo -ldflags='-s -w' github.com/corka149/timed
	strip timed-linux-amd64
