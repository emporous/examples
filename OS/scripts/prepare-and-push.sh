#!/bin/sh
set -e 
emporous build collection emporous go.registry:1338/test:latest --dsconfig=dataset-config.yaml
emporous push go.registry:1338/test:latest --insecure --plain-http
