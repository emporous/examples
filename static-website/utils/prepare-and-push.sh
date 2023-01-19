#/bin/sh

script_dir="$(cd "${BASH_SOURCE[0]%/*}"; pwd -P)"

set -e
set -x
# Prepare

read -p 'Registry (e.g. localhost:5000/emporous/emporous-framework-examples): ' registry
registry=localhost:5000/emporous/emporous-framework-examples
read -p "Extra Flags (e.g. --plain-http): " flags
flags='--plain-http --insecure'


pushd demo-content/dev
git submodule update --init --recursive
hugo -D
popd
pushd demo-content/prod
git submodule update --init --recursive
hugo -D
popd

schemaAddress="${registry%/*}/staticwebsiteschema:latest"
#emporous build schema schema-config.yaml $registry-schema:latest
emporous build schema schema-config.yaml ${registry%/*}/staticwebsiteschema:latest
#emporous push $flags $registry-schema:latest
emporous push $flags "$schemaAddress"
set -v
(schemaAddress="$schemaAddress" envsubst <dataset-config.yaml-template >dataset-config-new.yaml)
#emporous build collection --dsconfig <(cd "$script_dir"; schemaAddress="$schemaAddress" envsubst <../dataset-config.yaml-template) demo-content $registry:static-website
emporous --loglevel debug build collection --no-verify --plain-http --dsconfig dataset-config-new.yaml demo-content $registry:static-website
emporous push $flags $registry:static-website
