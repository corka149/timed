# go get github.com/crazy-max/xgo

release:
	rm -rf build
	mkdir build
	cd build
	${GOPATH}/bin/xgo -ldflags='-s -w' github.com/corka149/timed
	strip timed-linux-amd64
