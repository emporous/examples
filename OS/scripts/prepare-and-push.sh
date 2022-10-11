#!/bin/sh
set -e 
uor build collection uor go.registry:1338/test:latest --dsconfig=dataset-config.yaml 
uor push go.registry:1338/test:latest --insecure --plain-http