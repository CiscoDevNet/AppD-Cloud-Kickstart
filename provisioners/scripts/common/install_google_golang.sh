#!/bin/sh -eux
# install go programming language from google.

# install go programming language. ---------------------------------------------
gohome="go"
gorelease="1.13.6"
gobinary="${gohome}${gorelease}.linux-amd64.tar.gz"
gofolder="${gohome}-${gorelease}"

# create apache parent folder.
mkdir -p /usr/local/google
cd /usr/local/google

# download go binary from googleapis.com.
wget --no-verbose https://storage.googleapis.com/golang/${gobinary}

# extract go binary.
rm -f ${gohome}
tar -zxvf ${gobinary} --no-same-owner --no-overwrite-dir
chown -R root:root ./${gohome}
mv ${gohome} ${gofolder}
ln -s ${gofolder} ${gohome}
rm -f ${gobinary}

# set go home environment variables.
GOROOT=/usr/local/google/${gohome}
export GOROOT
PATH=${GOROOT}/bin:$PATH
export PATH

# verify installation.
go version
