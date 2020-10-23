
release:
	rm -f timed-*
	go get github.com/crazy-max/xgo
	${GOPATH}/bin/xgo -ldflags='-s -w' github.com/corka149/timed
	strip timed-linux-amd64
	rm -f *arm-*
	rm -f *mips*
	rm -f *-386*
	rm -f *arm64