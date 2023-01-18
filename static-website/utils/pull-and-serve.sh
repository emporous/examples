#/bin/sh
set -e

rm -rf /tmp/static-site
mkdir -p /tmp/static-site
pushd /tmp/static-site

read -p 'Registry (e.g. localhost:5000/emporous/examples): ' registry
read -p "Release version (dev|prod): " release
read -p "Extra Flags (e.g. --no-verify --plain-http): " flags

echo "Pulling content"
( set -x; emporous pull $flags --attributes release=$release $registry:static-website -o .; )

echo "Serving demo content on http://localhost:8081 with attributes --- ctrl+c to stop."

#Uses https://github.com/shurcooL/goexec
#go get -u github.com/shurcooL/goexec
#GO111MODULE=auto goexec 'http.ListenAndServe(`:8081`,http.FileServer(http.Dir(`'$release'/public`)))'

( cd "$release/public"; python3 -m http.server 8081; )
