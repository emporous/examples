#!/bin/sh
set -e
sudo podman run --privileged -v .:/profile ghcr.io/emporous/examples/archiso:latest mkarchiso -v -w /tmp -o /profile/out /profile
