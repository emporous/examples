#/bin/sh
set -e
# Prepare

read -p 'Registry: ' registry
read -p "Extra Flags: " flags


pushd demo-content/dev
git submodule update --init --recursive
hugo -D
popd
pushd demo-content/prod
git submodule update --init --recursive
hugo -D
popd

uor push --dsconfig dataset-config.yaml $flags demo-content $registry:static-website