#/bin/sh
set -e
#Uses https://github.com/shurcooL/goexec
#go get -u github.com/shurcooL/goexec

rm -rf /tmp/static-site
mkdir -p /tmp/static-site
pushd /tmp/static-site

read -p 'Registry: ' registry
read -p "Release version: " release
read -p "Extra Flags: " flags

echo "Pulling content"
uor pull $flags --attributes release=$release $registry:static-website . 

echo "Serving demo content on http://localhost:8081 with attributes --- ctrl+c to stop."
GO111MODULE=auto goexec 'http.ListenAndServe(`:8081`,http.FileServer(http.Dir(`'$release'/public`)))'
