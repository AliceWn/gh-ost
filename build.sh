#!/bin/bash
#
#

RELEASE_VERSION=$(cat RELEASE_VERSION)

function build {
    osname=$1
    osshort=$2
    GOOS=$3
    GOARCH=$4

    if ! go version | egrep -q 'go(1[.]9|1[.]1[0-9])' ; then
      echo "go version is too low. Must use 1.9 or above"
      exit 1
    fi

    echo "Building ${osname} binary"
    export GOOS
    export GOARCH
    go build -ldflags "$ldflags" -o $buildpath/$target go/cmd/gh-ost/main.go

    if [ $? -ne 0 ]; then
        echo "Build failed for ${osname}"
        exit 1
    fi

    (cd $buildpath && tar cfz ./gh-ost-binary-${osshort}-${timestamp}.tar.gz $target)
}

buildpath=/tmp/gh-ost
target=gh-ost
timestamp=$(date "+%Y%m%d%H%M%S")
ldflags="-X main.AppVersion=${RELEASE_VERSION}"

mkdir -p ${buildpath}
build macOS osx darwin amd64
build GNU/Linux linux linux amd64

echo "Binaries found in:"
ls -1 $buildpath/gh-ost-binary*${timestamp}.tar.gz
