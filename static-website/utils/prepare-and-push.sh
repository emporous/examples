#/bin/sh
set -e
set -x
# Prepare

read -p 'Registry (e.g. localhost:5000/d10n/uor-framework-examples): ' registry
read -p "Extra Flags (e.g. --plain-http): " flags


pushd demo-content/dev
git submodule update --init --recursive
hugo -D
popd
pushd demo-content/prod
git submodule update --init --recursive
hugo -D
popd

emporous build collection --dsconfig dataset-config.yaml demo-content $registry:static-website
emporous push $flags $registry:static-website
